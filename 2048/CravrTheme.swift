import SwiftUI

struct BlockBlastConstants {
    // Brand Colors (Exact Hex from Research)
    static let cravrGreen = Color(hex: "25E828") // Slightly brighter Green
    static let cravrBlue = Color(hex: "80F0FF")  // Brighter Blue
    static let cravrMaize = Color(hex: "F7EC59")
    static let cravrPumpkin = Color(hex: "FA7921")
    
    // Backgrounds
    static let cravrDarkSurface = Color(hex: "0D1F14") // Main Background
    static let gridBackground = Color(hex: "0F2417").opacity(0.9)
    static let emptyCell = Color(hex: "142E1C")
    
    // UI Constants
    static let gridSpacing: CGFloat = 3.0
    static let cornerRadiusRatio: CGFloat = 0.15 // 15% of size
    
    // Fallback fixed radius (used where size isn't dynamic)
    static let gridCornerRadius: CGFloat = 12
    static let cellCornerRadius: CGFloat = 10 
    
    // Block Colors for 2048 Tiles (Cycling vibrant palette)
    static let blockColors: [Color] = [
        cravrGreen,
        cravrBlue,
        cravrMaize,
        cravrPumpkin,
        cravrGreen.opacity(0.9),
        cravrBlue.opacity(0.9),
        cravrMaize.opacity(0.9),
        cravrPumpkin.opacity(0.9)
    ]
    
    static func tileColor(for value: Int) -> Color {
        // Map 2, 4, 8... to index 0, 1, 2...
        let index = Int(log2(Double(value))) - 1
        return blockColors[index % blockColors.count] // Cycle through
    }
}
