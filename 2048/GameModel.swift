import SwiftUI
import Combine

struct Tile: Identifiable, Equatable {
    let id = UUID()
    var value: Int
    var lastMerged: Bool = false
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
    @Published var gameOver: Bool = false
    @Published var hasWon: Bool = false
    @Published var keepPlaying: Bool = false

    init() {
        bestScore = UserDefaults.standard.integer(forKey: "BestScore")
        resetGame()
    }

    func resetGame() {
        grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        score = 0
        // Don't reset bestScore
        
        gameOver = false
        hasWon = false
        keepPlaying = false
        addRandomTile()
        addRandomTile()
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
        
        let originalGrid = grid
        var moved = false
        
        switch direction {
        case .left:
            moved = moveLeft()
        case .right:
            moved = moveRight()
        case .up:
            moved = moveUp()
        case .down:
            moved = moveDown()
        }
        
        if moved {
            if !hasWon || keepPlaying {
                addRandomTile()
                checkGameOver()
            }
        }
    }
    
    // MARK: - Movement Logic
    
    // Helper to compress and merge a single row/column array
    private func processLine(_ line: [Tile?]) -> ([Tile?], Int) {
        var newLine = line.compactMap { $0 }
        var scoreAdd = 0
        
        if newLine.isEmpty {
            return (Array(repeating: nil, count: 4), 0)
        }
        
        var mergedLine: [Tile] = []
        var skip = false
        
        for i in 0..<newLine.count {
            if skip {
                skip = false
                continue
            }
            
            if i + 1 < newLine.count && newLine[i].value == newLine[i+1].value {
                let textVal = newLine[i].value * 2
                var mergedTile = newLine[i]
                mergedTile.value = textVal
                mergedTile.lastMerged = true
                mergedLine.append(mergedTile)
                scoreAdd += textVal
                if textVal == 2048 { self.hasWon = true }
                skip = true
            } else {
                var tile = newLine[i]
                tile.lastMerged = false
                mergedLine.append(tile)
            }
        }
        
        // Pad with nil
        let result: [Tile?] = mergedLine.map { Optional($0) } + Array(repeating: nil, count: 4 - mergedLine.count)
        return (result, scoreAdd)
    }
    
    private func moveLeft() -> Bool {
        var moved = false
        for r in 0..<4 {
            let (newLine, scoreAdd) = processLine(grid[r])
            if grid[r] != newLine {
                grid[r] = newLine
                moved = true
                score += scoreAdd
            }
        }
        return moved
    }
    
    private func moveRight() -> Bool {
        var moved = false
        for r in 0..<4 {
            let reversedParams = Array(grid[r].reversed())
            let (newLine, scoreAdd) = processLine(reversedParams)
            let resultLine = Array(newLine.reversed())
            if grid[r] != resultLine {
                grid[r] = resultLine
                moved = true
                score += scoreAdd
            }
        }
        return moved
    }
    
    private func moveUp() -> Bool {
        var moved = false
        for c in 0..<4 {
            var col: [Tile?] = []
            for r in 0..<4 { col.append(grid[r][c]) }
            
            let (newCol, scoreAdd) = processLine(col)
            
            for r in 0..<4 {
                if grid[r][c] != newCol[r] {
                    moved = true
                }
                grid[r][c] = newCol[r]
            }
            if scoreAdd > 0 { score += scoreAdd }
        }
        return moved
    }
    
    private func moveDown() -> Bool {
        var moved = false
        for c in 0..<4 {
            var col: [Tile?] = []
            for r in 0..<4 { col.append(grid[r][c]) }
            
            let reversedCol = Array(col.reversed())
            let (newCol, scoreAdd) = processLine(reversedCol)
            let resultCol = Array(newCol.reversed())
            
            for r in 0..<4 {
                if grid[r][c] != resultCol[r] {
                    moved = true
                }
                grid[r][c] = resultCol[r]
            }
            if scoreAdd > 0 { score += scoreAdd }
        }
        return moved
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
