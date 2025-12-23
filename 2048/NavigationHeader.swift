import SwiftUI

struct NavigationHeader<Content: View>: View {
    let title: String
    let onDismiss: (() -> Void)?
    let content: Content
    
    @Environment(\.dismiss) private var dismiss
    
    init(_ title: String, onDismiss: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    if let onDismiss = onDismiss {
                        onDismiss()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(AppFont.rounded(20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(title)
                    .font(AppFont.rounded(20, weight: .bold))
                    .foregroundColor(BlockBlastConstants.cravrMaize)
                
                Spacer()
                
                // Placeholder for symmetry or extra action
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()
            
            content
        }
        .background(Color.clear) // Transparent to let StarBackground show through
    }
}

#Preview {
    ZStack {
        Color.green
        NavigationHeader("Test Header") {
            Text("Content")
        }
    }
}
