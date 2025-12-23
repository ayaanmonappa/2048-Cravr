import SwiftUI
import Combine

struct Tile: Identifiable, Equatable {
    let id = UUID()
    var value: Int
    var lastMerged: Bool = false
}

struct FloatingTile: Identifiable {
    let id = UUID()
    let tile: Tile
    let row: Int
    let col: Int
}


enum Direction {
    case up, down, left, right
}

class GameModel: ObservableObject {
    @Published var grid: [[Tile?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)
    @Published var score: Int = 0 {
        didSet {
            if score > bestScore {
                bestScore = score
                UserDefaults.standard.set(bestScore, forKey: "BestScore")
            }
        }
    }
    @Published var bestScore: Int = 0
    @Published var gameOver: Bool = false {
        didSet {
            if gameOver { AudioHapticsManager.shared.playGameOver() }
        }
    }
    @Published var hasWon: Bool = false {
        didSet {
            if hasWon && !oldValue { AudioHapticsManager.shared.playWin() }
        }
    }
    @Published var keepPlaying: Bool = false
    
    // Feature: Visual Effects Trigger
    @Published var unlockTrigger: Int = 0
    @Published var mergingTiles: [FloatingTile] = []
    @Published var isIdle: Bool = false
    
    private var sessionMaxTile: Int = 0
    private var idleTimer: Timer?

    init() {
        bestScore = UserDefaults.standard.integer(forKey: "BestScore")
        resetGame()
        AudioHapticsManager.shared.playBackgroundMusic()
    }

    func resetGame() {
        resetIdleTimer()
        grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        score = 0
        // Don't reset bestScore
        
        gameOver = false
        hasWon = false
        keepPlaying = false
        sessionMaxTile = 0 // Reset for new game
        addRandomTile()
        addRandomTile()
        
        // Initialize sessionMax
        updateSessionMax()
    }
    
    func resetIdleTimer() {
        idleTimer?.invalidate()
        isIdle = false
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            withAnimation(.easeInOut(duration: 0.5)) { // Faster trigger animation too
                self?.isIdle = true
            }
        }
    }
    
    private func updateSessionMax() {
        var maxVal = 0
        for r in 0..<4 {
            for c in 0..<4 {
                if let val = grid[r][c]?.value {
                    maxVal = max(maxVal, val)
                }
            }
        }
        sessionMaxTile = maxVal
    }

    func debugSetup() {
        // Clear grid
        grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        
        // Fill with a pattern that is nearly game over
        // Rows with no merges possible horizontally
        let values: [Int] = [
            2, 4, 8, 16,
            32, 64, 128, 256,
            512, 1024, 2, 4,
            8, 16, 32 // Last one empty
        ]
        
        var vIndex = 0
        for r in 0..<4 {
            for c in 0..<4 {
                if r == 3 && c == 3 { continue } // Leave last spot empty
                grid[r][c] = Tile(value: values[vIndex])
                vIndex += 1
            }
        }
        
        score = 9999
        gameOver = false
        hasWon = false
        updateSessionMax()
        // No checkGameOver here, wait for one move
    }
    
    func debugWinSetup() {
        // Clear grid
        grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        
        // Place two 1024 tiles ready to merge
        grid[1][1] = Tile(value: 1024)
        grid[1][2] = Tile(value: 1024)
        
        score = 20000
        gameOver = false
        hasWon = false
        keepPlaying = false
        updateSessionMax()
    }

