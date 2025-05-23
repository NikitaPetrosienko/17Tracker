
import Foundation

protocol NewHabitControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
    func didUpdateTracker(_ tracker: Tracker, category: String)
}
