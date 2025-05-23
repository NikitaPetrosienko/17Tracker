
import UIKit

final class NewHabitController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: NewHabitControllerDelegate?
    private var schedule: Set<WeekDay> = []
    private var selectedCategory: String?
    private var isFormValid: Bool = false
    private let emojis = EmojiStorage()
    private let colors = ColorsStorage()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let trackerStore: TrackerStoreProtocol = TrackerStore.shared
    private var editingTrackerId: UUID?
    private var completedDaysCount: Int = 0
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var numbersOfDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "5 дней"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: "backgroundGray")
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.tintColor = .black
        textField.textColor = .black
        return textField
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(
            string: "Категория",
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black])
        button.setAttributedTitle(attributedString, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        let chevronImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        button.setImage(chevronImage, for: .normal)
        button.backgroundColor = UIColor(named: "backgroundGray")
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.layer.cornerRadius = 16
        button.tintColor = .gray
        button.titleLabel?.numberOfLines = 0
        return button
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 0)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.titleLabel?.numberOfLines = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        let chevronImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        button.setImage(chevronImage, for: .normal)
        button.backgroundColor = UIColor(named: "backgroundGray")
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.layer.cornerRadius = 16
        button.tintColor = .gray
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "backgroundButtonColor")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerEmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "backgroundGray")
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private struct LayoutConstants {
        static let buttonSpacing: CGFloat = 56
        static let sideInset: CGFloat = 20
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        view.addGestureRecognizer(tapGesture)
        nameTextField.delegate = self
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        setupSubView()
        setupScrollView()
        setupButtons()
        setupChevron()
    }
    
    // MARK: - Private Func
    
    private func setupSubView() {
        view.addSubview(scrollView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        scrollView.addSubview(numbersOfDaysLabel)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(categoryButton)
        scrollView.addSubview(scheduleButton)
        scrollView.addSubview(separatorView)
        scrollView.addSubview(emojiLabel)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorLabel)
        scrollView.addSubview(colorCollectionView)
    }
    
    private func setupScrollView() {
        NSLayoutConstraint.activate([
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            numbersOfDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            numbersOfDaysLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(
                equalTo: numbersOfDaysLabel.isHidden ? titleLabel.bottomAnchor : numbersOfDaysLabel.bottomAnchor, constant: 24
                       ),
            
            nameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            categoryButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            
            emojiLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 0),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 0),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: (view.frame.width - LayoutConstants.buttonSpacing) / 2),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalToConstant: (view.frame.width - LayoutConstants.buttonSpacing) / 2),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupChevron() {
        let chevronImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        [categoryButton, scheduleButton].forEach { button in
            button.setImage(chevronImage, for: .normal)
            button.tintColor = .gray
            button.contentHorizontalAlignment = .left
            button.titleEdgeInsets = .zero
            button.imageView?.contentMode = .right
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: button.bounds.width - 40, bottom: 0, right: 16)
        }
    }
    
    private func updateCreateButtonState() {
        guard let text = nameTextField.text else {
            createButton.backgroundColor = UIColor(named: "backgroundButtonColor")
            createButton.isEnabled = false
            print("\(#file):\(#line)] \(#function) TextField.text == nil")
            return
        }
        let hasText = !text.isEmpty
        let hasSchedule = !schedule.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        
        isFormValid = hasText && hasSchedule && hasEmoji && hasColor
        
        if isFormValid {
            createButton.backgroundColor = .blackYPBlack
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(named: "backgroundButtonColor")
            createButton.isEnabled = false
        }
    }
    
    // MARK: - Public Methods

    func configurator(tracker: Tracker, categoryTitle: String) {
        numbersOfDaysLabel.isHidden = false
        titleLabel.text = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
        self.editingTrackerId = tracker.id
        self.nameTextField.text = tracker.title
        self.selectedCategory = categoryTitle
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.schedule = tracker.schedule
        self.createButton.setTitle("Сохранить", for: .normal)
        
           if let emojiIndex = emojis.emojis.firstIndex(of: tracker.emoji) {
               emojiCollectionView.selectItem(
                   at: IndexPath(item: emojiIndex, section: 0),
                   animated: false,
                   scrollPosition: []
               )
           }
        
           if let colorIndex = colors.colors.firstIndex(where: { $0.toHex() == tracker.color.toHex() }) {
               colorCollectionView.selectItem(
                   at: IndexPath(item: colorIndex, section: 0),
                   animated: false,
                   scrollPosition: []
               )
           }
        updateCreateButtonState()
        
        let title = "Категория\n"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ],
            range: NSRange(location: 0, length: title.count - 1)
        )
        let categoryString = NSAttributedString(
            string: categoryTitle,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor(named: "textGray") ?? .gray
            ]
        )
        attributedString.append(categoryString)
        categoryButton.setAttributedTitle(attributedString, for: .normal)
        
        let weekDays = schedule.map { $0.shortForm }.joined(separator: ", ")
        let scheduleTitle = "Расписание\n"
        let scheduleAttributedString = NSMutableAttributedString(string: scheduleTitle)
        scheduleAttributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ],
            range: NSRange(location: 0, length: scheduleTitle.count - 1)
        )
        let daysString = NSAttributedString(
            string: weekDays,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor(named: "textGray") ?? .gray
            ]
        )
        scheduleAttributedString.append(daysString)
        scheduleButton.setAttributedTitle(scheduleAttributedString, for: .normal)
        
        print("\(#file):\(#line)] \(#function) Контроллер сконфигурирован для редактирования трекера: \(tracker.title)")
    }
    
    private func formatDaysCount(_ count: Int) -> String {
        let format = NSLocalizedString("dayCount",
                                     tableName: "LocalizableDays",
                                     comment: "Number of days")
        return String.localizedStringWithFormat(format, count)
    }
    
    func setCompletedDaysCount(_ count: Int) {
        self.completedDaysCount = count
        let formattedText = formatDaysCount(count)
        numbersOfDaysLabel.text = formattedText
        numbersOfDaysLabel.isHidden = false
        print("\(#file):\(#line)] \(#function) Установлено количество дней: \(count)")
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = nameTextField.text, !title.isEmpty else {
            print("\(#file):\(#line)] \(#function) Ошибка: пустое название трекера")
            return
        }
        
        guard !schedule.isEmpty else {
            print("\(#file):\(#line)] \(#function) Ошибка: не выбраны дни недели")
            return
        }
        
        guard let emoji = selectedEmoji else {
            print("\(#file):\(#line)] \(#function) Ошибка: не выбран эмодзи")
            return
        }
        
        guard let color = selectedColor else {
            print("\(#file):\(#line)] \(#function) Ошибка: не выбран цвет")
            return
        }
        
        let categoryTitle = selectedCategory ?? "Важное"
        
        if let editingId = editingTrackerId {
            let updatedTracker = Tracker(
                id: editingId,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isPinned: false,
                creationDate: nil,
                originalCategory: categoryTitle
            )
            
            do {
                try trackerStore.updateTracker(updatedTracker)
                print("\(#file):\(#line)] \(#function) Трекер обновлен: \(title)")
                delegate?.didUpdateTracker(updatedTracker, category: categoryTitle)
                dismiss(animated: true)
            } catch {
                print("\(#file):\(#line)] \(#function) Ошибка обновления трекера: \(error)")
            }
        } else {
            let newTracker = Tracker(
                id: UUID(),
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isPinned: false,
                creationDate: nil,
                originalCategory: categoryTitle
            )
            
            let trackerCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [newTracker]
            )
            
            do {
                try trackerStore.createTracker(newTracker, category: trackerCategory)
                print("\(#file):\(#line)] \(#function) Трекер создан: \(title)")
                delegate?.didCreateTracker(newTracker, category: categoryTitle)
                dismiss(animated: true)
            } catch {
                print("\(#file):\(#line)] \(#function) Ошибка создания трекера: \(error)")
            }
        }
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleController = NewScheduleController(selectedWeekDays: schedule)
        scheduleController.delegate = self
        print("\(#file):\(#line)] \(#function) Открываем расписание с выбранными днями: \(schedule)")
        present(scheduleController, animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func categoryButtonTapped() {
        let viewModel = CategoryListViewModel(selectedCategory: selectedCategory)
        let categoryListController = CategoryListController(viewModel: viewModel)
        categoryListController.delegate = self
        let navigationController = UINavigationController(rootViewController: categoryListController)
        navigationController.modalPresentationStyle = .automatic
        print("\(#file):\(#line)] \(#function) Переход к выбору категории")
        present(navigationController, animated: true)
    }
}

