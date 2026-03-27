import WidgetKit
import SwiftUI

// MARK: - Widget Data Provider

struct KebabProvider: TimelineProvider {
    func placeholder(in context: Context) -> KebabEntry {
        KebabEntry(
            date: Date(),
            nearbyCount: 5,
            topShops: [],
            nearestShop: nil,
            userLocation: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (KebabEntry) -> Void) {
        let entry = loadWidgetData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<KebabEntry>) -> Void) {
        let entry = loadWidgetData()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadWidgetData() -> KebabEntry {
        let defaults = UserDefaults(suiteName: "group.com.kebablocator.app")
        
        // Load total shops count
        let totalShops = defaults?.integer(forKey: "widget_total_shops") ?? 0
        
        // Load top shops
        var topShops: [SimpleKebabShop] = []
        if let data = defaults?.data(forKey: "widget_top_shops"),
           let shops = try? JSONDecoder().decode([KebabShop].self, from: data) {
            topShops = shops.map { SimpleKebabShop(from: $0) }
        }
        
        return KebabEntry(
            date: Date(),
            nearbyCount: totalShops,
            topShops: topShops,
            nearestShop: topShops.first,
            userLocation: nil
        )
    }
}

// MARK: - Widget Entry

struct KebabEntry: TimelineEntry {
    let date: Date
    let nearbyCount: Int
    let topShops: [SimpleKebabShop]
    let nearestShop: SimpleKebabShop?
    let userLocation: SimpleLocation?
}

// MARK: - Simple Models for Widget

struct SimpleKebabShop: Identifiable, Codable {
    let id: String
    let name: String
    let rating: Double
    let address: String
    let isOpen: Bool
    let distance: String?
    
    init(from shop: KebabShop) {
        self.id = shop.id
        self.name = shop.name
        self.rating = shop.rating
        self.address = shop.address
        self.isOpen = shop.isOpenNow
        self.distance = nil
    }
    
    init(id: String, name: String, rating: Double, address: String, isOpen: Bool, distance: String? = nil) {
        self.id = id
        self.name = name
        self.rating = rating
        self.address = address
        self.isOpen = isOpen
        self.distance = distance
    }
}

struct SimpleLocation: Codable {
    let latitude: Double
    let longitude: Double
}
