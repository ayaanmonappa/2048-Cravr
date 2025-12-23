import SwiftUI

struct GridView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let spacing: CGFloat = BlockBlastConstants.gridSpacing
            let tileSize = (w - (spacing * 5)) / 4
            
            ZStack(alignment: .topLeading) {
                // Background Board (Empty Cells)
                RoundedRectangle(cornerRadius: BlockBlastConstants.gridCornerRadius)
                    .fill(BlockBlastConstants.gridBackground)
                
                VStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: spacing) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: tileSize * BlockBlastConstants.cornerRadiusRatio)
                                    .fill(BlockBlastConstants.emptyCell)
                                    .frame(width: tileSize, height: tileSize)
                            }
                        }
                    }
                }
                .padding(spacing)
                
                // Merging/Ghost Tiles Layer (Behind Active)
                ForEach(game.mergingTiles, id: \.tile.id) { item in
                     TileView(value: item.tile.value, waveTrigger: 0, index: -1, isIdle: game.isIdle) // No wave for ghosts
                        .frame(width: tileSize, height: tileSize)
                        .position(
                            x: spacing + CGFloat(item.col) * (tileSize + spacing) + tileSize / 2,
                            y: spacing + CGFloat(item.row) * (tileSize + spacing) + tileSize / 2
                        )
                        .transition(.identity) // Smooth overlap
                        .zIndex(-1)
                }

                // Active Tiles Layer
                ForEach(flattenedTiles(), id: \.tile.id) { item in
                    TileView(value: item.tile.value, waveTrigger: game.unlockTrigger, index: item.row * 4 + item.col, isIdle: game.isIdle)
                        .frame(width: tileSize, height: tileSize)
                        // Use position instead of offset for stable transitions
                        .position(
                            x: spacing + CGFloat(item.col) * (tileSize + spacing) + tileSize / 2,
                            y: spacing + CGFloat(item.row) * (tileSize + spacing) + tileSize / 2
                        )
                    
                        
                        
                        
                        .transition(.scale(scale: 0.8).animation(.easeOut(duration: 0.1)))
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
