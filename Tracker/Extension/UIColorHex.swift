import UIKit

extension UIColor {
    // Преобразование UIColor в 8-символьный hex-код, включающий alpha
    func toHex(includeAlpha: Bool = true) -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        
        if includeAlpha {
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            let a = Int(alpha * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}

extension UIColor {
    // Инициализация цвета из hex-строки, поддерживает как 6, так и 8 символов
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        let length = hexSanitized.count
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            let red   = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue  = CGFloat(rgb & 0x0000FF) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        } else if length == 8 {
            let red   = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            let blue  = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            let alpha = CGFloat(rgb & 0x000000FF) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
}
