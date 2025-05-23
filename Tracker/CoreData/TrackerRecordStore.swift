
import CoreData
import Foundation

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    convenience override init() {
        let context = PersistentContainer.shared.viewContext
        self.init(context: context)
        print("\(#file):\(#line)] \(#function) TrackerRecordStore инициализирован с дефолтным контекстом")
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        print("\(#file):\(#line)] \(#function) TrackerRecordStore инициализирован с переданным контекстом")
    }
    
    // MARK: - Methods
    
    func addNewRecord(_ record: TrackerRecord) throws {
        let idPredicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        let datePredicate = NSPredicate(format: "date == %@", record.date as CVarArg)
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            idPredicate,
            datePredicate
        ])
        
        do {
            let existingRecords = try context.fetch(fetchRequest)
            if existingRecords.isEmpty {
                let recordCoreData = TrackerRecordCoreData(context: context)
                recordCoreData.id = record.id
                recordCoreData.date = record.date
                try context.save()
                print("\(#file):\(#line)] \(#function) Сохранена запись для трекера ID: \(record.id)")
            } else {
                print("\(#file):\(#line)] \(#function) Запись уже существует для трекера ID: \(record.id)")
            }
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка сохранения записи: \(error)")
            throw error
        }
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordsCoreData = try context.fetch(request)
            return try recordsCoreData.map { try record(from: $0) }
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка загрузки записей: \(error)")
            throw error
        }
    }
    
    private func record(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = recordCoreData.id,
              let date = recordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidData
        }
        
        return TrackerRecord(
            id: id,
            date: date
        )
    }
    
    func deleteRecord(id: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let idPredicate = NSPredicate(format: "id == %@", id as CVarArg)
        let datePredicate = NSPredicate(format: "date >= %@ AND date < %@",
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            idPredicate,
            datePredicate
        ])
        
        do {
            let records = try context.fetch(fetchRequest)
            if records.isEmpty {
                print("\(#file):\(#line)] \(#function) Запись для удаления не найдена: ID \(id), дата \(date)")
                return
            }
            
            for record in records {
                context.delete(record)
                print("\(#file):\(#line)] \(#function) Удаляется запись: ID \(String(describing: record.id)), дата \(String(describing: record.date))")
            }
            
            try context.save()
            print("\(#file):\(#line)] \(#function) Успешно удалено записей: \(records.count)")
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка удаления записи: \(error)")
            throw error
        }
    }
}

// MARK: - Errors

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidData
}

