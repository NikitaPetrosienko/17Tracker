
import UIKit

final class NewIrregularEventController: UIViewController {
    
    // MARK: - Properties
    
    private var selectedCategory: String?
    private var isFormValid: Bool = false
    weak var delegate: NewHabitControllerDelegate?
    private let emojis = EmojiStorage()
    private let colors = ColorsStorage()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: "backgroundGray")
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.tintColor = .black
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        let chevronImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        button.setImage(chevronImage, for: .normal)
        button.tintColor = .gray
        button.backgroundColor = UIColor(named: "backgroundGray")
        button.layer.cornerRadius = 16
        button.titleLabel?.numberOfLines = 0
        return button
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerEmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        return collectionView
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
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        nameTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [categoryButton].forEach { button in
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: button.bounds.width - 40, bottom: 0, right: 16)
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(categoryButton)
        scrollView.addSubview(emojiLabel)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorLabel)
        scrollView.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            categoryButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            emojiLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateCreateButtonState() {
        guard let text = nameTextField.text else {
            createButton.backgroundColor = UIColor(named: "backgroundButtonColor")
            createButton.isEnabled = false
            print("\(#file):\(#line)] \(#function) TextField.text == nil")
            return
        }
        
        let hasText = !text.isEmpty
        let hasCategory = selectedCategory != nil
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        
        isFormValid = hasText && hasCategory && hasEmoji && hasColor
        
        if isFormValid {
            createButton.backgroundColor = .blackYPBlack
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(named: "backgroundButtonColor")
            createButton.isEnabled = false
        }
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
        
        guard let category = selectedCategory else {
            print("\(#file):\(#line)] \(#function) Ошибка: не выбрана категория")
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
        
        let currentDate = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let currentWeekDay = WeekDay(rawValue: weekday == 1 ? 7 : weekday - 1) ?? .monday
        
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: [currentWeekDay],
            isPinned: false,
            creationDate: Date(),
            originalCategory: category
        )
        
        let trackerCategory = TrackerCategory(title: category, trackers: [newTracker])
        let trackerStore: TrackerStoreProtocol = TrackerStore.shared
        
        do {
            try trackerStore.createTracker(newTracker, category: trackerCategory)
            let trackerCount = trackerStore.countTrackers()
            delegate?.didCreateTracker(newTracker, category: category)
            dismiss(animated: true)
        } catch {
            print("\(#file):\(#line)] \(#function) Ошибка сохранения трекера: \(error)")
        }
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

// MARK: - UICollectionViewDelegate & DataSource

extension NewIrregularEventController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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

extension NewIrregularEventController: CategoryListControllerDelegate {
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
        print("\(#file):\(#line)] \(#function) Обновлены категории: \(categories)")
    }
}

// MARK: - UITextFieldDelegate

extension NewIrregularEventController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
