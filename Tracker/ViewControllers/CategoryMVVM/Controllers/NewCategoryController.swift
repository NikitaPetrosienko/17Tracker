
import UIKit

final class NewCategoryController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: NewCategoryViewModel
    weak var delegate: CategoryListControllerDelegate?
    private var categoryListController: CategoryListController?
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor(named: "backgroundGray")
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.tintColor = .black
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Init
    
    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        print("\(#file):\(#line)] \(#function) Инициализирован с ViewModel")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupViews()
        setupBindings()
        nameTextField.delegate = self
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        viewModel.onValidationChanged = { [weak self] isValid in
            self?.doneButton.isEnabled = isValid
            self?.doneButton.backgroundColor = isValid ? .black : .gray
        }
        
        viewModel.onCompletion = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let categoryTitle):
                self.delegate?.didSelectCategory(categoryTitle)
                self.delegate?.didUpdateCategories([categoryTitle])
                if let presentingVC = self.presentingViewController as? UINavigationController,
                   let rootVC = presentingVC.viewControllers.first {
                    presentingVC.dismiss(animated: true) {
                        rootVC.dismiss(animated: true)
                    }
                } else {
                    self.dismiss(animated: true)
                }
                print("\(#file):\(#line)] \(#function) Категория создана и экраны закрыты: \(categoryTitle)")
            case .failure(let error):
                print("\(#file):\(#line)] \(#function) Ошибка создания категории: \(error)")
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(nameTextField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        
        if nameTextField.text?.lowercased() == "закрепленные" {
               let alert = UIAlertController(
                   title: "Ошибка",
                   message: "Такое название категории использовать нельзя",
                   preferredStyle: .alert
               )
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
               print("\(#file):\(#line)] \(#function) Попытка создания запрещенной категории: \(nameTextField.text ?? "")")
               return
           }
           
           guard let title = nameTextField.text else { return }
           viewModel.createCategory(title: title)
       }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        print("\(#file):\(#line)] \(#function) Клавиатура скрыта")
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("\(#file):\(#line)] \(#function) Клавиатура скрыта по нажатию Return")
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.validateInput(textField.text)
    }
}
