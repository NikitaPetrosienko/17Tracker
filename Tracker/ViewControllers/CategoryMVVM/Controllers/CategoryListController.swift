
import UIKit

final class CategoryListController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: CategoryListViewModel
    weak var delegate: CategoryListControllerDelegate?
    
    // MARK: - UI Elements
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackerPlaceholder")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: "backgroundGray")
        table.separatorStyle = .none
        table.layer.cornerRadius = 16
        table.clipsToBounds = true
        table.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = true
        return table
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        print("\(#file):\(#line)] \(#function) Инициализирован с ViewModel")
    }
    
    required init?(coder: NSCoder) {
        print("\(#file):\(#line)] \(#function) Ошибка: init(coder:) не реализован")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupNavigationBar()
        setupViews()
        viewModel.loadCategories()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            print("\(#file):\(#line)] \(#function) Получена ошибка: \(error)")
        }
        
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            self?.placeholderImageView.isHidden = !isEmpty
            self?.placeholderLabel.isHidden = !isEmpty
            self?.tableView.isHidden = isEmpty
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)
        view.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Категория"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        navigationItem.titleView = titleLabel
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryViewModel = NewCategoryViewModel()
        let categoryNameController = NewCategoryController(viewModel: newCategoryViewModel)
        categoryNameController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: categoryNameController)
        navigationController.modalPresentationStyle = .automatic
        print("\(#file):\(#line)] \(#function) Переход к экрану создания новой категории")
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CategoryListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoriesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
              print("\(#file):\(#line)] \(#function) Ошибка приведения типа ячейки")
              return UITableViewCell()
          }
          
          let category = viewModel.category(at: indexPath.row)
          cell.isSeparatorHidden = indexPath.row == viewModel.categoriesCount - 1
          
        
        cell.contentView.subviews.forEach { view in
            if view.tag == 100 {
                view.removeFromSuperview()
            }
        }
        
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.preservesSuperviewLayoutMargins = false
        
        cell.textLabel?.text = category.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = UIColor(named: "backgroundGray")
        cell.selectionStyle = .none
        
        if indexPath.row < viewModel.categoriesCount - 1  {
            let separatorView = UIView()
            separatorView.backgroundColor = .systemGray4
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.tag = 100
            cell.contentView.addSubview(separatorView)
            
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                separatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .systemBlue
        checkmark.isHidden = !category.isSelected
        cell.accessoryView = checkmark
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.categoriesCount - 1
        
        let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                    byRoundingCorners: [
                                        isFirstCell ? .topLeft : [],
                                        isFirstCell ? .topRight : [],
                                        isLastCell ? .bottomLeft : [],
                                        isLastCell ? .bottomRight : []
                                    ],
                                    cornerRadii: CGSize(width: 16, height: 16))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        cell.layer.mask = shape
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row)
        viewModel.selectCategory(category.title)
        delegate?.didSelectCategory(category.title)
        delegate?.didUpdateCategories(viewModel.allCategoryTitles)
        dismissAll()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.category(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                guard let self = self else { return }
                let editController = EditCategoryController(viewModel: self.viewModel, categoryTitle: category.title)
                editController.delegate = self.delegate
                let navigationController = UINavigationController(rootViewController: editController)
                navigationController.modalPresentationStyle = .automatic
                self.present(navigationController, animated: true)
                print("\(#file):\(#line)] \(#function) Открыт экран редактирования категории: \(category.title)")
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                let alert = UIAlertController(
                    title: nil,
                    message: "Уверены что хотите удалить категорию «\(category.title)»?",
                    preferredStyle: .actionSheet
                )
                
                alert.addAction(UIAlertAction(
                    title: "Удалить",
                    style: .destructive) { [weak self] _ in
                        self?.viewModel.deleteCategory(title: category.title)
                        print("\(#file):\(#line)] \(#function) Удалена категория: \(category.title)")
                    })
                
                alert.addAction(UIAlertAction(
                    title: "Отменить",
                    style: .cancel
                ))
                
                self?.present(alert, animated: true)
            }
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    private func dismissAll() {
        guard let presentingVC = presentingViewController as? UINavigationController,
              let newHabitVC = presentingVC.viewControllers.first else {
            dismiss(animated: true)
            return
        }
        presentingVC.dismiss(animated: true)
    }
}
