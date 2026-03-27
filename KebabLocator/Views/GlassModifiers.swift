import SwiftUI

// MARK: - Liquid Glass Design System

// Glass card modifier — translucent blur with glow border
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 18
    var opacity: CGFloat = 0.08
    var borderOpacity: CGFloat = 0.15
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(opacity),
                                    Color.white.opacity(opacity * 0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(borderOpacity),
                                Color.white.opacity(borderOpacity * 0.3),
                                Color.accentOrange.opacity(borderOpacity * 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// Glass background — full screen gradient mesh with blur
struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.bgPrimary
                    
                    // Animated gradient blobs
                    Circle()
                        .fill(Color.accentOrange.opacity(0.06))
                        .blur(radius: 80)
                        .frame(width: 300, height: 300)
                        .offset(x: -100, y: -200)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.04))
                        .blur(radius: 100)
                        .frame(width: 400, height: 400)
                        .offset(x: 150, y: 100)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.03))
                        .blur(radius: 90)
                        .frame(width: 250, height: 250)
                        .offset(x: -50, y: 300)
                }
                .ignoresSafeArea()
            )
    }
}

// Glow border — pulsing glow 
struct GlowBorder: ViewModifier {
    var color: Color = .accentOrange
    var cornerRadius: CGFloat = 18
    @State private var isGlowing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color.opacity(isGlowing ? 0.4 : 0.15), lineWidth: 1.5)
                    .shadow(color: color.opacity(isGlowing ? 0.3 : 0.1), radius: isGlowing ? 10 : 4, x: 0, y: 0)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }
}

// Glass pill — small translucent pill for tags, badges
struct GlassPill: ViewModifier {
    var color: Color = .accentOrange
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .fill(color.opacity(0.08))
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
            )
    }
}

// Glass button style
struct GlassButtonStyle: ButtonStyle {
    var color: Color = .accentOrange
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func glassCard(cornerRadius: CGFloat = 18, opacity: CGFloat = 0.08, borderOpacity: CGFloat = 0.15) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity, borderOpacity: borderOpacity))
    }
    
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
    
    func glowBorder(color: Color = .accentOrange, cornerRadius: CGFloat = 18) -> some View {
        modifier(GlowBorder(color: color, cornerRadius: cornerRadius))
    }
    
    func glassPill(color: Color = .accentOrange) -> some View {
        modifier(GlassPill(color: color))
    }
}

// MARK: - Animated Glass Orb (for empty states)

struct AnimatedGlassOrb: View {
    @State private var phase: CGFloat = 0
    var size: CGFloat = 120
    var color: Color = .accentOrange
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.2), color.opacity(0.05), .clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 10)
            
            // Glass sphere
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.03),
                                    color.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.05),
                                    color.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: color.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Highlight reflection
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.5, height: size * 0.25)
                .offset(y: -size * 0.2)
                .rotationEffect(.degrees(-15))
        }
        .scaleEffect(1.0 + sin(phase) * 0.03)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Glass Stat Card (for Saved tab stats)

struct GlassStatCard: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .accentOrange
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textMuted)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(cornerRadius: 16)
    }
}

// MARK: - Additional Glass Colors

extension Color {
    static let glassWhite = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let glassHighlight = Color.white.opacity(0.18)
}
