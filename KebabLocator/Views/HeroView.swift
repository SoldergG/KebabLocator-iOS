import SwiftUI

// MARK: - Hero / Onboarding View

struct HeroView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var locationManager: LocationManager
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateButtons = false
    @State private var animateStats = false
    @State private var pulsate = false
    
    var body: some View {
        ZStack {
            // Background
            Color.bgPrimary
                .ignoresSafeArea()
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.accentOrange.opacity(0.08),
                    Color.clear,
                    Color.accentOrange.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Badge
                Text("🥙 #1 Kebab Finder")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.accentOrange)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.accentOrange.opacity(0.12))
                            .overlay(
                                Capsule()
                                    .stroke(Color.accentOrange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .scaleEffect(pulsate ? 1.05 : 1.0)
                    .opacity(animateTitle ? 1 : 0)
                    .offset(y: animateTitle ? 0 : 20)
                    .padding(.bottom, 24)
                
                // Title
                VStack(spacing: 4) {
                    Text("Find the")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Text("Best Kebabs")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient.kebabGradient)
                    
                    Text("Near You")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.textPrimary)
                }
                .multilineTextAlignment(.center)
                .opacity(animateTitle ? 1 : 0)
                .offset(y: animateTitle ? 0 : 30)
                .padding(.bottom, 20)
                
                // Subtitle
                Text("Discover top-rated kebab shops, explore menus, read reviews, and get directions — all in one place.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .opacity(animateSubtitle ? 1 : 0)
                    .offset(y: animateSubtitle ? 0 : 20)
                    .padding(.bottom, 40)
                
                // CTA Buttons
                VStack(spacing: 14) {
                    Button(action: {
                        locationManager.requestPermission()
                        locationManager.startUpdating()
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showOnboarding = false
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Use My Location")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(LinearGradient.kebabGradient)
                        .clipShape(Capsule())
                        .shadow(color: .accentGlow, radius: 12, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showOnboarding = false
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Explore the Map")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 32)
                .opacity(animateButtons ? 1 : 0)
                .offset(y: animateButtons ? 0 : 30)
                .padding(.bottom, 40)
                
                // Stats
                HStack(spacing: 40) {
                    StatItem(number: "150+", label: "SHOPS")
                    StatItem(number: "4.8K", label: "REVIEWS")
                    StatItem(number: "12", label: "CITIES")
                }
                .opacity(animateStats ? 1 : 0)
                .offset(y: animateStats ? 0 : 20)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                animateTitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                animateSubtitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                animateButtons = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                animateStats = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.2)) {
                pulsate = true
            }
        }
    }
}

struct StatItem: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.accentOrange)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textMuted)
                .tracking(1.5)
        }
    }
}
