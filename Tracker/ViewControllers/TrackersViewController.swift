

import UIKit
import CoreData
import YandexMobileMetrica

final class TrackersViewController: UIViewController, FilterListControllerDelegate {
    
    // MARK: - FilterListControllerDelegate
    func didSelectFilter(_ filter: FilterType) {
        filteredTracker(filter)
    }
    
    // MARK: - Properties
    
    // NSFetchedResultsController для автоматического отслеживания изменений в Core Data
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    let layoutParams = LayoutParams()
    var filteredCategories: [TrackerCategory] = []
    var categories: [TrackerCategory] = []
    var currentDate: Date = Date()
    var completedTrackers: Set<CompletedTrackerID> = []
    
    // Свойства спринта 17
    private let trackerStore: TrackerStoreProtocol = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var currentFilter: FilterType = .allTrackers
    private var searchText: String = ""
    let bottomInset: CGFloat = 80
    let params: [AnyHashable: Any] = [
        "key1": "value1",
        "key2": "value2"
    ]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
    
    struct LayoutParams {
        let columnCount: Int = 2
        let interItemSpacing: CGFloat = 9
        let leftInset: CGFloat = 16
        let rightInset: CGFloat = 16
        
        var totalInsetWidth: CGFloat {
            leftInset + rightInset + interItemSpacing * (CGFloat(columnCount) - 1)
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plusButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.trackersText
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = Localization.searchText
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.backgroundImage = UIImage()
        sb.backgroundColor = .clear
        sb.tintColor = .black
        return sb
    }()
    
