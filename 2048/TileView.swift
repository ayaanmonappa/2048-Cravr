import SwiftUI

struct TileView: View {
    let value: Int
    var waveTrigger: Int = 0
    var index: Int = 0
    var isIdle: Bool = false
    
    @State private var waveScale: CGFloat = 1.0
    @State private var popScale: CGFloat = 1.0
    @State private var flashOpacity: Double = 0.0
    
    // Idle Animation State
    @State private var idleScale: CGFloat = 1.0
    @State private var idleFlash: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            
            ZStack {
                // Main Block Background
                RoundedRectangle(cornerRadius: size * BlockBlastConstants.cornerRadiusRatio, style: .continuous)
                    .fill(AppColors.tileColor(for: value))
                    .shadow(
                        color: AppColors.tileColor(for: value).opacity(0.5),
                        radius: 4,
                        x: 0,
                        y: 0
                    )
                    // Glow Effect
                    .shadow(
                        color: AppColors.tileColor(for: value).opacity(0.8),
                        radius: 8,
                        x: 0,
                        y: 0
                    )
                
                // Gloss Effect
                if value > 0 {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(4)
                }
                
                // Number Text
                if value > 0 {
                    Text("\(value)")
                        .font(AppFont.rounded(fontSize(for: value), weight: .black))
                        .foregroundColor(AppColors.tileTextColor(for: value))
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                }
                
                // Flash Overlay
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .opacity(flashOpacity)
            }
            .scaleEffect(popScale * waveScale * idleScale)
            .onChange(of: value) { newValue in
                if newValue > 0 {
                    // Stop idle animation on interaction (implied by value change often, but mainly controlled by prop)
                    // Merge Pop Animation - Sharp & Precise
                    withAnimation(.easeOut(duration: 0.1)) {
                        popScale = 1.15
                        flashOpacity = 0.5
                    }
                    // Reset immediately after 100ms
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.1)) {
                            popScale = 1.0
                            flashOpacity = 0.0
                        }
                    }
                }
            }
            .onChange(of: waveTrigger) { _ in
                if waveTrigger > 0 {
                    // Calculate delay based on index (row-major)
                    // Diagonal wave: (row + col)
                    let row = index / 4
                    let col = index % 4
                    let delay = Double(row + col) * 0.05 // Even faster ripple (Immediate)
                    
                    // Exaggerated Wave Scale & Brightness
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(delay)) {
                        waveScale = 1.4 // Boom!
                        flashOpacity = 1.0 // Max Flash (used for brightness too)
                    }
                    
                    withAnimation(.easeOut(duration: 0.4).delay(delay + 0.3)) {
                        waveScale = 1.0
                        flashOpacity = 0.0
                    }
                }
            }
            .onChange(of: isIdle) { idle in
                if idle {
                     withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                         idleScale = 1.03
                         idleFlash = 0.15 // Subtle brightening
                     }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        idleScale = 1.0
                        idleFlash = 0.0
                    }
                }
            }
            .brightness(flashOpacity * 0.5 + idleFlash) // Flash makes it bright white-ish
        }
    }
    
    // Dynamic font size for larger numbers
    private func fontSize(for value: Int) -> CGFloat {
        switch value {
        case 0...9: return 42
        case 10...99: return 38
        case 100...999: return 30
        case 1000...9999: return 24
        default: return 20
        }
    }
}

#Preview {
    HStack {
        TileView(value: 2).frame(width: 80, height: 80)
        TileView(value: 2048).frame(width: 80, height: 80)
    }
}
