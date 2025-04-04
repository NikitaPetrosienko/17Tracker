
import UIKit

final class AppNavigationService {
    // MARK: - Singleton
    
    static let shared = AppNavigationService()
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "OnboardingCompleted"
    
    // MARK: - Init
    
    private init() {
        print("\(#file):\(#line)] \(#function) AppNavigationService инициализирован")
    }
    
    // MARK: - Public Methods
    
    func configureInitialViewController() -> UIViewController {
        let isOnboardingCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        print("\(#file):\(#line)] \(#function) Определение стартового экрана. Онбординг завершен: \(isOnboardingCompleted)")
        
        if isOnboardingCompleted {
            print("\(#file):\(#line)] \(#function) Возвращаем главный экран")
            return TabBarController()
        } else {
            print("\(#file):\(#line)] \(#function) Возвращаем экран онбординга")
            return OnboardingViewController()
        }
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: onboardingCompletedKey)
        print("\(#file):\(#line)] \(#function) Онбординг отмечен как завершенный")
    }
}