    private lazy var placeholderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        // При отсутствии трекеров placeholder показывается
        stack.isHidden = true
        return stack
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "trackerPlaceholder")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.emptyStateText
        label.textColor = .label
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        picker.tintColor = .blue
        if let textLabel = picker.subviews.first?.subviews.first as? UILabel {
            textLabel.font = .systemFont(ofSize: 17)
        }
        return picker
    }()
    
    private lazy var emptyFilterLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.nothingNotFoundText
        label.textColor = .label
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var emptyFilterImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "NothingNotFound")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(named: "background")
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        cv.register(SupplementaryView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "header")
        cv.register(SupplementaryView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: "footer")
        return cv
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.filtersButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Если хотите, чтобы экран поддерживал системную тему, удалите принудительный light mode
        // if #available(iOS 13.0, *) {
        //     overrideUserInterfaceStyle = .light
        // }
        setupViews()
        setupNavigationBar()
        setupPlaceholder()
        setupCollectionView()
        setupFetchedResultsController()
        updatePlaceholderVisibility()
        loadTrackersFromStore()
        loadTrackerRecords()
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDataUpdate),
                                               name: NSNotification.Name("TrackersDataDidChange"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.trackEvent("open", parameters: ["Screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.trackEvent("close", parameters: ["Screen": "Main"])
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "background")
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        placeholderStack.addArrangedSubview(placeholderImageView)
        placeholderStack.addArrangedSubview(placeholderLabel)
        view.addSubview(placeholderStack)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        view.addSubview(emptyFilterLabel)
        view.addSubview(emptyFilterImage)
        setupTapGestureForKeyboardDismiss()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            
            emptyFilterImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFilterImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyFilterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFilterLabel.topAnchor.constraint(equalTo: emptyFilterImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupNavigationBar() {
        let addButton = UIButton(frame: CGRect(x: 6, y: 0, width: 42, height: 42))
        addButton.setImage(UIImage(named: "plusButton"), for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        let addBarButton = UIBarButtonItem(customView: addButton)
        let dateBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.leftBarButtonItem = addBarButton
        navigationItem.rightBarButtonItem = dateBarButton
    }
    
    private func setupPlaceholder() {
        placeholderStack.isHidden = false
        
        NSLayoutConstraint.activate([
            placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupCollectionView() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTapGestureForKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - NSFetchedResultsController Setup
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: PersistentContainer.shared.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении fetch: \(error)")
        }
    }
    
    // MARK: - Data Loading & Filtering
    
    private func updatePlaceholderVisibility() {
        let hasVisibleTrackers = !filteredCategories.isEmpty
        let isSearching = !searchText.isEmpty

        if hasVisibleTrackers {
            // Если трекеры есть – показываем коллекцию и скрываем оба placeholder-а
            collectionView.isHidden = false
            placeholderStack.isHidden = true
            emptyFilterLabel.isHidden = true
            emptyFilterImage.isHidden = true
        } else {
            // Если трекеры отсутствуют – скрываем коллекцию
            collectionView.isHidden = true
            if isSearching {
                // Если пользователь ищет, показываем emptyFilter (например, "Ничего не найдено")
                placeholderStack.isHidden = true
                emptyFilterLabel.isHidden = false
                emptyFilterImage.isHidden = false
                emptyFilterLabel.text = Localization.nothingNotFoundText
            } else {
                // Если поиск не активен, показываем основной placeholder (например, "Что будем отслеживать?")
                placeholderStack.isHidden = false
                emptyFilterLabel.isHidden = true
                emptyFilterImage.isHidden = true
            }
        }
    }

    private func filterTrackersByDate(_ date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let adjustedWeekday = WeekDay(rawValue: weekday == 1 ? 7 : weekday - 1) ?? .monday
        print("\(#file):\(#line)] \(#function) Фильтрация для даты: \(date), день недели: \(adjustedWeekday.shortName)")
        
        let filtered = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                let isIrregular = tracker.schedule.count == 1 && tracker.creationDate != nil
                if isIrregular {
                    let isCompletedAny = completedTrackers.contains { $0.id == tracker.id }
                    if isCompletedAny {
                        let isCompletedToday = completedTrackers.contains {
                            $0.id == tracker.id && calendar.isDate($0.date, inSameDayAs: date)
                        }
                        return isCompletedToday
                    } else {
                        return true
                    }
                } else {
                    return tracker.schedule.contains(adjustedWeekday)
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        print("Найдено после фильтрации: категорий - \(filtered.count), трекеров - \(filtered.reduce(0) { $0 + $1.trackers.count })")
        return filtered
    }
    
    private func loadTrackerRecords() {
        do {
            let records = try trackerRecordStore.fetchRecords()
            completedTrackers = Set(records.map { CompletedTrackerID(id: $0.id, date: $0.date) })
            print("\(#file):\(#line)] \(#function) Загружено записей: \(records.count)")
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка загрузки записей трекеров: \(error)")
        }
    }
    
    private func loadTrackersFromStore() {
        guard let coreDatas = fetchedResultsController.fetchedObjects else { return }
        
        do {
            let loadedTrackers = try coreDatas.map { coreData -> Tracker in
                return try (trackerStore as! TrackerCoreStore).tracker(from: coreData)
            }
            
            var dict: [String: [Tracker]] = [:]
            let pinned = loadedTrackers.filter { $0.isPinned }
            if !pinned.isEmpty {
                // Используем литерал для закреплённых
                dict["Закрепленные"] = pinned
            }
            let unpinned = loadedTrackers.filter { !$0.isPinned }
            for tracker in unpinned {
                let categoryTitle = tracker.originalCategory ?? "Важное"
                dict[categoryTitle, default: []].append(tracker)
            }
            
            categories = dict.map { TrackerCategory(title: $0.key, trackers: $0.value) }
            categories.sort { cat1, cat2 in
                if cat1.title == "Закрепленные" {
                    return true
                }
                if cat2.title == "Закрепленные" {
                    return false
                }
                return cat1.title < cat2.title
            }
            
            filteredCategories = filterTrackersByDate(currentDate)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.updatePlaceholderVisibility()
                self.updateFilterButtonVisibility()
                print("\(#file):\(#line)] \(#function) Загружено категорий: \(self.categories.count)")
            }
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка преобразования объектов трекера: \(error)")
        }
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let newTrackerController = NewTrackerController()
        newTrackerController.delegate = self
        let nav = UINavigationController(rootViewController: newTrackerController)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
        
        AnalyticsService.shared.trackEvent("click", parameters: [
            "Screen": "Main",
            "Item": "add_track"
        ])
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        let formattedDate = dateFormatter.string(from: sender.date)
        print("Выбрана дата: \(formattedDate)")
        
        filteredTracker(currentFilter)
        updateFilterButtonVisibility()
    }
    
    @objc private func filterButtonTapped() {
        let filterVM = FilterListViewModel()
        let filterController = FilterListController(viewModel: filterVM)
        filterController.delegate = self
        filterController.modalPresentationStyle = .automatic
        present(filterController, animated: true)
       
        AnalyticsService.shared.trackEvent("click", parameters: [
            "Screen": "Main",
            "Item": "filter"
        ])
    }
    
    // MARK: - Tracker Management
    
    func isTrackerCompleted(_ tracker: Tracker, date: Date) -> Bool {
        let completedID = CompletedTrackerID(id: tracker.id, date: date)
        return completedTrackers.contains(completedID)
    }
    
    func addTrackerRecord(_ tracker: Tracker, date: Date) {
        let completedID = CompletedTrackerID(id: tracker.id, date: date)
        completedTrackers.insert(completedID)
        do {
            let record = TrackerRecord(id: tracker.id, date: date)
            try trackerRecordStore.addNewRecord(record)
            StatisticStore.shared.updateStatistics()
            print("\(#file):\(#line)] \(#function) Сохранена запись трекера: \(tracker.title)")
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка сохранения записи трекера: \(error)")
        }
        collectionView.reloadData()
    }
    
    func removeTrackerRecord(_ tracker: Tracker, date: Date) {
        let completedID = CompletedTrackerID(id: tracker.id, date: date)
        do {
            try trackerRecordStore.deleteRecord(id: tracker.id, date: date)
            completedTrackers.remove(completedID)
            StatisticStore.shared.updateStatistics()
            print("\(#file):\(#line)] \(#function) Успешно удалена запись трекера: \(tracker.title)")
            collectionView.reloadData()
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка удаления записи трекера: \(error)")
        }
    }
    
    func countCompletedDays(for tracker: Tracker) -> Int {
        return completedTrackers.filter { $0.id == tracker.id }.count
    }
    
    func createCategory(withTitle title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        categories.append(newCategory)
        filteredCategories = filterTrackersByDate(currentDate)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updatePlaceholderVisibility()
            print("Добавлена новая категория: \(title)")
        }
    }
    
    struct CompletedTrackerID: Hashable {
        let id: UUID
        let date: Date
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(Calendar.current.startOfDay(for: date))
        }
        static func == (lhs: CompletedTrackerID, rhs: CompletedTrackerID) -> Bool {
            return lhs.id == rhs.id &&
                Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
    }
    
    func filteredTracker(_ filter: FilterType) {
        currentFilter = filter
        switch filter {
        case .allTrackers:
            filteredCategories = filterTrackersByDate(currentDate)
        case .todayTrackers:
            datePicker.setDate(Date(), animated: true)
            currentDate = Date()
            filteredCategories = filterTrackersByDate(currentDate)
        case .completedTrackers:
            let dateFiltered = filterTrackersByDate(currentDate)
            filteredCategories = dateFiltered.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    isTrackerCompleted(tracker, date: currentDate)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        case .uncompletedTrackers:
            let dateFiltered = filterTrackersByDate(currentDate)
            filteredCategories = dateFiltered.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    !isTrackerCompleted(tracker, date: currentDate)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
        print("\(#file):\(#line)] \(#function) Применен фильтр: \(filter.rawValue)")
    }
    
    private func updateFilterButtonVisibility() {
        let hasTrackersForDate = !filterTrackersByDate(currentDate).isEmpty
        filterButton.isHidden = !hasTrackersForDate
    }
    
    @objc private func handleDataUpdate() {
        loadTrackersFromStore()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackersViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("NSFetchedResultsController: база обновилась")
        loadTrackersFromStore()
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Выделена ячейка: \(indexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu(title: "", children: []) }
            
            let pinTitle = tracker.isPinned ? Localization.unPinText : Localization.pinText
            let pinImage = UIImage(systemName: tracker.isPinned ? "pin.slash" : "pin")
            
            let pinAction = UIAction(title: pinTitle, image: pinImage) { [weak self] _ in
                guard let self = self else { return }
                let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.item]
                let categoryTitle = self.filteredCategories[indexPath.section].title
                let updatedTracker = Tracker(
                    id: tracker.id,
                    title: tracker.title,
                    color: tracker.color,
                    emoji: tracker.emoji,
                    schedule: tracker.schedule,
                    isPinned: !tracker.isPinned,
                    creationDate: tracker.creationDate,
                    originalCategory: tracker.isPinned ? tracker.originalCategory : categoryTitle
                )
                
                do {
                    try self.trackerStore.updateTracker(updatedTracker)
                    self.loadTrackersFromStore()
                    
                    if let categoryIndex = self.categories.firstIndex(where: { $0.title == categoryTitle }) {
                        var updatedTrackers = self.categories[categoryIndex].trackers
                        if let trackerIndex = updatedTrackers.firstIndex(where: { $0.id == tracker.id }) {
                            updatedTrackers[trackerIndex] = updatedTracker
                            self.categories[categoryIndex] = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
                        }
                    }
                    
                    self.collectionView.reloadData()
                    self.updatePlaceholderVisibility()
                    
                    print("Трекер \(tracker.isPinned ? "откреплен" : "закреплен"): \(tracker.title)")
                } catch {
                    print("Ошибка при обновлении трекера: \(error)")
                }
            }
            
            let editAction = UIAction(title: Localization.editText, image: UIImage(systemName: "pencil")) { [weak self] _ in
                guard let self = self,
                      let category = self.categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) else { return }
                let completedDays = self.countCompletedDays(for: tracker)
                let newHabitController = NewHabitController()
                newHabitController.delegate = self
                newHabitController.configurator(tracker: tracker, categoryTitle: category.title)
                newHabitController.setCompletedDaysCount(completedDays)
                self.present(newHabitController, animated: true)
                AnalyticsService.shared.trackEvent("click", parameters: [
                    "Screen": "Main",
                    "Item": "edit"
                ])
            }
            
            let deleteAction = UIAction(title: Localization.deleteText,
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                let alert = UIAlertController(title: Localization.deleteTrackerText,
                                              message: nil,
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: Localization.cancelText, style: .cancel))
                alert.addAction(UIAlertAction(title: Localization.deleteText, style: .destructive) { [weak self] _ in
                    self?.deleteTracker(at: indexPath)
                })
                self.present(alert, animated: true)
                AnalyticsService.shared.trackEvent("click", parameters: [
                    "Screen": "Main",
                    "Item": "delete"
                ])
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Снято выделение с ячейки: \(indexPath.item)")
    }
}

// MARK: - NewHabitControllerDelegate

extension TrackersViewController: NewHabitControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        // Если NSFetchedResultsController уже обновляет данные автоматически,
        // достаточно просто перезагрузить collectionView и обновить placeholder.
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }
    
    func didUpdateTracker(_ tracker: Tracker, category: String) {
        do {
            try trackerStore.updateTracker(tracker)
            loadTrackersFromStore()
            collectionView.reloadData()
            print("Трекер обновлен: \(tracker.title)")
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
}

extension TrackersViewController {
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        var newCategories = categories
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let existingCategory = categories[categoryIndex]
            let newTrackers = existingCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: newTrackers)
            newCategories[categoryIndex] = updatedCategory
            print("Добавлен трекер \(tracker.title) в категорию \(categoryTitle)")
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
            print("Создана новая категория \(categoryTitle) с трекером \(tracker.title)")
        }
        categories = newCategories
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard indexPath.section < filteredCategories.count else {
            print("Ошибка: индекс секции \(indexPath.section) выходит за пределы \(filteredCategories.count)")
            return
        }
        
        let filteredCategory = filteredCategories[indexPath.section]
        guard indexPath.item < filteredCategory.trackers.count else {
            print("Ошибка: индекс трекера \(indexPath.item) выходит за пределы \(filteredCategory.trackers.count)")
            return
        }
        
        let trackerToDelete = filteredCategory.trackers[indexPath.item]
        guard let categoryIndex = categories.firstIndex(where: { $0.title == filteredCategory.title }) else {
            print("Ошибка: категория не найдена \(filteredCategory.title)")
            return
        }
        
        do {
            try trackerStore.deleteTracker(id: trackerToDelete.id)
            if let categoryIndex = categories.firstIndex(where: { $0.title == filteredCategory.title }) {
                var updatedTrackers = categories[categoryIndex].trackers
                if let trackerIndex = updatedTrackers.firstIndex(where: { $0.id == trackerToDelete.id }) {
                    updatedTrackers.remove(at: trackerIndex)
                    completedTrackers = completedTrackers.filter { $0.id != trackerToDelete.id }
                    
                    if updatedTrackers.isEmpty {
                        categories.remove(at: categoryIndex)
                    } else {
                        categories[categoryIndex] = TrackerCategory(title: filteredCategory.title, trackers: updatedTrackers)
                    }
                    
                    filteredCategories = filterTrackersByDate(currentDate)
                    print("Трекер успешно удален: \(trackerToDelete.title)")
                    collectionView.reloadData()
                    updatePlaceholderVisibility()
                }
            }
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }
}

extension TrackersViewController: CategoryListControllerDelegate {
    func didSelectCategory(_ category: String) {
        if !categories.contains(where: { $0.title == category }) {
            createCategory(withTitle: category)
        }
    }
    
    func didUpdateCategories(_ categories: [String]) {
        collectionView.reloadData()
        print("Обновлены категории: \(categories)")
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText.lowercased()
        
        if searchText.isEmpty {
            filteredCategories = filterTrackersByDate(currentDate)
        } else {
            let dateFiltered = filterTrackersByDate(currentDate)
            filteredCategories = dateFiltered.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(self.searchText)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
        print("Поиск по запросу: \(searchText)")
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        print("Начат ввод поискового запроса")
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchText = ""
        filteredCategories = filterTrackersByDate(currentDate)
        updatePlaceholderVisibility()
        collectionView.reloadData()
        print("Поиск отменен")
    }
}
