
import CoreData

final class TrackerCoreStoreFetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: NSNotification.Name("TrackersDataDidChange"),
            object: nil
        )
        print("\(#file):\(#line)] \(#function) База обновилась")
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
           case .insert:
               print("\(#file):\(#line)] \(#function) Добавлен новый объект")
           case .delete:
               print("\(#file):\(#line)] \(#function) Объект удален")
           case .update:
               print("\(#file):\(#line)] \(#function) Объект обновлен")
           case .move:
               print("\(#file):\(#line)] \(#function) Объект перемещен")
           @unknown default:
               print("\(#file):\(#line)] \(#function) Неизвестное изменение")
           }
    }
}
