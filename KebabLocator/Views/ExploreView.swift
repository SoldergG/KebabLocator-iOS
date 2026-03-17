import SwiftUI
import MapKit

// MARK: - Explore View (Listings + Search)

struct ExploreView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedSort: SortOption = .distance
    @State private var selectedShop: KebabShop?
    @State private var showDetail = false
    @State private var showSortMenu = false
    
    private var filteredShops: [KebabShop] {
        var shops = locationManager.liveShops + KebabShop.sampleData
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .doner:
            shops = shops.filter { $0.category == .doner }
        case .falafel:
            shops = shops.filter { $0.category == .falafel }
        case .durum:
            shops = shops.filter { $0.category == .durum }
        case .shawarma:
            shops = shops.filter { $0.category == .shawarma }
        case .lateNight:
            shops = shops.filter { $0.tags.contains(where: { $0.lowercased().contains("late night") }) }
        case .topRated:
            shops = shops.filter { $0.rating >= 4.6 }
        case .openNow:
            shops = shops.filter { $0.isOpenNow }
        }
        
        // Apply search
        if !searchText.isEmpty {
            shops = shops.filter { shop in
                shop.name.localizedCaseInsensitiveContains(searchText) ||
                shop.address.localizedCaseInsensitiveContains(searchText) ||
                shop.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
                shop.description.localizedCaseInsensitiveContains(searchText) ||
                shop.popularDishes.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        // Apply sort
        let location = locationManager.effectiveLocation
        switch selectedSort {
        case .distance:
            shops.sort { $0.distance(from: location) < $1.distance(from: location) }
        case .rating:
            shops.sort { $0.rating > $1.rating }
        case .price:
            shops.sort { $0.price.count < $1.price.count }
        case .name:
            shops.sort { $0.name < $1.name }
        }
        
        return shops
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Search Bar
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        // Filter Chips
                        filterChips
                            .padding(.top, 14)
                        
                        // Results Header with Sort
                        resultsHeader
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                        
                        // Shop Cards
                        if filteredShops.isEmpty {
                            noResultsView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredShops) { shop in
                                    ShopCardView(
                                        shop: shop,
                                        userLocation: locationManager.effectiveLocation,
                                        isFavorite: favoritesManager.isFavorite(shop),
                                        onFavorite: {
                                            favoritesManager.toggle(shop)
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
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .refreshable {
                locationManager.searchNearbyKebabs(at: locationManager.effectiveLocation)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            .onChange(of: locationManager.searchRadius) {
                locationManager.searchNearbyKebabs(at: locationManager.effectiveLocation)
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.bgPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showDetail) {
                if let shop = selectedShop {
                    ShopDetailView(shop: shop, userLocation: locationManager.effectiveLocation)
                }
            }
        }
    }
    

    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textMuted)
            
            TextField("Search shops, dishes...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.textMuted)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterOption.allCases, id: \.self) { filter in
                    FilterChip(
                        title: "\(filter.emoji) \(filter.rawValue)",
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedFilter = filter
                        }
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Results Header
    
    private var resultsHeader: some View {
        HStack {
            Text("Nearby Kebab Shops")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            Spacer()
            
            // Radius Button
            Menu {
                ForEach([5, 10, 20, 40], id: \.self) { radius in
                    Button {
                        locationManager.searchRadius = Double(radius)
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    } label: {
                        Label("\(radius) km", systemImage: locationManager.searchRadius == Double(radius) ? "checkmark" : "mappin.and.ellipse")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "scope")
                        .font(.system(size: 11, weight: .semibold))
                    Text("\(Int(locationManager.searchRadius))km")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.accentOrange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.accentOrange.opacity(0.1))
                        .overlay(
                            Capsule().stroke(Color.accentOrange.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Sort Button
            Menu {
                ForEach(SortOption.allCases, id: \.self) { sort in
                    Button {
                        selectedSort = sort
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    } label: {
                        Label(sort.rawValue, systemImage: selectedSort == sort ? "checkmark" : sort.icon)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text(selectedSort.rawValue)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.accentOrange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.accentOrange.opacity(0.1))
                        .overlay(
                            Capsule().stroke(Color.accentOrange.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            Text("\(filteredShops.count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(Color.surface)
                )
        }
    }
    
    // MARK: - No Results
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.textMuted)
                .padding(.top, 40)
            Text("No kebab shops found")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.textSecondary)
            Text("Try adjusting your search or filters")
                .font(.system(size: 14))
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .accentOrange : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentOrange.opacity(0.15) : Color.surface)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.accentOrange : Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
                .shadow(color: isSelected ? .accentGlow : .clear, radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Shop Card

struct ShopCardView: View {
    let shop: KebabShop
    let userLocation: CLLocation
    let isFavorite: Bool
    let onFavorite: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Image
            Group {
                if shop.imageName.hasPrefix("http") {
                    AsyncImage(url: URL(string: shop.imageName)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            KebabPlaceholderView(name: shop.name)
                        }
                    }
                    .frame(width: 120, height: 140)
                } else {
                    Image(shop.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 140)
                }
            }
            .clipped()
            .overlay(alignment: .topLeading) {
                if shop.rating >= 4.7 {
                    Text("TOP")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(LinearGradient.kebabGradient)
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
            
            // Body
            VStack(alignment: .leading, spacing: 5) {
                // Name + Favorite
                HStack {
                    Text(shop.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(isFavorite ? .closedRed : .textMuted)
                            .scaleEffect(isFavorite ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text(shop.address)
                        .lineLimit(1)
                }
                .font(.system(size: 12))
                .foregroundColor(.textMuted)
                
                HStack(spacing: 10) {
                    // Rating
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.starYellow)
                        Text(String(format: "%.1f", shop.rating))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.starYellow)
                        Text("(\(shop.reviews))")
                            .font(.system(size: 10))
                            .foregroundColor(.textMuted)
                    }
                    
                    // Price
                    Text(shop.price)
                        .font(.system(size: 11))
                        .foregroundColor(.textMuted)
                    
                    // Distance
                    Text(String(format: "%.1f km", shop.distance(from: userLocation)))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                // Open/Closed
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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(shop.tags.prefix(3), id: \.self) { tag in
                            TagPill(tag: tag)
                        }
                        // Service badges
                        if shop.hasDelivery {
                            ServiceBadge(icon: "bicycle", text: "Delivery")
                        }
                    }
                }
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Service Badge

struct ServiceBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundColor(.openGreen)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.openGreen.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color.openGreen.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tag Pill

struct TagPill: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.accentOrange)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.accentOrange.opacity(0.08))
                    .overlay(
                        Capsule()
                            .stroke(Color.accentOrange.opacity(0.15), lineWidth: 1)
                    )
            )
    }
}
