import SwiftUI

struct OpeningView: View {
    let startGame: () -> Void
    let bestScore: Int
    
    @State private var animateTitle = false
    @State private var animateScore = false
    
    var body: some View {
        ZStack {
            StarBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("2048")
                    .font(AppFont.rounded(80, weight: .black))
                    .foregroundColor(AppColors.primaryGreen)
                    .shadow(color: AppColors.primaryGreen.opacity(0.5), radius: 20, x: 0, y: 10)
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
                .offset(y: animateScore ? -10 : 10)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        animateScore = true
                    }
                }
                
                Spacer()
                
                // Play Button
                Button(action: startGame) {
                    Text("PLAY")
                        .font(AppFont.rounded(30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                        .background(
                            Capsule()
                                .fill(AppColors.primaryGreen)
                                .shadow(radius: 10)
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
