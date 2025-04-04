
import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    
    private var currentPage = 0
    private let numberOfPages = 2
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = .gray
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        print("\(#file):\(#line)] \(#function) Ошибка: init(coder:) не реализован")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageController()
        setupPageControl()
        print("\(#file):\(#line)] \(#function) Онбординг контроллер загружен")
    }
    
    // MARK: - Private Methods
    
    private func setupPageController() {
        dataSource = self
        delegate = self
        
        if let firstPage = createOnboardingPage(at: 0) {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createOnboardingPage(at index: Int) -> UIViewController? {
        switch index {
        case 0:
            return FirstOnboardingViewController()
        case 1:
            return SecondOnboardingViewController()
        default:
            print("\(#file):\(#line)] \(#function) Ошибка: некорректный индекс страницы: \(index)")
            return nil
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = getPageIndex(for: viewController) else {
            print("\(#file):\(#line)] \(#function) Ошибка определения текущей страницы")
            return nil
        }
        
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        return createOnboardingPage(at: previousIndex)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = getPageIndex(for: viewController) else {
            print("\(#file):\(#line)] \(#function) Ошибка определения текущей страницы")
            return nil
        }
        
        let nextIndex = currentIndex + 1
        guard nextIndex < numberOfPages else { return nil }
        
        return createOnboardingPage(at: nextIndex)
    }
    
    private func getPageIndex(for viewController: UIViewController) -> Int? {
        switch viewController {
        case is FirstOnboardingViewController:
            return 0
        case is SecondOnboardingViewController:
            return 1
        default:
            return nil
        }
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed,
           let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = getPageIndex(for: currentViewController) {
            pageControl.currentPage = currentIndex
            currentPage = currentIndex
        }
    }
}
