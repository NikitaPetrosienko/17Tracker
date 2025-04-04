
import UIKit

final class NewScheduleController: UIViewController {
    
    // MARK: - Properties
    
    private var selectedWeekDays: Set<WeekDay> = []
    weak var delegate: NewScheduleControllerDelegate?
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = UIColor(named: "backgroundGray")
        stack.layer.cornerRadius = 16
        stack.clipsToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupWeekDaysControls()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    init(selectedWeekDays: Set<WeekDay> = []) {
        self.selectedWeekDays = selectedWeekDays
        super.init(nibName: nil, bundle: nil)
        print("\(#file):\(#line)] \(#function) Инициализирован с днями: \(selectedWeekDays)")
    }
    
    required init?(coder: NSCoder) {
        print("\(#file):\(#line)] \(#function) Ошибка: init(coder:) не реализован")
        return nil
    }
    
    private func setupWeekDaysControls() {
        WeekDay.allCases.forEach { day in
            let containerView = createWeekDayControl(for: day)
            stackView.addArrangedSubview(containerView)
            
            if let toggle = containerView.subviews.compactMap({ $0 as? UISwitch }).first {
                toggle.isOn = selectedWeekDays.contains(day)
            }
            
            NSLayoutConstraint.activate([
                containerView.heightAnchor.constraint(equalToConstant: 75)
            ])
        }
    }
    
    
    private func createWeekDayControl(for day: WeekDay) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(named: "backgroundGray")
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = day.shortName
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let toggle = UISwitch()
        toggle.onTintColor = .systemBlue
        toggle.tag = day.rawValue
        toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        let separator = UIView()
        separator.backgroundColor = .systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(toggle)
        container.addSubview(separator)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        if day == .sunday {
            separator.isHidden = true
        }
        return container
    }
    
    // MARK: - Actions
    
    @objc private func switchChanged(_ sender: UISwitch) {
        guard let day = WeekDay(rawValue: sender.tag) else { return }
        
        if sender.isOn {
            selectedWeekDays.insert(day)
        } else {
            selectedWeekDays.remove(day)
        }
        print("\(#file):\(#line)] \(#function) Выбранные дни: \(selectedWeekDays)")
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didUpdateSchedule(selectedWeekDays)
        print("\(#file):\(#line)] \(#function) Сохранено расписание: \(selectedWeekDays)")
        dismiss(animated: true)
    }
}
