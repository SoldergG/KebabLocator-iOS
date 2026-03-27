import SwiftUI
import CoreLocation

// MARK: - Saved (Favorites) View — Liquid Glass Design

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedShop: KebabShop?
    @State private var showDetail = false
    @State private var sortOption: SavedSortOption = .recent
    @State private var animateStats = false
    
    private var favoriteShops: [KebabShop] {
        var shops = favoritesManager.getFavoriteShops(ids: favoritesManager.favoriteIDs, additionalShops: locationManager.liveShops)
        
        switch sortOption {
        case .recent:
            break // Keep default order
        case .rating:
            shops.sort { $0.rating > $1.rating }
        case .distance:
            let loc = locationManager.effectiveLocation
            shops.sort { $0.distance(from: loc) < $1.distance(from: loc) }
        case .name:
            shops.sort { $0.name < $1.name }
        }
        
        return shops
    }
    
    private var avgRating: Double {
        guard !favoriteShops.isEmpty else { return 0 }
        return favoriteShops.reduce(0) { $0 + $1.rating } / Double(favoriteShops.count)
    }
    
    private var uniqueCategories: Int {
        Set(favoriteShops.map { $0.category }).count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid Glass background
                Color.bgPrimary.ignoresSafeArea()
                
                // Ambient gradient blobs
                GeometryReader { geo in
                    Circle()
                        .fill(Color.accentOrange.opacity(0.05))
                        .blur(radius: 80)
                        .frame(width: 300, height: 300)
                        .offset(x: -60, y: -100)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.04))
                        .blur(radius: 100)
                        .frame(width: 350, height: 350)
                        .offset(x: geo.size.width - 100, y: 200)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.03))
                        .blur(radius: 70)
                        .frame(width: 200, height: 200)
                        .offset(x: 50, y: geo.size.height - 300)
                }
                .ignoresSafeArea()
                
                if favoriteShops.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Inline Header
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Saved")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.textPrimary)
                                Text("Your favorite places")
                                    .font(.system(size: 15))
                                    .foregroundColor(.textMuted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)
                            
                            // Stats Header
                            statsHeader
                            
                            // Sort Bar
                            sortBar
                            
                            // Ad Banner
                            BannerAd(adUnitID: "ca-app-pub-3940256099942544/2934735716", height: 60)
                                .glassCard(cornerRadius: 12, opacity: 0.04, borderOpacity: 0.08)
                            
                            // Saved Shop Cards
                            LazyVStack(spacing: 14) {
                                ForEach(favoriteShops) { shop in
                                    SavedShopCard(
                                        shop: shop,
                                        userLocation: locationManager.effectiveLocation,
                                        onRemove: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                favoritesManager.toggle(shop)
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        selectedShop = shop
                                        showDetail = true
                                    }
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        favoritesManager.fetchShops(forceRefresh: true)
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showDetail) {
                if let shop = selectedShop {
                    ShopDetailView(shop: shop, userLocation: locationManager.effectiveLocation)
                }
            }
            .onAppear {
                if favoritesManager.allShops.isEmpty {
                    favoritesManager.fetchShops()
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    animateStats = true
                }
            }
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        HStack(spacing: 10) {
            GlassStatCard(
                icon: "bookmark.fill",
                value: "\(favoriteShops.count)",
                label: "Saved",
                color: .accentOrange
            )
            .scaleEffect(animateStats ? 1 : 0.8)
            .opacity(animateStats ? 1 : 0)
            
            GlassStatCard(
                icon: "star.fill",
                value: String(format: "%.1f", avgRating),
                label: "Avg Rating",
                color: .starYellow
            )
            .scaleEffect(animateStats ? 1 : 0.8)
            .opacity(animateStats ? 1 : 0)
            
            GlassStatCard(
                icon: "square.grid.2x2.fill",
                value: "\(uniqueCategories)",
                label: "Types",
                color: .openGreen
            )
            .scaleEffect(animateStats ? 1 : 0.8)
            .opacity(animateStats ? 1 : 0)
        }
    }
    
    // MARK: - Sort Bar
    
    private var sortBar: some View {
        HStack {
            Text("\(favoriteShops.count) places saved")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Menu {
                ForEach(SavedSortOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            sortOption = option
                        }
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    } label: {
                        Label(option.rawValue, systemImage: sortOption == option ? "checkmark" : option.icon)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text(sortOption.rawValue)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.accentOrange)
                .glassPill(color: .accentOrange)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            AnimatedGlassOrb(size: 110, color: .accentOrange)
                .overlay(
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.accentOrange.opacity(0.7))
                )
            
            VStack(spacing: 10) {
                Text("No Saved Places")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Tap the ♡ on any kebab shop\nto save it here for quick access")
                    .font(.system(size: 15))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Sort Options

enum SavedSortOption: String, CaseIterable {
    case recent = "Recent"
    case rating = "Rating"
    case distance = "Distance"
    case name = "Name"
    
    var icon: String {
        switch self {
        case .recent: return "clock.fill"
        case .rating: return "star.fill"
        case .distance: return "location.fill"
        case .name: return "textformat.abc"
        }
    }
}

// MARK: - Saved Shop Card (Liquid Glass Style)

struct SavedShopCard: View {
    let shop: KebabShop
    let userLocation: CLLocation
    let onRemove: () -> Void
    @State private var cardAppeared = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Image
            Group {
                if let imageURL = shop.displayImageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            KebabPlaceholderView(name: shop.name)
                        }
                    }
                    .frame(width: 110, height: 130)
                } else {
                    KebabPlaceholderView(name: shop.name)
                        .frame(width: 110, height: 130)
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .topLeading) {
                // Category badge
                Image(systemName: shop.category.sfSymbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(6)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Name + Remove
                HStack {
                    Text(shop.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentOrange)
                            .shadow(color: .accentOrange.opacity(0.4), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                
                // Address
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text(shop.address)
                        .lineLimit(1)
                }
                .font(.system(size: 12))
                .foregroundColor(.textMuted)
                
                // Rating + Price + Distance
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.starYellow)
                        Text(String(format: "%.1f", shop.rating))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.starYellow)
                    }
                    
                    Text(shop.price)
                        .font(.system(size: 11))
                        .foregroundColor(.textMuted)
                    
                    Text(String(format: "%.1f km", shop.distance(from: userLocation)))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                // Open status
                HStack(spacing: 4) {
                    Circle()
                        .fill(shop.isOpenNow ? Color.openGreen : Color.closedRed)
                        .frame(width: 6, height: 6)
                    Text(shop.statusText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(shop.isOpenNow ? .openGreen : .closedRed)
                    Text("· \(shop.hours)")
                        .font(.system(size: 10))
                        .foregroundColor(.textMuted)
                        .lineLimit(1)
                }
                
                // Tags
                HStack(spacing: 5) {
                    ForEach(shop.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.accentOrange)
                            .glassPill(color: .accentOrange)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 18)
        .scaleEffect(cardAppeared ? 1 : 0.95)
        .opacity(cardAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardAppeared = true
            }
        }
    }
}
