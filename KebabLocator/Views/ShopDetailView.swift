import SwiftUI
import MapKit

// MARK: - Shop Detail View

struct ShopDetailView: View {
    let shop: KebabShop
    let userLocation: CLLocation
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false
    @State private var showDirectionsMenu = false
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var showReportSheet = false
    @State private var showVerificationSheet = false
    
    // Pseudo-dynamic confirmation count
    private var confirmationsNeeded: Int {
        let base = (abs(shop.id.hashValue) % 2) + 2
        return favoritesManager.hasVerified(shop) ? max(1, base - 1) : base
    }
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Image
                    headerImage
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(shop.tags, id: \.self) { tag in
                                    TagPill(tag: tag)
                                }
                            }
                        }
                        
                        // Name + Favorite
                        HStack {
                            Text(shop.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Button {
                                favoritesManager.toggle(shop)
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            } label: {
                                Image(systemName: favoritesManager.isFavorite(shop) ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(favoritesManager.isFavorite(shop) ? .closedRed : .textMuted)
                                    .scaleEffect(favoritesManager.isFavorite(shop) ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: favoritesManager.isFavorite(shop))
                            }
                            
                            // Share Button
                            ShareLink(item: URL(string: shop.website.contains("http") ? shop.website : "https://www.google.com/maps/search/?api=1&query=\(shop.coordinate.latitude),\(shop.coordinate.longitude)")!) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.textMuted)
                            }
                            .padding(.leading, 12)
                        }
                        
                        // Rating + Open Status
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < Int(shop.rating) ? "star.fill" : (Double(i) < shop.rating ? "star.leadinghalf.filled" : "star"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.starYellow)
                                }
                                Text(String(format: "%.1f", shop.rating))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.starYellow)
                                Text("(\(shop.reviews))")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textMuted)
                            }
                            
                            // Open/Closed Badge
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(shop.isOpenNow ? Color.openGreen : Color.closedRed)
                                    .frame(width: 7, height: 7)
                                Text(shop.statusText)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(shop.isOpenNow ? .openGreen : .closedRed)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill((shop.isOpenNow ? Color.openGreen : Color.closedRed).opacity(0.1))
                            )
                        }
                        
                        // Address with Copy
                        Button {
                            UIPasteboard.general.string = shop.address
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.accentOrange)
                                Text(shop.address)
                                    .font(.system(size: 15))
                                    .foregroundColor(.textSecondary)
                                    .lineLimit(1)
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textMuted)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        // Info Grid
                        infoGrid
                        
                        // Directions Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Get Directions")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                            
                            HStack(spacing: 12) {
                                NavigationActionButton(title: "Apple Maps", icon: "apple.logo", color: .blue) {
                                    let placemark = MKPlacemark(coordinate: shop.coordinate)
                                    let mapItem = MKMapItem(placemark: placemark)
                                    mapItem.name = shop.name
                                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                                }
                                
                                NavigationActionButton(title: "Google Maps", icon: "map.fill", color: .green) {
                                    if let url = URL(string: "comgooglemaps://?daddr=\(shop.coordinate.latitude),\(shop.coordinate.longitude)&directionsmode=driving") {
                                        if UIApplication.shared.canOpenURL(url) {
                                            UIApplication.shared.open(url)
                                        } else {
                                            if let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(shop.coordinate.latitude),\(shop.coordinate.longitude)") {
                                                UIApplication.shared.open(webUrl)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Service Options
                        serviceOptions
                        
                        // Popular Dishes
                        popularDishes
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                            Text(shop.description)
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                                .lineSpacing(6)
                        }
                        
                        // Action Buttons
                        actionButtons
                        
                        // Banner Ad
                        BannerAd(adUnitID: "ca-app-pub-3940256099942544/6300978111", height: 50)
                            .padding(.top, 16)
                            
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                    .offset(y: animateIn ? 0 : 30)
                    .opacity(animateIn ? 1 : 0)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 10) {
                // Share
                ShareLink(item: "Check out \(shop.name) on Kebab Locator! 🥙\n\(shop.address)\nRating: \(String(format: "%.1f", shop.rating)) ⭐") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateIn = true
            }
        }
        .confirmationDialog("Get Directions", isPresented: $showDirectionsMenu, titleVisibility: .visible) {
            Button("Apple Maps") {
                let placemark = MKPlacemark(coordinate: shop.coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = shop.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
            }
            
            Button("Google Maps") {
                if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(shop.coordinate.latitude),\(shop.coordinate.longitude)&directionsmode=walking") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        if let webUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(shop.coordinate.latitude),\(shop.coordinate.longitude)") {
                            UIApplication.shared.open(webUrl)
                        }
                    }
                }
            }
            
            Button("Waze") {
                if let url = URL(string: "waze://?ll=\(shop.coordinate.latitude),\(shop.coordinate.longitude)&navigate=yes") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        if let storeUrl = URL(string: "https://apps.apple.com/app/id323229106") {
                            UIApplication.shared.open(storeUrl)
                        }
                    }
                }
            }
            
            Button("Citymapper") {
                let encodedName = shop.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "citymapper://directions?endcoord=\(shop.coordinate.latitude),\(shop.coordinate.longitude)&endname=\(encodedName)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        if let storeUrl = URL(string: "https://apps.apple.com/app/id469463298") {
                            UIApplication.shared.open(storeUrl)
                        }
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Header Image
    
    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            // Base layer: The actual shop image (Always present as fallback)
            Group {
                if let imageURL = shop.displayImageURL {
                    AsyncImage(url: imageURL) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            ZStack { Color.surface; Image(systemName: "fork.knife").font(.system(size: 40)).foregroundColor(.textMuted) }
                        }
                    }
                } else {
                    ZStack { Color.surface; Image(systemName: "fork.knife").font(.system(size: 40)).foregroundColor(.textMuted) }
                }
            }
            .frame(height: 240)
            .clipped()
            
            // Overlying layer: LookAround Preview (if available)
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 240)
                    .clipped()
                    .transition(.opacity)
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 240)
        .task {
            // Delay search slightly to ensure view is ready
            try? await Task.sleep(nanoseconds: 500_000_000)
            let request = MKLookAroundSceneRequest(coordinate: shop.coordinate)
            let scene = try? await request.scene
            withAnimation(.easeInOut) {
                lookAroundScene = scene
            }
        }
    }
    
    // MARK: - Info Grid
    
    private var infoGrid: some View {
        HStack(spacing: 12) {
            InfoCard(systemIcon: "clock.fill", title: "Hours", value: shop.hours)
            InfoCard(systemIcon: "eurosign.circle.fill", title: "Price", value: shop.price)
            InfoCard(systemIcon: "mappin.circle.fill", title: "Distance", value: String(format: "%.1f km", shop.distance(from: userLocation)))
        }
    }
    
    // MARK: - Service Options
    
    private var serviceOptions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Services")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 10) {
                ServiceOption(icon: "bag.fill", title: "Takeaway", available: shop.hasTakeaway)
                ServiceOption(icon: "fork.knife", title: "Dine In", available: shop.hasDineIn)
                ServiceOption(icon: "bicycle", title: "Delivery", available: shop.hasDelivery)
            }
        }
    }
    
    // MARK: - Popular Dishes
    
    private var popularDishes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Popular Dishes")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            ForEach(shop.popularDishes, id: \.self) { dish in
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.accentOrange)
                    Text(dish)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.surface.opacity(0.4))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.8
                                )
                        )
                )
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Directions
            Button {
                showDirectionsMenu = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Get Directions")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(LinearGradient.kebabGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .accentGlow, radius: 12, x: 0, y: 4)
            }
            
            // Call
            if !shop.phone.isEmpty {
                Link(destination: URL(string: "tel:\(shop.phone.replacingOccurrences(of: " ", with: ""))")!) {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Call \(shop.phone)")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.surface.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
            }
            
            // Call Button
            if !shop.phone.isEmpty {
                Button {
                    let cleanPhone = shop.phone.filter { "0123456789+".contains($0) }
                    if let url = URL(string: "tel://\(cleanPhone)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Call Restaurant")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.openGreen.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .openGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            
            // Website / Attribution
            if !shop.website.isEmpty {
                let lowerUrl = shop.website.lowercased()
                
                if lowerUrl.contains("yelp") {
                    attributionBadge(text: "Authentic Kebab found via Yelp")
                } else if lowerUrl.contains("google") || lowerUrl.contains("maps") || lowerUrl.contains("osm") || lowerUrl.contains("openstreetmap") {
                    attributionBadge(text: "Authentic Kebab found via Maps")
                } else if lowerUrl.contains("foursquare") {
                    attributionBadge(text: "Authentic Kebab found via Foursquare")
                } else {
                    // Actual restaurant website
                    Link(destination: URL(string: shop.website.hasPrefix("http") ? shop.website : "https://\(shop.website)")!) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .font(.system(size: 16, weight: .semibold))
                            Text(shop.website)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.accentOrange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.accentOrange.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.accentOrange.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            
            // Verification Status & Actions
            VStack(spacing: 12) {
                // Verification Status
                HStack {
                    if favoritesManager.hasVerified(shop) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.openGreen)
                        
                        Text("You confirmed this place")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.openGreen)
                    } else {
                        Image(systemName: shop.isVerified ? "checkmark.shield.fill" : "clock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(shop.isVerified ? .openGreen : .orange)
                        
                        Text(shop.isVerified ? "Verified Place" : "Pending Verification")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(shop.isVerified ? .openGreen : .orange)
                    }
                    
                    Spacer()
                    
                    if !shop.isVerified {
                        Text("Needs \(confirmationsNeeded) more confirmation\(confirmationsNeeded == 1 ? "" : "s")")
                            .font(.system(size: 12))
                            .foregroundColor(.textMuted)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill((shop.isVerified || favoritesManager.hasVerified(shop) ? Color.openGreen : Color.orange).opacity(0.1))
                )
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Confirm Button (only if not verified by this device and not globally verified)
                    if !shop.isVerified && !favoritesManager.hasVerified(shop) {
                        Button {
                            showVerificationSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Confirm Exists")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.openGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    // Report Button (or Reported State)
                    if favoritesManager.hasReported(shop) {
                        HStack(spacing: 8) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Reported by You")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.closedRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.closedRed.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Button {
                            showReportSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Report")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.closedRed)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportPlaceView(shop: shop)
        }
        .sheet(isPresented: $showVerificationSheet) {
            SubmitVerificationView(shop: shop)
        }
    }
    
    // MARK: - Attribution Badge
    
    private func attributionBadge(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.accentOrange)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surface.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

// MARK: - Service Option

struct ServiceOption: View {
    let icon: String
    let title: String
    let available: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(title)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(available ? .textPrimary : .textMuted.opacity(0.5))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(available ? Color.surface.opacity(0.4) : Color.surface.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    available ? Color.white.opacity(0.1) : Color.white.opacity(0.04),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
        )
        .overlay(alignment: .topTrailing) {
            if available {
                Circle()
                    .fill(Color.openGreen)
                    .frame(width: 6, height: 6)
                    .offset(x: -6, y: 6)
            }
        }
    }
}

// MARK: - Info Card

struct InfoCard: View {
    let systemIcon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemIcon)
                .font(.system(size: 20))
                .foregroundColor(.accentOrange)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textMuted)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 14, opacity: 0.06, borderOpacity: 0.1)
    }
}

// MARK: - Navigation Action Button

struct NavigationActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}