    func addRandomTile() {
        var emptyCells: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == nil {
                    emptyCells.append((r, c))
                }
            }
        }
        
        guard let randomCell = emptyCells.randomElement() else { return }
        let value = Int.random(in: 0..<10) < 9 ? 2 : 4
        grid[randomCell.0][randomCell.1] = Tile(value: value)
    }

    func move(_ direction: Direction) {
        guard !gameOver else { return }
        if hasWon && !keepPlaying { return }
        
        resetIdleTimer()
        
        let originalGrid = grid
        var moved = false
        var merged = false
        var maxMergedValue = 0
        
        switch direction {
        case .left:
            (moved, merged, maxMergedValue) = moveLeft()
        case .right:
            (moved, merged, maxMergedValue) = moveRight()
        case .up:
            (moved, merged, maxMergedValue) = moveUp()
        case .down:
            (moved, merged, maxMergedValue) = moveDown()
        }
        
        if moved {
            AudioHapticsManager.shared.playMove()
            if merged {
                AudioHapticsManager.shared.playMerge()
                if maxMergedValue > sessionMaxTile {
                    sessionMaxTile = maxMergedValue
                    unlockTrigger += 1
                    AudioHapticsManager.shared.playUnlock()
                }
            }
            
            if !hasWon || keepPlaying {
                addRandomTile()
                checkGameOver()
            }
        }
    }
    
    // MARK: - Movement Logic
    
    // Helper to compress and merge a single row/column array
    // Returns: (ResultLine, ScoreAdd, Merged, MaxVal, GhostMoves)
    // GhostMoves: (originalIndex, destIndex)
    private func processLine(_ line: [Tile?]) -> ([Tile?], Int, Bool, Int, [(Int, Int)]) {
        // 1. Compress (keep original indices)
        var compact: [(tile: Tile, originalIndex: Int)] = []
        for (i, t) in line.enumerated() {
            if let t = t { compact.append((t, i)) }
        }
        
        var scoreAdd = 0
        var merged = false
        var maxVal = 0
        var ghostMoves: [(Int, Int)] = []
        
        var mergedLine: [Tile] = []
        var skip = false
        
        for i in 0..<compact.count {
            if skip {
                skip = false
                continue
            }
            
            let current = compact[i]
            
            if i + 1 < compact.count && current.tile.value == compact[i+1].tile.value {
                let next = compact[i+1]
                let textVal = current.tile.value * 2
                var mergedTile = current.tile
                mergedTile.value = textVal
                mergedTile.lastMerged = true
                
                mergedLine.append(mergedTile)
                
                // Ghost Logic: The 'next' tile is consumed. It moves from next.originalIndex to mergedLine.count - 1
                ghostMoves.append((next.originalIndex, mergedLine.count - 1))
                
                scoreAdd += textVal
                merged = true
                maxVal = max(maxVal, textVal)
                if textVal == 2048 { self.hasWon = true }
                skip = true
            } else {
                var tile = current.tile
                tile.lastMerged = false
                mergedLine.append(tile)
            }
        }
        
        // Pad with nil
        let result: [Tile?] = mergedLine.map { Optional($0) } + Array(repeating: nil, count: 4 - mergedLine.count)
        return (result, scoreAdd, merged, maxVal, ghostMoves)
    }
    
    private func moveLeft() -> (Bool, Bool, Int) {
        var moved = false
        var anyMerged = false
        var maxVal = 0
        var newGhosts: [FloatingTile] = []
        
        for r in 0..<4 {
            let (newLine, scoreAdd, merged, lineMax, ghosts) = processLine(grid[r])
            if grid[r] != newLine {
                grid[r] = newLine
                moved = true
                score += scoreAdd
                if merged { anyMerged = true }
                maxVal = max(maxVal, lineMax)
                
                // Map ghosts (r, c) -> (r, c)
                for (srcIdx, destIdx) in ghosts {
                    // We need the Tile from the original grid before overwrite?
                    // Actually, processLine is pure. grid[r] is still old here.
                    // Wait, grid[r] is [Tile?]. ghosts says index srcIdx in grid[r] was consumed.
                    if let tile = grid[r][srcIdx] {
                        newGhosts.append(FloatingTile(tile: tile, row: r, col: destIdx))
                    }
                }
            }
        }
        if !newGhosts.isEmpty {
            self.mergingTiles = newGhosts
            clearGhostsAfterDelay()
        }
        return (moved, anyMerged, maxVal)
    }
    
    private func moveRight() -> (Bool, Bool, Int) {
        var moved = false
        var anyMerged = false
        var maxVal = 0
        var newGhosts: [FloatingTile] = []
        
        for r in 0..<4 {
            let reversedParams = Array(grid[r].reversed())
            let (newLine, scoreAdd, merged, lineMax, ghosts) = processLine(reversedParams)
            let resultLine = Array(newLine.reversed())
            if grid[r] != resultLine {
                // Map ghosts
                for (srcIdx, destIdx) in ghosts {
                    // Reversed frame: index i corresponds to col (3 - i)
                    let srcCol = 3 - srcIdx
                    let destCol = 3 - destIdx
                    if let tile = grid[r][srcCol] {
                        newGhosts.append(FloatingTile(tile: tile, row: r, col: destCol))
                    }
                }
                
                grid[r] = resultLine
                moved = true
                score += scoreAdd
                if merged { anyMerged = true }
                maxVal = max(maxVal, lineMax)
            }
        }
        if !newGhosts.isEmpty {
            self.mergingTiles = newGhosts
            clearGhostsAfterDelay()
        }
        return (moved, anyMerged, maxVal)
    }
    
    private func moveUp() -> (Bool, Bool, Int) {
        var moved = false
        var anyMerged = false
        var maxVal = 0
        var newGhosts: [FloatingTile] = []
        
        for c in 0..<4 {
            var col: [Tile?] = []
            for r in 0..<4 { col.append(grid[r][c]) }
            
            let (newCol, scoreAdd, merged, lineMax, ghosts) = processLine(col)
            
            // Generate ghosts before modifying grid?
            // Yes, need to read old state.
            // But we check diff first.
            let hasChanged = (0..<4).contains { r in grid[r][c] != newCol[r] }
            
            if hasChanged {
                 for (srcIdx, destIdx) in ghosts {
                    // Up frame: index i corresponds to row i
                    let srcRow = srcIdx
                    let destRow = destIdx
                    if let tile = grid[srcRow][c] {
                        newGhosts.append(FloatingTile(tile: tile, row: destRow, col: c))
                    }
                }
                
                for r in 0..<4 {
                    if grid[r][c] != newCol[r] { moved = true }
                    grid[r][c] = newCol[r]
                }
                score += scoreAdd
                if merged { anyMerged = true }
                maxVal = max(maxVal, lineMax)
            }
        }
        if !newGhosts.isEmpty {
            self.mergingTiles = newGhosts
            clearGhostsAfterDelay()
        }
        return (moved, anyMerged, maxVal)
    }
    
    private func moveDown() -> (Bool, Bool, Int) {
        var moved = false
        var anyMerged = false
        var maxVal = 0
        var newGhosts: [FloatingTile] = []
        
        for c in 0..<4 {
            var col: [Tile?] = []
            for r in 0..<4 { col.append(grid[r][c]) }
            
            let reversedCol = Array(col.reversed())
            let (newCol, scoreAdd, merged, lineMax, ghosts) = processLine(reversedCol)
            let resultCol = Array(newCol.reversed())
            
            let hasChanged = (0..<4).contains { r in grid[r][c] != resultCol[r] }
            
            if hasChanged {
                 for (srcIdx, destIdx) in ghosts {
                    // Down frame: index i corresponds to row (3 - i)
                    let srcRow = 3 - srcIdx
                    let destRow = 3 - destIdx
                    if let tile = grid[srcRow][c] {
                        newGhosts.append(FloatingTile(tile: tile, row: destRow, col: c))
                    }
                }
                
                for r in 0..<4 {
                    if grid[r][c] != resultCol[r] { moved = true }
                    grid[r][c] = resultCol[r]
                }
                score += scoreAdd
                if merged { anyMerged = true }
                maxVal = max(maxVal, lineMax)
            }
        }
        if !newGhosts.isEmpty {
            self.mergingTiles = newGhosts
            clearGhostsAfterDelay()
        }
        return (moved, anyMerged, maxVal)
    }
    
    private func clearGhostsAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.mergingTiles = []
        }
    }
    
    func checkGameOver() {
        // Check for empty cells
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == nil { return }
            }
        }
        
        // Check for possible merges
        for r in 0..<4 {
            for c in 0..<4 {
                let val = grid[r][c]!.value
                // Check right
                if c < 3, let right = grid[r][c+1], right.value == val { return }
                // Check down
                if r < 3, let down = grid[r+1][c], down.value == val { return }
            }
        }
        
        gameOver = true
    }
}
