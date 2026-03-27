import SwiftUI
import WidgetKit

// MARK: - Small Widget View

struct KebabSmallWidgetView: View {
    var entry: KebabProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // Background
            Color.black
            
            VStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.accentOrange.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentOrange)
                }
                
                // Count
                Text("\(entry.nearbyCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("kebab spots")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Medium Widget View

struct KebabMediumWidgetView: View {
    var entry: KebabProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            
            HStack(spacing: 16) {
                // Left side - Icon and count
                VStack(spacing: 4) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.accentOrange)
                    
                    Text("\(entry.nearbyCount)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("nearby")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .frame(width: 80)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Right side - Top rated
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Rated")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    if let shop = entry.nearestShop {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(shop.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.starYellow)
                                Text(String(format: "%.1f", shop.rating))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.starYellow)
                                
                                if shop.isOpen {
                                    Text("• Open")
                                        .font(.system(size: 10))
                                        .foregroundColor(.openGreen)
                                } else {
                                    Text("• Closed")
                                        .font(.system(size: 10))
                                        .foregroundColor(.closedRed)
                                }
                            }
                        }
                    } else {
                        Text("No shops nearby")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Large Widget View

struct KebabLargeWidgetView: View {
    var entry: KebabProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentOrange)
                    
                    Text("Kebab Locator")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(entry.nearbyCount) spots")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Shops list
                VStack(spacing: 0) {
                    ForEach(Array(entry.topShops.prefix(4).enumerated()), id: \.element.id) { index, shop in
                        ShopRowView(shop: shop, index: index + 1)
                        
                        if index < min(entry.topShops.count, 4) - 1 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Shop Row View

struct ShopRowView: View {
    let shop: SimpleKebabShop
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(Color.accentOrange.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Text("\(index)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.accentOrange)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(shop.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.starYellow)
                        Text(String(format: "%.1f", shop.rating))
                            .font(.system(size: 11))
                            .foregroundColor(.starYellow)
                    }
                    
                    if shop.isOpen {
                        Text("Open")
                            .font(.system(size: 10))
                            .foregroundColor(.openGreen)
                    } else {
                        Text("Closed")
                            .font(.system(size: 10))
                            .foregroundColor(.closedRed)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Widget Bundle

@main
struct KebabLocatorWidgets: WidgetBundle {
    var body: some Widget {
        KebabLocatorWidget()
        KebabLocatorMediumWidget()
        KebabLocatorLargeWidget()
    }
}

// MARK: - Individual Widgets

struct KebabLocatorWidget: Widget {
    let kind: String = "KebabLocatorSmall"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KebabProvider()) { entry in
            KebabSmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Kebab Count")
        .description("Shows the number of nearby kebab shops.")
        .supportedFamilies([.systemSmall])
    }
}

struct KebabLocatorMediumWidget: Widget {
    let kind: String = "KebabLocatorMedium"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KebabProvider()) { entry in
            KebabMediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Top Kebab")
        .description("Shows the top rated nearby kebab shop.")
        .supportedFamilies([.systemMedium])
    }
}

struct KebabLocatorLargeWidget: Widget {
    let kind: String = "KebabLocatorLarge"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KebabProvider()) { entry in
            KebabLargeWidgetView(entry: entry)
        }
        .configurationDisplayName("Top Rated List")
        .description("Shows a list of top rated kebab shops.")
        .supportedFamilies([.systemLarge])
    }
}
