
import Foundation

final class FilterListViewModel: FilterListViewModelProtocol {
    
    // MARK: - Properties
    
    var onFilterChanged: ((FilterType) -> Void)?
     private(set) var selectedFilter: FilterType {
         didSet {
             UserDefaults.standard.set(selectedFilter.rawValue, forKey: "selectedFilter")
         }
     }
     
     let filters: [FilterType] = FilterType.allCases
     var onSelectedFilterChanged: ((FilterType) -> Void)?
     
     init() {
         let savedFilterRawValue = UserDefaults.standard.string(forKey: "selectedFilter") ?? FilterType.todayTrackers.rawValue
         self.selectedFilter = FilterType(rawValue: savedFilterRawValue) ?? .todayTrackers
     }
     
     // MARK: - Methods
     
     func selectFilter(_ filter: FilterType) {
         selectedFilter = filter
         onFilterChanged?(filter)
         onSelectedFilterChanged?(filter)
         print("\(#file):\(#line)] \(#function) Выбран фильтр: \(filter.rawValue)")
     }
 }
