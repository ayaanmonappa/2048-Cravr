import SwiftUI

enum GameState {
    case menu
    case playing
}

struct ContentView: View {
    @StateObject private var game = GameModel()
    @State private var gameState: GameState = .menu
    @State private var showSettings: Bool = false
    
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
            
            // Settings Overlay
            if showSettings {
                SettingsView(isPresented: $showSettings)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.default, value: gameState)
        .animation(.easeInOut, value: showSettings)
    }
    
    var gameView: some View {
        ZStack {
            // Background
            StarBackground(isIdle: game.isIdle)
            
            // ... (Testing shortcuts hidden)
            
            VStack {
                // Header
                NavigationHeader("2048", onDismiss: {
                    withAnimation { gameState = .menu }
                }) {
                    Button(action: {
                        withAnimation { showSettings = true }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
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
                            .font(AppFont.rounded(22, weight: .bold)) // Increased size
                            .foregroundColor(.black) // Black text on bright button
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrGreen.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: BlockBlastConstants.cravrGreen.opacity(0.5), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding(.horizontal, 20)
                    
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
                    
                    Spacer() // Add spacer at bottom to push content up if needed
                }
                .padding(.bottom, 20)
            }
            
            // Overlays
            if game.gameOver {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 24) {
                        Text("GAME OVER")
                            .font(AppFont.rounded(40, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [BlockBlastConstants.cravrPumpkin, BlockBlastConstants.cravrMaize],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: BlockBlastConstants.cravrPumpkin.opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        VStack(spacing: 12) {
                            Text("SCORE")
                                .font(AppFont.rounded(14, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("\(game.score)")
                                .font(AppFont.rounded(52, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            withAnimation { game.resetGame() }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("PLAY AGAIN")
                            }
                            .font(AppFont.rounded(20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrGreen.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: BlockBlastConstants.cravrGreen.opacity(0.4), radius: 10, x: 0, y: 4)
                            )
                        }
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(BlockBlastConstants.cravrDarkSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(20)
                }
            }
            
            if game.hasWon && !game.keepPlaying {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 24) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(BlockBlastConstants.cravrMaize)
                            .shadow(color: BlockBlastConstants.cravrMaize.opacity(0.6), radius: 20)
                        
                        Text("YOU WIN!")
                            .font(AppFont.rounded(40, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [BlockBlastConstants.cravrMaize, BlockBlastConstants.cravrPumpkin],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Button(action: {
                            withAnimation { game.resetGame() }
                        }) {
                            Text("NEW GAME")
                                .font(AppFont.rounded(20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrGreen.opacity(0.8)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                        }
                        
                        if !game.keepPlaying {
                            Button("Continue Playing") {
                                withAnimation {
                                    game.keepPlaying = true
                                }
                            }
                            .font(AppFont.rounded(18, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(BlockBlastConstants.cravrDarkSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(20)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
