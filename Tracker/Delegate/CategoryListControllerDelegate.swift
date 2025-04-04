
import Foundation

protocol CategoryListControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
    func didUpdateCategories(_ categories: [String]) 
}
