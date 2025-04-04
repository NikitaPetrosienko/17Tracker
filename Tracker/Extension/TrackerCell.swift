
import UIKit
import YandexMobileMetrica

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "TrackerCell"
    private var completedDaysCount: Int = 0
    private var currentDate: Date?
    private var tracker: Tracker?
    private var isCompleted: Bool = false
    private var completionHandler: (() -> Void)?
    
    // MARK: - UI Elements
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pinIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiView)
        emojiView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(completeButton)
        contentView.addSubview(counterLabel)
        cardView.addSubview(pinIcon)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            
            pinIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            pinIcon.widthAnchor.constraint(equalToConstant: 16),
            pinIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        guard let tracker = self.tracker,
              let currentDate = self.currentDate else { return }
        
        if isFutureDate(currentDate) {
            print("\(#file):\(#line)] \(#function) Нельзя отметить трекер на будущую дату")
            return
        }
        
        isCompleted.toggle()
        setCompletedState(isCompleted)
        completedDaysCount += isCompleted ? 1 : -1
        counterLabel.text = pluralizeDays(completedDaysCount)
        completionHandler?()
        
        AnalyticsService.shared.trackEvent("click", parameters: [
            "Screen": "Main",
            "Item": "track"
        ])
    }
    
    // MARK: - Private Methods
    
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: date)
        return selectedDate > today
    }
    
    // MARK: - Public Methods
    
    func setCompletedState(_ isCompleted: Bool) {
        if isCompleted {
            if let image = UIImage(named: "completedButtonCell") {
                completeButton.setImage(image, for: .normal)
            } else {
                print("\(#file):\(#line)] \(#function) Ошибка загрузки изображения completedButtonCell")
            }
        } else {
            if let image = UIImage(systemName: "plus") {
                completeButton.setImage(image, for: .normal)
            }
        }
        completeButton.alpha = isCompleted ? 0.3 : 1.0
    }
    
    func configureCompletionHandler(
        tracker: Tracker,
        isCompleted: Bool,
        completionHandler: @escaping () -> Void
    ) {
        self.tracker = tracker
        self.isCompleted = isCompleted
        self.completionHandler = completionHandler
        setCompletedState(isCompleted)
    }
    
    func configure(with tracker: Tracker, currentDate: Date, completedDaysCount: Int, isCompleted: Bool) {
        self.tracker = tracker
        self.currentDate = currentDate
        self.completedDaysCount = completedDaysCount
        self.isCompleted = isCompleted
        
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        completeButton.backgroundColor = tracker.color
        completeButton.layer.borderColor = tracker.color.cgColor
        completeButton.tintColor = .white
        counterLabel.text = pluralizeDays(completedDaysCount)
        setCompletedState(isCompleted)
        
        pinIcon.isHidden = !tracker.isPinned
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let format = NSLocalizedString("dayCount",
                                     tableName: "LocalizableDays",
                                     comment: "Number of days")
        return String.localizedStringWithFormat(format, count)
    }
}


