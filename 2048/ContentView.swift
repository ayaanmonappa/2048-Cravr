import SwiftUI

enum GameState {
    case menu
    case playing
}

struct ContentView: View {
    @StateObject private var game = GameModel()
    @State private var gameState: GameState = .menu
    
    var body: some View {
        ZStack {
            if gameState == .menu {
                OpeningView(startGame: {
                    withAnimation {
                        gameState = .playing
                        game.resetGame()
                    }
                }, bestScore: game.bestScore)
                .transition(.opacity)
            } else {
                gameView
            }
        }
        .animation(.default, value: gameState)
    }
    
    var gameView: some View {
        ZStack {
            // Background
            StarBackground()
            
            // Keyboard Shortcuts for testing
            Group {
                Button("") { withAnimation { game.move(.up) } }
                    .keyboardShortcut(.upArrow, modifiers: [])
                Button("") { withAnimation { game.move(.down) } }
                    .keyboardShortcut(.downArrow, modifiers: [])
                Button("") { withAnimation { game.move(.left) } }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                Button("") { withAnimation { game.move(.right) } }
                    .keyboardShortcut(.rightArrow, modifiers: [])
            }
            .opacity(0) // Hide the shortcuts buttons
            
            VStack {
                // Header
                NavigationHeader("2048") {
                    // Empty content for header extension or just spacer
                    EmptyView()
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Score Card
                        HStack {
                            CardView {
                                VStack {
                                    Text("SCORE")
                                        .font(AppFont.rounded(14, weight: .bold))
                                        .foregroundColor(Color.white.opacity(0.7))
                                    Text("\(game.score)")
                                        .font(AppFont.rounded(28, weight: .heavy))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 100)
                            
                            CardView {
                                VStack {
                                    Text("BEST")
                                        .font(AppFont.rounded(14, weight: .bold))
                                        .foregroundColor(Color.white.opacity(0.7))
                                    Text("\(game.bestScore)") // Placeholder for high score
                                        .font(AppFont.rounded(28, weight: .heavy))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 100)
                        }
                        .padding(.horizontal)
                        
                        // Game Board
                        GridView(game: game)
                            .padding(.horizontal)
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onEnded { value in
                                        let horizontal = value.translation.width
                                        let vertical = value.translation.height
                                        
                                        if abs(horizontal) > abs(vertical) {
                                            if horizontal < 0 {
                                                withAnimation { game.move(.left) }
                                            } else {
                                                withAnimation { game.move(.right) }
                                            }
                                        } else {
                                            if vertical < 0 {
                                                withAnimation { game.move(.up) }
                                            } else {
                                                withAnimation { game.move(.down) }
                                            }
                                        }
                                    }
                            )
                        
                        // Controls / New Game
                        Button(action: {
                            withAnimation {
                                game.resetGame()
                            }
                        }) {
                            Text("New Game")
                                .font(AppFont.rounded(18, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primaryGreen) // Use primary green
                                .cornerRadius(16)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        
                        // Debug Button
                        Button(action: {
                            withAnimation {
                                game.debugSetup()
                            }
                        }) {
                            Text("Debug: Near End Game")
                                .font(AppFont.rounded(14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                        
                        // Debug Button: Win
                        Button(action: {
                            withAnimation {
                                game.debugWinSetup()
                            }
                        }) {
                            Text("Debug: Near Win")
                                .font(AppFont.rounded(14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(8)
                        }
                        

                    }
                    .padding(.bottom, 20)
                }
            }
            
            // Overlays
            if game.gameOver {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack {
                        Text("Game Over!")
                            .font(AppFont.rounded(40, weight: .black))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 10)
                        
                        Button("Try Again") {
                            withAnimation { game.resetGame() }
                        }
                        .font(AppFont.rounded(20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(AppColors.primaryGreen)
                        .cornerRadius(10)
                        .padding(.top, 10)
                    }
                }
            }
            
            if game.hasWon && !game.keepPlaying {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text("You Win!")
                            .font(AppFont.rounded(40, weight: .black))
                            .foregroundColor(AppColors.primaryGreen)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 10)
                        
                        Button("New Game") {
                            withAnimation { game.resetGame() }
                        }
                        .font(AppFont.rounded(20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(AppColors.primaryGreen)
                        .cornerRadius(10)
                        
                        if !game.keepPlaying {
                            Button("Continue Playing") {
                                withAnimation {
                                    game.keepPlaying = true
                                    // Hide overlay is implicit because overlay shows if (hasWon && !keepPlaying) ?? 
                                    // Actually need to check ContentView condition for showing this overlay.
                                }
                            }
                            .font(AppFont.rounded(18, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 10)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
