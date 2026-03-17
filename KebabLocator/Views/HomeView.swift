import SwiftUI
import MapKit

// MARK: - Home View (Main Dashboard)

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedShop: KebabShop?
    @State private var showDetail = false
    @State private var showLocationSheet = false
    @Binding var selectedTab: Int // To navigate to Explore/Map
    
    // Top 3 closest top-rated shops
    private var topPicks: [KebabShop] {
        let loc = locationManager.effectiveLocation
        let allShops = locationManager.liveShops + KebabShop.sampleData
        return allShops
            .filter { $0.rating >= 4.0 }
            .sorted { $0.distance(from: loc) < $1.distance(from: loc) }
            .prefix(5)
            .map { $0 }
    }
    
    // Nearest Open Now shops
    private var openNow: [KebabShop] {
        let loc = locationManager.effectiveLocation
        let allShops = locationManager.liveShops + KebabShop.sampleData
        return allShops
            .filter { $0.isOpenNow }
            .sorted { $0.distance(from: loc) < $1.distance(from: loc) }
            .prefix(15)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // Header Greeting & Location
                        header
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        
                        // Top Picks horizontally scrollable
                        if !topPicks.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader(title: "Top Rated Near You", icon: "star.fill", color: .starYellow)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(topPicks) { shop in
                                            HomeCardView(shop: shop, userLocation: locationManager.effectiveLocation)
                                                .frame(width: 260)
                                                .onTapGesture {
                                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                                    generator.impactOccurred()
                                                    selectedShop = shop
                                                    showDetail = true
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // Action Buttons (Explore Map)
                        quickActions
                            .padding(.horizontal, 16)
                        
                        // Open Now List
                        if !openNow.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader(title: "Open Now", icon: "clock.fill", color: .openGreen)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(openNow) { shop in
                                        ShopCardView(
                                            shop: shop,
                                            userLocation: locationManager.effectiveLocation,
                                            isFavorite: favoritesManager.isFavorite(shop),
                                            onFavorite: {
                                                withAnimation { favoritesManager.toggle(shop) }
                                            }
                                        )
                                        .onTapGesture {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            selectedShop = shop
                                            showDetail = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        if topPicks.isEmpty && openNow.isEmpty && !locationManager.isFetchingLiveShops {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.textMuted)
                                    .padding(.top, 40)
                                
                                Text("No Kebabs Found Nearby")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.textPrimary)
                                
                                Text("Try changing your location or zooming out the map.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textMuted)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
                                Button {
                                    locationManager.useGPSLocation()
                                } label: {
                                    Text("Try GPS Again")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.accentOrange.gradient)
                                        .clipShape(Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .refreshable {
                locationManager.searchNearbyKebabs(at: locationManager.effectiveLocation)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDetail) {
                if let shop = selectedShop {
                    ShopDetailView(shop: shop, userLocation: locationManager.effectiveLocation)
                }
            }
            .sheet(isPresented: $showLocationSheet) {
                LocationInputView()
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "hand.wave.fill")
                        .foregroundColor(.accentOrange)
                        .font(.system(size: 14))
                    Text(greeting)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textMuted)
                }
                
                Text("Find Your Kebab")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .tracking(-0.5)
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showLocationSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textSecondary)
                        Text(locationManager.isUsingManualLocation ? locationManager.manualAddress : "Current Location")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.textMuted)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            Spacer()
            
            // Recenter GPS Button
            Button {
                locationManager.useGPSLocation()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 24))
                    Text("GPS Real")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(LinearGradient.kebabGradient)
            }
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 18 { return "Good Afternoon" }
        if hour < 22 { return "Good Evening" }
        return "Late Night Craving?"
    }
    
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        HStack(spacing: 12) {
            Button {
                selectedTab = 1 // Switch to Explore
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search All")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            
            Button {
                selectedTab = 2 // Switch to Map
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Interactive Map")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(LinearGradient.kebabGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .accentGlow, radius: 8, x: 0, y: 4)
            }
        }
    }
}

// MARK: - Home Card View (Horizontal)

struct HomeCardView: View {
    let shop: KebabShop
    let userLocation: CLLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            Group {
                if shop.imageName.hasPrefix("http") {
                    AsyncImage(url: URL(string: shop.imageName)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            KebabPlaceholderView(name: shop.name)
                        }
                    }
                    .frame(height: 140)
                } else {
                    Image(shop.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                }
            }
            .clipped()
            .overlay(alignment: .topTrailing) {
                // Distance badge
                Text(String(format: "%.1f km", shop.distance(from: userLocation)))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(shop.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.starYellow)
                        Text(String(format: "%.1f", shop.rating))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.starYellow)
                    }
                    
                    Text("·")
                        .foregroundColor(.textMuted)
                    
                    Text(shop.price)
                        .font(.system(size: 12))
                        .foregroundColor(.textMuted)
                        
                    Spacer()
                    
                    // Small status dot
                    Circle()
                        .fill(shop.isOpenNow ? Color.openGreen : Color.closedRed)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: KebabCategory
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.surface)
                    .frame(height: 56)
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.accentOrange)
            }
            Text(category.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

