import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct KebabLocatorApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var favoritesManager = FavoritesManager()
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(favoritesManager)
                .preferredColorScheme(.dark)
        }
    }
}
