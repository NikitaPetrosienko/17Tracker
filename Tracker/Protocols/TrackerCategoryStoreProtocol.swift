
import Foundation

protocol TrackerCategoryStoreProtocol {
    func createCategory(_ category: TrackerCategory) throws
    func fetchCategories() throws -> [TrackerCategory]
    func deleteCategory(title: String) throws 
}
