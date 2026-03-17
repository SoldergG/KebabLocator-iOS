import SwiftUI
import MapKit

// MARK: - Map Tab View

struct MapTabView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedShop: KebabShop?
    @State private var selectedShopID: String?
    @State private var showDetail = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 38.7167, longitude: -9.1395),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    private var allShops: [KebabShop] {
        locationManager.liveShops + KebabShop.sampleData
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map
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
                    
                    // Kebab shop markers
                    ForEach(allShops) { shop in
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
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: selectedShopID) { oldID, newID in
                    if let newID = newID {
                        selectedShop = allShops.first(where: { $0.id == newID })
                    } else {
                        selectedShop = nil
                    }
                }
                
                // Bottom info card when shop selected
                if let shop = selectedShop, !showDetail {
                    VStack {
                        Spacer()
                        bottomCard(shop: shop)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedShop?.id)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.bgPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .overlay(alignment: .bottomTrailing) {
                // Floating Locate Me Button
                if selectedShop == nil {
                    Button {
                        withAnimation {
                            if let location = locationManager.userLocation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                ))
                            }
                        }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.accentOrange)
                            .clipShape(Circle())
                            .shadow(color: .accentGlow, radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 24)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            .sheet(isPresented: $showDetail) {
                if let shop = selectedShop {
                    ShopDetailView(shop: shop, userLocation: locationManager.effectiveLocation)
                }
            }
            .onAppear {
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
                
                Image(systemName: "fork.knife")
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
