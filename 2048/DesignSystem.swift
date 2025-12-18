import SwiftUI
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppColors {
    static let primaryGreen = Color(hex: "1C9D1F")
    static let darkGreenBg = Color(hex: "032205") // Guessing a dark green based on "StarBackground" context
    static let gradientStart = Color(hex: "FED544") // Yellowish
    static let gradientEnd = Color(hex: "00BC09")   // Greener
    
    // Tile Colors
    static func tileColor(for value: Int) -> Color {
        switch value {
        case 2: return Color(hex: "EEE4DA")
        case 4: return Color(hex: "EDE0C8")
        case 8: return Color(hex: "F2B179")
        case 16: return Color(hex: "F59563")
        case 32: return Color(hex: "F67C5F")
        case 64: return Color(hex: "F65E3B")
        case 128: return Color(hex: "EDCF72")
        case 256: return Color(hex: "EDCC61")
        case 512: return Color(hex: "EDC850")
        case 1024: return Color(hex: "EDC53F")
        case 2048: return Color(hex: "EDC22E")
        default: return Color(hex: "3C3A32")
        }
    }
    
    static func tileTextColor(for value: Int) -> Color {
        return value > 4 ? .white : Color(hex: "776E65")
    }
}

// Typography wrapper
struct AppFont {
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
}
