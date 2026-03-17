import SwiftUI

struct KebabPlaceholderView: View {
    let name: String
    
    var body: some View {
        ZStack {
            // Premium Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.surface, Color.bgElevated]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                // Large Kebab/Food Icon
                ZStack {
                    Circle()
                        .fill(Color.accentOrange.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "fork.knife")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(LinearGradient.kebabGradient)
                }
                
                // Subtle text
                Text(name)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .opacity(0.5)
            }
        }
    }
}

#Preview {
    KebabPlaceholderView(name: "Reis do Kebab")
        .frame(width: 200, height: 150)
}
