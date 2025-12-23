import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

struct StarBackground: View {
    var isIdle: Bool = false // Passed from GameModel
    
    @State private var pulseEffect: Bool = false
    @State private var stars: [Star] = (0..<50).map { _ in
        Star(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 1...3),
            opacity: Double.random(in: 0.3...0.8)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Gradient/Color
                LinearGradient(
                    gradient: Gradient(colors: [BlockBlastConstants.cravrDarkSurface, .black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Stars
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x * geometry.size.width, y: star.y * geometry.size.height)
                        .opacity(star.opacity)
                }
            }
            .opacity(pulseEffect ? 0.5 : 1.0) // More intense fade
            .scaleEffect(pulseEffect ? 1.05 : 1.0) // Stronger breathing
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isIdle) { idle in
            if idle {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseEffect = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    pulseEffect = false
                }
            }
        }
    }
}

#Preview {
    StarBackground()
}
