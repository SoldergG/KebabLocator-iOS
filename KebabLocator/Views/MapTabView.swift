import SwiftUI
import MapKit

// MARK: - Map Tab View

struct MapTabView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedShop: KebabShop?
    @State private var selectedShopID: String?
    @State private var showDetail = false
    @State private var showFilters: Bool = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 38.7167, longitude: -9.1395),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    @State private var visibleRegion: MKCoordinateRegion?

    private var allShops: [KebabShop] {
        let live = Array(locationManager.liveShops)
        let saved = Array(favoritesManager.allShops)
        return live + saved
    }

    private var visibleShops: [KebabShop] {
        guard let region = visibleRegion else { return allShops }
        let latBuffer = region.span.latitudeDelta * 0.75
        let lonBuffer = region.span.longitudeDelta * 0.75
        return allShops.filter {
            abs($0.coordinate.latitude  - region.center.latitude)  <= latBuffer &&
            abs($0.coordinate.longitude - region.center.longitude) <= lonBuffer
        }
    }
    
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $selectedShopID) {
                // User location
                if let location = locationManager.userLocation {
                    Annotation("You", coordinate: location.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                }
                
                // Kebab shop markers (only visible region for performance)
                ForEach(visibleShops) { shop in
                    Annotation(shop.name, coordinate: shop.coordinate) {
                        KebabMarker(
                            shop: shop,
                            isSelected: selectedShop?.id == shop.id
                        )
                    }
                    .tag(shop.id)
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .colorScheme(.dark)
            .ignoresSafeArea(edges: [.bottom])
            .onMapCameraChange { context in visibleRegion = context.region }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.bgPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
            // Overlays
            .overlay(alignment: .top) {
                // Ad Banner at top
                VStack(spacing: 0) {
                    BannerAd(adUnitID: "ca-app-pub-3940256099942544/2934735716", height: 50)
                        .frame(height: 50)
                    
                    // Top gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [Color.bgPrimary, Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                }
            }
            .overlay(alignment: .bottom) {
                // Bottom info card
                if let shop = selectedShop, !showDetail {
                    bottomCard(shop: shop)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedShop?.id)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // Floating Locate Me Button
                if selectedShop == nil {
                    VStack(spacing: 12) {
                        // Refresh button
                        Button {
                            favoritesManager.fetchShops(forceRefresh: true)
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.surface)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
                        Button {
                            withAnimation {
                                if let location = locationManager.userLocation {
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                    ))
                                }
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.accentOrange)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 32)
                }
            }
            .onChange(of: selectedShopID) { oldID, newID in
                if let newID = newID {
                    selectedShop = allShops.first(where: { $0.id == newID })
                } else {
                    selectedShop = nil
                }
            }
            .sheet(isPresented: $showDetail) {
                if let shop = selectedShop {
                    ShopDetailView(shop: shop, userLocation: locationManager.effectiveLocation)
                }
            }
            .onAppear {
                // Load shops from Supabase
                if favoritesManager.allShops.isEmpty {
                    favoritesManager.fetchShops()
                }
                
                if let location = locationManager.userLocation {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    ))
                }
            }
        }
    }
    
    // MARK: - Bottom Card
    
    private func bottomCard(shop: KebabShop) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surface)
                Image(systemName: shop.category.sfSymbol)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentOrange)
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.starYellow)
                        Text(String(format: "%.1f", shop.rating))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.starYellow)
                    }
                    
                    Text(shop.price)
                        .font(.system(size: 12))
                        .foregroundColor(.textMuted)
                    
                    Text(shop.hours)
                        .font(.system(size: 11))
                        .foregroundColor(.textMuted)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button {
                showDetail = true
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LinearGradient.kebabGradient)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Kebab Marker

struct KebabMarker: View {
    let shop: KebabShop
    let isSelected: Bool
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Pulse ring
            if isSelected {
                Circle()
                    .fill(Color.accentOrange.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulse ? 1.3 : 1.0)
                    .opacity(pulse ? 0 : 0.8)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                            pulse = true
                        }
                    }
            }
            
            // Marker
            ZStack {
                Circle()
                    .fill(LinearGradient.kebabGradient)
                    .frame(width: isSelected ? 44 : 38, height: isSelected ? 44 : 38)
                    .shadow(color: .accentGlow, radius: isSelected ? 10 : 4)
                
                Image(systemName: shop.category.sfSymbol)
                    .font(.system(size: isSelected ? 18 : 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: isSelected ? 44 : 38, height: isSelected ? 44 : 38)
            )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
