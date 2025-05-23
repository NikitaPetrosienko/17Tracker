
final class NewCategoryViewModel {
    
    // MARK: - Types
    
    typealias ValidationHandler = (Bool) -> Void
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    // MARK: - Properties
    
    private let trackerCategoryStore: TrackerCategoryStore
    
    // MARK: - Bindings
    
    var onValidationChanged: ValidationHandler?
    var onCompletion: CompletionHandler?
    
    // MARK: - Init
    
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    // MARK: - Methods
    
    func validateInput(_ text: String?) {
        let isValid = text?.isEmpty == false
        onValidationChanged?(isValid)
    }
    
    func createCategory(title: String) {
        let category = TrackerCategory(title: title, trackers: [])
        
        do {
            try trackerCategoryStore.createCategory(category)
            onCompletion?(.success(title))
            print("\(#file):\(#line)] \(#function) Создана новая категория: \(title)")
        } catch {
            onCompletion?(.failure(error))
            print("\(#file):\(#line)] \(#function) Ошибка создания категории: \(error)")
        }
    }
}
