
import UIKit

final class TabBarController: UITabBarController {
    
    let trackerNavigationController = TrackersViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            tabBar.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        }
    }
    
    func tabBarController() {
        
        let trackers = UINavigationController(rootViewController: trackerNavigationController)
        
        let trackerText: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        trackers.tabBarItem = UITabBarItem(
            title: Localization.trackersText,
            image: UIImage(named: "Trackers"),
            selectedImage: nil
        )
        trackers.tabBarItem.setTitleTextAttributes(trackerText as [NSAttributedString.Key : Any], for: .normal)
        
        let statisticVC = StatisticViewController()
        let statisticNavigationController = UINavigationController(rootViewController: statisticVC)
        
        statisticNavigationController.tabBarItem = UITabBarItem(
            title: Localization.statisticText,
            image: UIImage(named: "Statistic"),
            selectedImage: nil
        )
        statisticNavigationController.tabBarItem.setTitleTextAttributes(trackerText as [NSAttributedString.Key : Any], for: .normal)
        
        viewControllers = [trackers, statisticNavigationController]
        
        tabBar.tintColor = UIColor(named: "tabBarTintColor")
        tabBar.backgroundColor = UIColor(named: "background")
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor(named: "borderColor")?.cgColor
    }
}
