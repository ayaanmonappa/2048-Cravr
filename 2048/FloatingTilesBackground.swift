import SwiftUI

struct FloatingTilesBackground: View {
    @State private var tiles: [FloatingSpaceshipTile] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(tiles) { tile in
                    FloatingSpaceshipTileView(tile: tile, size: geometry.size)
                }
            }
            .onAppear {
                // Create random tiles
                tiles = (0..<15).map { _ in
                    FloatingSpaceshipTile(
                        value: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048].randomElement()!,
                        x: CGFloat.random(in: 0...1),
                        y: CGFloat.random(in: 0...1),
                        rotation: Double.random(in: 0...360),
                        size: CGFloat.random(in: 40...80),
                        speed: Double.random(in: 15...35)
                    )
                }
            }
        }
    }
}

struct FloatingSpaceshipTile: Identifiable {
    let id = UUID()
    let value: Int
    var x: CGFloat // 0 to 1
    var y: CGFloat // 0 to 1
    var rotation: Double
    let size: CGFloat
    let speed: Double // seconds for one full cycle
}

struct FloatingSpaceshipTileView: View {
    let tile: FloatingSpaceshipTile
    let size: CGSize
    
    @State private var animatedX: CGFloat = 0
    @State private var animatedY: CGFloat = 0
    @State private var animatedRotation: Double = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(BlockBlastConstants.tileColor(for: tile.value))
            .frame(width: tile.size, height: tile.size)
            .overlay(
                // Number Text
                Text("\(tile.value)")
                    .font(AppFont.rounded(fontSize(for: tile.value), weight: .black))
                    .foregroundColor(.white)
            )
            .overlay(
                // Gloss Effect
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(3)
            )
            .shadow(
                color: BlockBlastConstants.tileColor(for: tile.value).opacity(0.4),
                radius: 8,
                x: 0,
                y: 0
            )
            .opacity(opacity)
            .rotationEffect(.degrees(animatedRotation))
            .position(
                x: animatedX * size.width,
                y: animatedY * size.height
            )
            .onAppear {
                // Set initial position
                animatedX = tile.x
                animatedY = tile.y
                animatedRotation = tile.rotation
                
                // Animate in a random path
                startFloatingAnimation()
            }
    }
    
    private func startFloatingAnimation() {
        // Create random waypoints for a smooth floating path
        let waypoint1X = CGFloat.random(in: 0...1)
        let waypoint1Y = CGFloat.random(in: 0...1)
        let waypoint2X = CGFloat.random(in: 0...1)
        let waypoint2Y = CGFloat.random(in: 0...1)
        let waypoint3X = CGFloat.random(in: 0...1)
        let waypoint3Y = CGFloat.random(in: 0...1)
        
        let rotationOffset = Double.random(in: 360...720)
        
        // Animate through waypoints in a loop
        withAnimation(.linear(duration: tile.speed / 4).delay(0)) {
            animatedX = waypoint1X
            animatedY = waypoint1Y
            animatedRotation = tile.rotation + rotationOffset / 4
            opacity = Double.random(in: 0.2...0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + tile.speed / 4) {
            withAnimation(.linear(duration: tile.speed / 4)) {
                animatedX = waypoint2X
                animatedY = waypoint2Y
                animatedRotation = tile.rotation + rotationOffset / 2
                opacity = Double.random(in: 0.2...0.5)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + tile.speed / 2) {
            withAnimation(.linear(duration: tile.speed / 4)) {
                animatedX = waypoint3X
                animatedY = waypoint3Y
                animatedRotation = tile.rotation + (rotationOffset * 3 / 4)
                opacity = Double.random(in: 0.2...0.5)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (tile.speed * 3 / 4)) {
            withAnimation(.linear(duration: tile.speed / 4)) {
                animatedX = tile.x
                animatedY = tile.y
                animatedRotation = tile.rotation + rotationOffset
                opacity = Double.random(in: 0.2...0.5)
            }
        }
        
        // Loop the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + tile.speed) {
            startFloatingAnimation()
        }
    }
    
    private func fontSize(for value: Int) -> CGFloat {
        switch value {
        case 0...99: return tile.size * 0.4
        case 100...999: return tile.size * 0.35
        case 1000...9999: return tile.size * 0.3
        default: return tile.size * 0.25
        }
    }
}

#Preview {
    ZStack {
        Color.black
        FloatingTilesBackground()
    }
}
