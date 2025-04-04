
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
    
    func updateStatistics() {
        do {
            let fetchRequest = TrackerRecordCoreData.fetchRequest()
            let records = try context.fetch(fetchRequest)
            
            let completedTrackers = records.count
            
            let calendar = Calendar.current
            let groupedByDate = Dictionary(grouping: records) { record -> Date in
                let date = record.date ?? Date()
                return calendar.startOfDay(for: date)
            }
            
            let today = calendar.startOfDay(for: Date())
            let todayRecords = groupedByDate[today]?.count ?? 0
            
            let trackersFetchRequest = TrackerCoreData.fetchRequest()
            let allTrackers = try context.fetch(trackersFetchRequest)
            let totalTrackers = allTrackers.count
            
            let idealDays = calculateIdealDays(groupedRecords: groupedByDate)
            
            let averageCompletion = totalTrackers > 0 ? Int((Double(todayRecords) / Double(totalTrackers)) * 100) : 0
            
            let bestStreak = calculateBestStreak(groupedRecords: groupedByDate)
            
            let clearRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StatisticCoreData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: clearRequest)
            try context.execute(deleteRequest)
            
            let statisticData = StatisticData(
                completedTrackers: completedTrackers,
                idealDays: idealDays,
                averageCompletion: averageCompletion,
                bestStreak: bestStreak
            )
            saveStatistics(statisticData)
            
            NotificationCenter.default.post(
                name: NSNotification.Name("StatisticsDataDidChange"),
                object: nil
            )
            
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка обновления статистики: \(error)")
        }
    }
    
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
    
    private func calculateAverageCompletion(records: [TrackerRecordCoreData]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let todayRecords = records.filter { record in
            guard let date = record.date else { return false }
            return calendar.isDate(date, inSameDayAs: startOfDay)
        }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let totalPossibleCompletions = allTrackers.count
            guard totalPossibleCompletions > 0 else { return 0 }
            
            return Int((Double(todayRecords.count) / Double(totalPossibleCompletions)) * 100)
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка подсчета среднего завершения: \(error)")
            return 0
        }
    }
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
