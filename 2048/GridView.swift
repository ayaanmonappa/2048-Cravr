import SwiftUI

struct GridView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let spacing: CGFloat = 12
            let tileSize = (w - (spacing * 5)) / 4
            
            ZStack(alignment: .topLeading) {
                // Background Board (Empty Cells)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "BBADA0"))
                
                VStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: spacing) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "CDC1B4"))
                                    .frame(width: tileSize, height: tileSize)
                            }
                        }
                    }
                }
                .padding(spacing)
                
                // Active Tiles Layer
                ForEach(flattenedTiles(), id: \.tile.id) { item in
                    TileView(value: item.tile.value)
                        .frame(width: tileSize, height: tileSize)
                        // Use offset instead of position to keep the frame local for transition
                        .offset(
                            x: spacing + CGFloat(item.col) * (tileSize + spacing),
                            y: spacing + CGFloat(item.row) * (tileSize + spacing)
                        )
                        // Transition applies to the view before offset visually moves it? 
                        // Actually with offset, the view is technically at top-leading. 
                        // The scale transition defaults to center of the view frame.
                        // So scaling happens at (tileSize/2, tileSize/2) of the un-offset view?
                        // No, modifier order matters.
                        // If transition is attached to the view, it animates the view's appearance.
                        // If that view is offset, the animation happens at the offset location.
                        .transition(.scale)
                        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3), value: item.col)
                        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3), value: item.row)
                        .animation(.easeOut(duration: 0.15), value: item.tile.value)
                        .zIndex(item.tile.lastMerged ? 1 : 0) // Ensure merged tiles stay on top during animation if needed
                }
            }
            .frame(width: w, height: w) // Explicitly size the ZStack
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    // Helper to flatten grid for structural identity
    private func flattenedTiles() -> [(tile: Tile, row: Int, col: Int)] {
        var tiles: [(Tile, Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if let tile = game.grid[r][c] {
                    tiles.append((tile, r, c))
                }
            }
        }
        return tiles
    }
}