// MARK: - NewScheduleControllerDelegate

extension NewHabitController: NewScheduleControllerDelegate {
    func didUpdateSchedule(_ schedule: Set<WeekDay>) {
        self.schedule = schedule
        print("\(#file):\(#line)] \(#function) Получено расписание: \(schedule)")
        
        let title = "Расписание\n"
        let weekDays = schedule.map { $0.shortForm }.joined(separator: ", ")
        
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ],
            range: NSRange(location: 0, length: title.count - 1)
        )
        
        if !schedule.isEmpty {
            let daysString = NSAttributedString(
                string: weekDays,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17),
                    .foregroundColor: UIColor(named: "textGray") ?? .gray
                ]
            )
            attributedString.append(daysString)
        }
        scheduleButton.setAttributedTitle(attributedString, for: .normal)
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension NewHabitController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.emojis.count
        } else {
            return colors.colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "EmojiCell",
                for: indexPath
            ) as? TrackerEmojiCell else {
                print("\(#file):\(#line)] \(#function) Ошибка приведения типа для EmojiCell")
                return UICollectionViewCell()
            }
            cell.configure(with: emojis.emojis[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ColorCell",
                for: indexPath
            ) as? TrackerColorCell else {
                print("\(#file):\(#line)] \(#function) Ошибка приведения типа для ColorCell")
                return UICollectionViewCell()
            }
            cell.configure(with: colors.colors[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis.emojis[indexPath.item]
            print("\(#file):\(#line)] \(#function) Выбран эмодзи: \(selectedEmoji ?? "")")
            
        } else if collectionView == colorCollectionView {
            selectedColor = colors.colors[indexPath.item]
            print("\(#file):\(#line)] \(#function) Выбран цвет: \(selectedColor?.description ?? "")")
        }
        updateCreateButtonState()
    }
}

// MARK: - Скрытие клаиватуры

extension NewHabitController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateCreateButtonState()
        print("\(#file):\(#line)] \(#function) Начато редактирование текста")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.async {
            self.updateCreateButtonState()
        }
        return true
    }
}

extension NewHabitController: CategoryListControllerDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        let title = "Категория\n"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ],
            range: NSRange(location: 0, length: title.count - 1)
        )
        let categoryString = NSAttributedString(
            string: category,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor(named: "textGray") ?? .gray
            ]
        )
        attributedString.append(categoryString)
        categoryButton.setAttributedTitle(attributedString, for: .normal)
        updateCreateButtonState()
        print("\(#file):\(#line)] \(#function) Выбрана категория: \(category)")
    }
    func didUpdateCategories(_ categories: [String]) {
        print("\(#file):\(#line)] \(#function) Получено обновление категорий: \(categories)")
    }
}
