
import Foundation

protocol TrackerRecordStoreProtocol {
    func addNewRecord(_ record: TrackerRecord) throws
    func fetchRecords() throws -> [TrackerRecord]
}
