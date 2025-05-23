import UIKit
import CoreData

final class StatisticStore {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    static let shared = StatisticStore()
    
    // MARK: - Init
    private init() {
        self.context = PersistentContainer.shared.viewContext
        print("\(#file):\(#line)] \(#function) StatisticStore инициализирован")
    }
    
    // MARK: - Methods
    
    /// Обновляет статистику: вычисляет показатели, очищает старые записи и сохраняет новые данные.
    func updateStatistics() {
        do {
            // Получаем все записи трекеров
            let fetchRequest = TrackerRecordCoreData.fetchRequest()
            let records = try context.fetch(fetchRequest)
            
            let completedTrackers = records.count
            
            let calendar = Calendar.current
            // Группируем записи по началу дня
            let groupedByDate = Dictionary(grouping: records) { record -> Date in
                let date = record.date ?? Date()
                return calendar.startOfDay(for: date)
            }
            
            // Для сегодняшней даты получаем количество записей
            let today = calendar.startOfDay(for: Date())
            let todayRecords = groupedByDate[today]?.count ?? 0
            
            // Получаем общее количество трекеров
            let trackersFetchRequest = TrackerCoreData.fetchRequest()
            let allTrackers = try context.fetch(trackersFetchRequest)
            let totalTrackers = allTrackers.count
            
            // Подсчитываем идеальные дни и лучший период (стрейк)
            let idealDays = calculateIdealDays(groupedRecords: groupedByDate)
            let bestStreak = calculateBestStreak(groupedRecords: groupedByDate)
            
            // Вычисляем процент завершения для сегодняшнего дня
            let averageCompletion = totalTrackers > 0 ? Int((Double(todayRecords) / Double(totalTrackers)) * 100) : 0
            
            // Удаляем старые записи статистики
            let clearRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StatisticCoreData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: clearRequest)
            try context.execute(deleteRequest)
            try context.save()
            
            // Формируем новые данные статистики
            let statisticData = StatisticData(
                completedTrackers: completedTrackers,
                idealDays: idealDays,
                averageCompletion: averageCompletion,
                bestStreak: bestStreak
            )
            // Сохраняем статистику
            saveStatistics(statisticData)
            
            // Посылаем уведомление об обновлении статистики
            NotificationCenter.default.post(
                name: NSNotification.Name("StatisticsDataDidChange"),
                object: nil
            )
            
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка обновления статистики: \(error)")
        }
    }
    
    /// Подсчитывает количество идеальных дней, когда количество записей совпадает с общим числом трекеров.
    private func calculateIdealDays(groupedRecords: [Date: [TrackerRecordCoreData]]) -> Int {
        var idealDays = 0
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let totalTrackers = allTrackers.count
            
            for (_, dayRecords) in groupedRecords {
                if dayRecords.count == totalTrackers {
                    idealDays += 1
                }
            }
            print("\(#file):\(#line)] \(#function) Подсчет идеальных дней: \(idealDays) из \(groupedRecords.count)")
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка подсчета идеальных дней: \(error)")
        }
        
        return idealDays
    }
    
    /// Подсчитывает лучший период (наибольший стейк последовательных дней)
    private func calculateBestStreak(groupedRecords: [Date: [TrackerRecordCoreData]]) -> Int {
        let dates = groupedRecords.keys.sorted()
        guard !dates.isEmpty else { return 0 }
        
        var currentStreak = 1
        var maxStreak = 1
        let calendar = Calendar.current
        
        for i in 1..<dates.count {
            let previousDate = dates[i-1]
            let currentDate = dates[i]
            let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            if daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    /// Сохраняет данные статистики в Core Data.
    private func saveStatistics(_ data: StatisticData) {
        let statisticEntity = StatisticCoreData(context: context)
        statisticEntity.completedTrackers = Int64(data.completedTrackers)
        statisticEntity.idealDays = Int64(data.idealDays)
        statisticEntity.averageCompletion = Int64(data.averageCompletion)
        statisticEntity.bestStreak = Int64(data.bestStreak)
        
        do {
            try context.save()
            print("\(#file):\(#line)] \(#function) Статистика сохранена в CoreData")
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка сохранения статистики: \(error)")
        }
    }
    
    /// Метод для очистки статистики (удаления всех объектов StatisticCoreData).
    func clearStatistics() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StatisticCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Статистика очищена")
            NotificationCenter.default.post(name: NSNotification.Name("StatisticsDataDidChange"), object: nil)
        } catch {
            print("Ошибка при очистке статистики: \(error)")
        }
    }
    
    /// Возвращает статистику из Core Data. Если статистика не найдена – возвращает значения по умолчанию (0).
    func fetchStatistics() -> StatisticData {
        let fetchRequest = StatisticCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bestStreak", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let statisticEntity = try context.fetch(fetchRequest).first {
                return StatisticData(
                    completedTrackers: Int(statisticEntity.completedTrackers),
                    idealDays: Int(statisticEntity.idealDays),
                    averageCompletion: Int(statisticEntity.averageCompletion),
                    bestStreak: Int(statisticEntity.bestStreak)
                )
            }
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка загрузки статистики: \(error)")
        }
        
        return StatisticData(completedTrackers: 0, idealDays: 0, averageCompletion: 0, bestStreak: 0)
    }
}

// MARK: - StatisticData

struct StatisticData {
    let completedTrackers: Int
    let idealDays: Int
    let averageCompletion: Int
    let bestStreak: Int
}
