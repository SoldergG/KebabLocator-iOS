import SwiftUI
import MapKit

// MARK: - Home View (Main Dashboard)

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedShop: KebabShop?
    @State private var showDetail = false
    @State private var showLocationSheet = false
    @State private var showAddSheet = false
    @Binding var selectedTab: Int
    
    // Mode toggle: Kebab vs Convenience Store
    @State private var isConvenienceMode: Bool = false
    @State private var animatedText: String = "Kebab"
    @State private var textIndex: Int = 0
    let textOptions = ["Kebab", "Convenience"]
    
    // Mode selection sheet
    @State private var showModeSelector: Bool = false
    
    // Animation timer
    @State private var timer: Timer?
    
    // Top 3 closest top-rated shops (filtered by mode)
    private var topPicks: [KebabShop] {
        let loc = locationManager.effectiveLocation
        
        // Use real convenience stores when in Convenience mode
        if isConvenienceMode {
            return locationManager.convenienceStores
                .filter { $0.rating >= 3.0 }
                .sorted { $0.distance(from: loc) < $1.distance(from: loc) }
                .prefix(5)
                .map { $0 }
        }
        
        // Default: show kebabs
        let allShops = Array(locationManager.liveShops) + Array(favoritesManager.allShops)
        
        return allShops
            .filter { $0.rating >= 4.0 }
            .sorted { $0.distance(from: loc) < $1.distance(from: loc) }
            .prefix(5)
            .map { $0 }
    }
    
    // Nearest All shops (filtered by mode)
    private var allPlaces: [KebabShop] {
        let loc = locationManager.effectiveLocation
        
        // Use real convenience stores when in Convenience mode
        if isConvenienceMode {
            return locationManager.convenienceStores
                .sorted { $0.distance(from: loc) < $1.distance(from: loc) }
                .prefix(15)
                .map { $0 }
        } else {
            let allShops = Array(locationManager.liveShops) + Array(favoritesManager.allShops)
            
            return allShops
                .sorted { $0.distance(from: loc) < $1.distance(from: loc) }
                .prefix(15)
                .map { $0 }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                // Ambient glass blobs
                Circle()
                    .fill(Color.accentOrange.opacity(0.05))
                    .blur(radius: 90)
                    .frame(width: 280, height: 280)
                    .offset(x: -120, y: -180)
                    .ignoresSafeArea()
                
                Circle()
                    .fill(Color.blue.opacity(0.03))
                    .blur(radius: 100)
                    .frame(width: 300, height: 300)
                    .offset(x: 150, y: 100)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Fixed Header on top (non-scrolling)
                    header
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    
                    // Scrolling content below
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            // Ad Banner
                            BannerAd(adUnitID: "ca-app-pub-3940256099942544/2934735716", height: 50)
                                .padding(.horizontal, 16)
                            
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
                            
                            // All Places List
                            if !allPlaces.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    sectionHeader(title: "All Places", icon: "location.fill", color: .accentOrange)
                                    
                                    LazyVStack(spacing: 12) {
                                        ForEach(allPlaces) { shop in
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
                            
                            if topPicks.isEmpty && allPlaces.isEmpty && !locationManager.isFetchingLiveShops {
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
                            
                            Spacer(minLength: 20)
                            
                            // Bottom Action Buttons
                            bottomActions
                                .padding(.horizontal, 16)
                                .padding(.bottom, 30)
                        }
                        .padding(.top, 20)
                    }
                    .refreshable {
                        locationManager.searchNearbyKebabs(at: locationManager.effectiveLocation)
                        favoritesManager.fetchShops(forceRefresh: true)
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                }
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
            .sheet(isPresented: $showAddSheet) {
                AddKebabView(isConvenienceMode: isConvenienceMode)
            }
            .sheet(isPresented: $showModeSelector) {
                ModeSelectorView(isConvenienceMode: $isConvenienceMode, animatedText: $animatedText, textIndex: $textIndex)
            }
            .onAppear {
                // Load shops from Supabase
                if favoritesManager.allShops.isEmpty {
                    favoritesManager.fetchShops()
                }
                
                // Load convenience stores if in Convenience mode
                if isConvenienceMode {
                    locationManager.searchNearbyConvenienceStores()
                } else {
                    // Start text animation timer
                    startTextAnimation()
                }
            }
            .onChange(of: isConvenienceMode) { oldValue, newValue in
                if newValue {
                    // When Convenience mode is activated, fetch real stores
                    locationManager.searchNearbyConvenienceStores()
                } else {
                    // When switched back to Kebab mode, start animation
                    startTextAnimation()
                }
            }
            .onDisappear {
                // Stop timer when leaving view
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    // MARK: - Text Animation
    
    private func startTextAnimation() {
        // Animate text every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            guard !isConvenienceMode else { return } // Don't animate in convenience mode
            
            withAnimation(.easeInOut(duration: 0.3)) {
                textIndex = (textIndex + 1) % textOptions.count
                animatedText = textOptions[textIndex]
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
                
                // Static title - wider and more beautiful
                VStack(alignment: .leading, spacing: 2) {
                    Text("Find Your")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .tracking(2)
                    
                    HStack(spacing: 8) {
                        Text("Nearest")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .tracking(1)
                        
                        Text(isConvenienceMode ? "Convenience" : "Kebab")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(isConvenienceMode ? .openGreen : .accentOrange)
                            .tracking(1)
                            .shadow(color: isConvenienceMode ? .openGreen.opacity(0.5) : .accentOrange.opacity(0.5), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: isConvenienceMode ? "bag.fill" : "fork.knife")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(isConvenienceMode ? .openGreen : .accentOrange)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Mode indicator pill
                HStack(spacing: 8) {
                    Capsule()
                        .fill(isConvenienceMode ? Color.openGreen.opacity(0.2) : Color.accentOrange.opacity(0.2))
                        .frame(width: isConvenienceMode ? 140 : 100, height: 28)
                        .overlay(
                            HStack(spacing: 4) {
                                Image(systemName: isConvenienceMode ? "moon.stars.fill" : "fork.knife.circle")
                                    .font(.system(size: 12))
                                Text(isConvenienceMode ? "Convenience Mode" : "Kebab Mode")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(isConvenienceMode ? .openGreen : .accentOrange)
                        )
                        .onTapGesture {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            isConvenienceMode.toggle()
                        }
                    
                    Text("(tap to switch)")
                        .font(.system(size: 11))
                        .foregroundColor(.textMuted)
                }
                .padding(.top, 4)
                
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
        }
        .padding(.trailing, 4)
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
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.surface.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
    
    // MARK: - Bottom Actions (Add Spot & GPS)
    
    private var bottomActions: some View {
        HStack(spacing: 12) {
            // Add Kebab Button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showAddSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(isConvenienceMode ? "Add Store" : "Add Kebab")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.openGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // GPS Recenter Button
            Button {
                locationManager.useGPSLocation()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } label: {
                HStack {
                    Image(systemName: "location.north.circle.fill")
                    Text("Center GPS")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
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
                if let imageURL = shop.displayImageURL {
                    AsyncImage(url: imageURL) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            KebabPlaceholderView(name: shop.name)
                        }
                    }
                    .frame(height: 140)
                } else {
                    KebabPlaceholderView(name: shop.name)
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
            .overlay(alignment: .topLeading) {
                if shop.isSponsored {
                    Text("SPONSORED")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.accentOrange)
                        .cornerRadius(4)
                        .padding(8)
                }
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
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.06), Color.white.opacity(0.02), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.04), Color.accentOrange.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
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
        .glassCard(cornerRadius: 16, opacity: 0.06, borderOpacity: 0.1)
    }
}

// MARK: - Mode Selector Sheet View

struct ModeSelectorView: View {
    @Binding var isConvenienceMode: Bool
    @Binding var animatedText: String
    @Binding var textIndex: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Select Mode")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        // Kebab Mode Button
                        ModeButton(
                            title: "Kebab",
                            subtitle: "Find the best kebab shops",
                            icon: "fork.knife",
                            color: .accentOrange,
                            isSelected: !isConvenienceMode
                        ) {
                            isConvenienceMode = false
                            animatedText = "Kebab"
                            textIndex = 0
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            dismiss()
                        }
                        
                        // Convenience Mode Button
                        ModeButton(
                            title: "Convenience",
                            subtitle: "Late night convenience stores",
                            icon: "bag.fill",
                            color: .openGreen,
                            isSelected: isConvenienceMode
                        ) {
                            isConvenienceMode = true
                            animatedText = "Convenience"
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            dismiss()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
}

// MARK: - Mode Button

struct ModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                }
                
                Spacer()
                
                // Checkmark if selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.bgElevated.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                LinearGradient(colors: [color.opacity(0.5), color.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? color.opacity(0.15) : .clear, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


