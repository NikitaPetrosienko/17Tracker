
import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static func decode(from encoded: Int64) -> Set<WeekDay> {
           var weekDays = Set<WeekDay>()
           for day in WeekDay.allCases {
               if (encoded & (1 << (day.rawValue - 1))) != 0 {
                   weekDays.insert(day)
               }
           }
           return weekDays
       }
    
    var shortName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
        
    }
    
    var shortForm: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
