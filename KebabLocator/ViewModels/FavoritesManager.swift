import Foundation
import SwiftUI

// MARK: - Favorites Manager

class FavoritesManager: ObservableObject {
    @Published var favoriteIDs: Set<String> {
        didSet {
            saveFavorites()
        }
    }
    
    private let key = "kebab_favorites"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteIDs = ids
        } else {
            favoriteIDs = []
        }
    }
    
    func isFavorite(_ shop: KebabShop) -> Bool {
        favoriteIDs.contains(shop.id)
    }
    
    func toggle(_ shop: KebabShop) {
        if favoriteIDs.contains(shop.id) {
            favoriteIDs.remove(shop.id)
        } else {
            favoriteIDs.insert(shop.id)
        }
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func favorites(from shops: [KebabShop]) -> [KebabShop] {
        shops.filter { favoriteIDs.contains($0.id) }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIDs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
