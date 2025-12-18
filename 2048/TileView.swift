import SwiftUI

struct TileView: View {
    let value: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColors.tileColor(for: value))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
            
            if value > 0 {
                Text("\(value)")
                    .font(AppFont.rounded(fontSize(for: value), weight: .bold))
                    .foregroundColor(AppColors.tileTextColor(for: value))
            }
        }
    }
    
    // Dynamic font size for larger numbers
    private func fontSize(for value: Int) -> CGFloat {
        switch value {
        case 0...99: return 32
        case 100...999: return 26
        case 1000...9999: return 20
        default: return 16
        }
    }
}

#Preview {
    HStack {
        TileView(value: 2).frame(width: 80, height: 80)
        TileView(value: 2048).frame(width: 80, height: 80)
    }
}
