import SwiftUI
import MapKit

// MARK: - Content View (Main)

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedTab = 0
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            MapTabView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(2)
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(3)
            
            LocationInputView()
                .tabItem {
                    Label("Location", systemImage: "location.fill")
                }
                .tag(4)
        }
        .tint(Color.accentOrange)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.bgPrimary)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Design System Colors

extension Color {
    static let bgPrimary = Color(red: 0.04, green: 0.04, blue: 0.06)
    static let bgElevated = Color(red: 0.07, green: 0.07, blue: 0.10)
    static let bgCard = Color(red: 0.07, green: 0.07, blue: 0.10).opacity(0.85)
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.16)
    static let accentOrange = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let accentGlow = Color(red: 0.96, green: 0.62, blue: 0.04).opacity(0.25)
    static let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let textSecondary = Color(red: 0.61, green: 0.64, blue: 0.69)
    static let textMuted = Color(red: 0.42, green: 0.44, blue: 0.50)
    static let starYellow = Color(red: 0.98, green: 0.75, blue: 0.14)
    static let openGreen = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let closedRed = Color(red: 0.94, green: 0.27, blue: 0.27)
}

// MARK: - Gradient

extension LinearGradient {
    static let kebabGradient = LinearGradient(
        colors: [Color.accentOrange, Color(red: 0.94, green: 0.27, blue: 0.27)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
