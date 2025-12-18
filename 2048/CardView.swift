import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Darker background with opacity
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: "062C09").opacity(0.8)) // Dark green tint
                
            // Stroke
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            
            content
                .padding(20)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CardView {
            Text("Hello World")
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 100)
    }
}
