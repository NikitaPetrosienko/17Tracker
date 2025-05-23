
import UIKit

final class FilterListController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: FilterListViewModelProtocol
    private let filterView = FilterListView()
    weak var delegate: FilterListControllerDelegate?
    
    // MARK: - Init
    
    init(viewModel: FilterListViewModelProtocol = FilterListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        print("\(#file):\(#line)] \(#function) Ошибка: init(coder:) не реализован")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.tableView.delegate = self
        filterView.tableView.dataSource = self
        
        view.addSubview(filterView)
        
        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: view.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filterView.tableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.filters.count * 75))
        ])
    }
}

// MARK: - UITableViewDelegate & DataSource

extension FilterListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as? CategoryCell else {
            print("\(#file):\(#line)] \(#function) Ошибка приведения типа ячейки")
            return UITableViewCell()
        }
        
        let filter = viewModel.filters[indexPath.row]
        cell.textLabel?.text = filter.rawValue
        cell.backgroundColor = UIColor(named: "backgroundGray")
        cell.selectionStyle = .none
        
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .systemBlue
        checkmark.isHidden = filter != viewModel.selectedFilter 
        cell.accessoryView = checkmark
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.filters.count - 1
        
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
        let selectedFilter = viewModel.filters[indexPath.row]
        viewModel.selectFilter(selectedFilter)
        delegate?.didSelectFilter(selectedFilter)
        tableView.reloadData()
        dismiss(animated: true)
    }
}
