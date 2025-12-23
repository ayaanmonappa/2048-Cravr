import SwiftUI

struct OpeningView: View {
    let startGame: () -> Void
    let bestScore: Int
    
    @State private var animateTitle = false
    @State private var animateScore = false
    
    var body: some View {
        ZStack {
            StarBackground()
            
            FloatingTilesBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("2048")
                    .font(AppFont.rounded(80, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrMaize],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: BlockBlastConstants.cravrGreen.opacity(0.5), radius: 20, x: 0, y: 10)
                    .scaleEffect(animateTitle ? 1.1 : 1.0)
                    .rotationEffect(.degrees(animateTitle ? -5 : 5))
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            animateTitle = true
                        }
                    }
                
                // High Score Display
                VStack {
                    Text("BEST SCORE")
                        .font(AppFont.rounded(16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(bestScore)")
                        .font(AppFont.rounded(40, weight: .heavy))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Play Button
                Button(action: startGame) {
                    Text("PLAY")
                        .font(AppFont.rounded(30, weight: .bold))
                        .foregroundColor(.black) // Black text on bright button
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
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
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    OpeningView(startGame: {}, bestScore: 12345)
}
