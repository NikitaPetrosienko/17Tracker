
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let navigationService = AppNavigationService.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            print("\(#file):\(#line)] \(#function) Ошибка: не удалось получить windowScene")
            return
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationService.configureInitialViewController()
        window?.makeKeyAndVisible()
    }
}
