import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

struct StarBackground: View {
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
                    gradient: Gradient(colors: [Color(hex: "053308"), Color(hex: "021C03")]),
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
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    StarBackground()
}
