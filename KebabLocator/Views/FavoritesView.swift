import SwiftUI

// MARK: - Favorites View

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedShop: KebabShop?
    @State private var showDetail = false
    
    private var favoriteShops: [KebabShop] {
        favoritesManager.favorites(from: KebabShop.sampleData)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if favoriteShops.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(favoriteShops) { shop in
                                ShopCardView(
                                    shop: shop,
                                    userLocation: locationManager.effectiveLocation,
                                    isFavorite: true,
                                    onFavorite: {
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
                                    insertion: .opacity,
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Favorites")
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
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentOrange.opacity(0.08))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.slash")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.accentOrange.opacity(0.6))
            }
            
            Text("No Favorites Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Text("Tap the ♡ on any kebab shop\nto save it here for quick access")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
}
