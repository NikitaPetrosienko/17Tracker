
import Foundation

protocol CategoryListViewModelProtocol {
    var onCategoriesUpdated: (([CategoryViewModel]) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var onEmptyStateChanged: ((Bool) -> Void)? { get set }
    
    func loadCategories()
    func selectCategory(_ title: String)
    func deleteCategory(title: String)
    func updateCategory(oldTitle: String, newTitle: String)
}
