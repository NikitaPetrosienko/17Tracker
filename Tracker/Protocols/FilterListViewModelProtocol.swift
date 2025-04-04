
import Foundation

protocol FilterListViewModelProtocol {
    var onFilterChanged: ((FilterType) -> Void)? { get set }
    var onSelectedFilterChanged: ((FilterType) -> Void)? { get set } 
    var selectedFilter: FilterType { get }
    var filters: [FilterType] { get }
    func selectFilter(_ filter: FilterType)
}
