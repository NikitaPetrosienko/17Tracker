
import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private var isInitialized = false
    
    private init() {
        
    }
    
    func initialize(withApiKey apiKey: String) {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey) else {
//            print("\(#file):\(#line)] \(#function) Ошибка: не удалось создать конфигурацию YandexMetrica")
            return
        }
        configuration.logs = true
        configuration.sessionTimeout = 10
        YMMYandexMetrica.activate(with: configuration)
        isInitialized = true
        
//        print("\(#file):\(#line)] \(#function) YandexMetrica успешно инициализирована")
    }

    func trackEvent(_ name: String, parameters: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(name, parameters: parameters) { error in
//            print("\(#file):\(#line)] \(#function) Событие '\(name)' добавлено в очередь")
//            print("\(#file):\(#line)] \(#function) Параметры: \(parameters)")
            
            YMMYandexMetrica.sendEventsBuffer()
        }
    }
}
