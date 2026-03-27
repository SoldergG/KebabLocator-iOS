import Foundation
import SwiftUI
import CoreLocation

// MARK: - Favorites Manager

class FavoritesManager: ObservableObject {
    @Published var favoriteIDs: Set<String> {
        didSet {
            saveFavorites()
        }
    }
    
    // Shop Data Manager properties
    @Published var allShops: [KebabShop] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var lastFetch: Date?
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    let supabaseUrl = "https://omwvsocbyqqriictjyfx.supabase.co"
    let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9td3Zzb2NieXFxcmlpY3RqeWZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3NTU3NjMsImV4cCI6MjA4OTMzMTc2M30.621TXLX7f3oYQ0wMI6W_-fAG8041TwOVilLASvlqT-8"
    
    private let key = "kebab_favorites"
    private let cachedShopsKey = "cached_supabase_shops"
    private let verifiedKey = "verified_place_ids"
    private let reportedKey = "reported_place_ids"
    
    @Published var verifiedPlaceIDs: Set<String> = []
    @Published var reportedPlaceIDs: Set<String> = []
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteIDs = ids
        } else {
            favoriteIDs = []
        }
        
        // Load verified places
        if let data = UserDefaults.standard.data(forKey: verifiedKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            verifiedPlaceIDs = ids
        }
        
        // Load reported places
        if let data = UserDefaults.standard.data(forKey: reportedKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            reportedPlaceIDs = ids
        }
        
        // Load cached shops immediately
        loadCachedShops()
    }
    
    func hasVerified(_ shop: KebabShop) -> Bool {
        verifiedPlaceIDs.contains(shop.id)
    }
    
    private func markAsVerified(_ shopId: String) {
        verifiedPlaceIDs.insert(shopId)
        if let data = try? JSONEncoder().encode(verifiedPlaceIDs) {
            UserDefaults.standard.set(data, forKey: verifiedKey)
        }
    }
    
    func hasReported(_ shop: KebabShop) -> Bool {
        reportedPlaceIDs.contains(shop.id)
    }
    
    private func markAsReported(_ shopId: String) {
        reportedPlaceIDs.insert(shopId)
        if let data = try? JSONEncoder().encode(reportedPlaceIDs) {
            UserDefaults.standard.set(data, forKey: reportedKey)
        }
    }
    
    // MARK: - Shop Data Methods
    
    func fetchShops(forceRefresh: Bool = false) {
        if !forceRefresh, 
           let lastFetch = lastFetch,
           Date().timeIntervalSince(lastFetch) < cacheDuration,
           !allShops.isEmpty {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/kebab_shops?select=*&is_active=eq.true&order=is_sponsored.desc,rating.desc") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let dbShops = try JSONDecoder().decode([SupabaseShopData].self, from: data)
                    self.allShops = dbShops.map { self.convertToKebabShop($0) }
                    self.lastFetch = Date()
                    self.cacheShops()
                } catch {
                    self.errorMessage = "Decode error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func getFavoriteShops(ids: Set<String>, additionalShops: [KebabShop] = []) -> [KebabShop] {
        let combined = allShops + additionalShops
        // De-duplicate by id, preferring allShops (Supabase) entries
        var seen = Set<String>()
        var unique: [KebabShop] = []
        for shop in combined {
            if !seen.contains(shop.id) {
                seen.insert(shop.id)
                unique.append(shop)
            }
        }
        return unique.filter { ids.contains($0.id) }
    }
    
    func submitShop(
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        description: String,
        category: KebabCategory,
        phone: String?,
        website: String?,
        hours: String,
        openHour: Int,
        closeHour: Int,
        price: String,
        tags: [String],
        hasDelivery: Bool,
        hasDineIn: Bool,
        hasTakeaway: Bool,
        imageData: Data?,
        completion: @escaping (Bool, String?) -> Void
    ) {
        // First upload image if provided
        var imageUrl: String?
        let group = DispatchGroup()
        
        if let imageData = imageData {
            group.enter()
            uploadPhoto(image: imageData) { url in
                imageUrl = url
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            let shop = SupabaseShopData(
                id: UUID().uuidString,
                name: name,
                rating: 0,
                reviews: 0,
                address: address,
                latitude: latitude,
                longitude: longitude,
                tags: tags,
                price: price,
                hours: hours,
                open_hour: openHour,
                close_hour: closeHour,
                description: description,
                category: category.rawValue,
                phone: phone,
                website: website,
                popular_dishes: ["Kebab"],
                has_delivery: hasDelivery,
                has_dine_in: hasDineIn,
                has_takeaway: hasTakeaway,
                image_url: imageUrl,
                is_sponsored: false,
                is_verified: false,
                contributor_id: nil,
                is_active: true
            )
            
            self.submitShopToSupabase(shop: shop, completion: completion)
        }
    }
    
    private func submitShopToSupabase(shop: SupabaseShopData, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/kebab_shops") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        do {
            request.httpBody = try JSONEncoder().encode(shop)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(false, error.localizedDescription)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        completion(true, nil)
                    } else {
                        completion(false, "Server error")
                    }
                }
            }.resume()
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    private func uploadPhoto(image: Data, completion: @escaping (String?) -> Void) {
        let fileName = "\(UUID().uuidString).jpg"
        guard let url = URL(string: "\(supabaseUrl)/storage/v1/object/shop-photos/\(fileName)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = image
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            let publicUrl = "\(self.supabaseUrl)/storage/v1/object/public/shop-photos/\(fileName)"
            completion(publicUrl)
        }.resume()
    }
    
    private func convertToKebabShop(_ db: SupabaseShopData) -> KebabShop {
        return KebabShop(
            id: db.id,
            name: db.name,
            rating: db.rating,
            reviews: db.reviews,
            address: db.address,
            coordinate: CLLocationCoordinate2D(latitude: db.latitude, longitude: db.longitude),
            tags: db.tags,
            price: db.price,
            hours: db.hours,
            openHour: db.open_hour,
            closeHour: db.close_hour,
            description: db.description,
            imageName: "kebab_hero",
            category: KebabCategory(rawValue: db.category) ?? .doner,
            phone: db.phone ?? "",
            website: db.website ?? "",
            popularDishes: db.popular_dishes,
            hasDelivery: db.has_delivery,
            hasDineIn: db.has_dine_in,
            hasTakeaway: db.has_takeaway,
            isSponsored: db.is_sponsored ?? false,
            isVerified: db.is_verified ?? false,
            contributorId: db.contributor_id,
            imageUrl: db.image_url
        )
    }
    
    // MARK: - Caching
    
    private func cacheShops() {
        do {
            let data = try JSONEncoder().encode(allShops)
            UserDefaults.standard.set(data, forKey: cachedShopsKey)
        } catch {
            print("Cache save error: \(error)")
        }
    }
    
    private func loadCachedShops() {
        guard let data = UserDefaults.standard.data(forKey: cachedShopsKey) else { return }
        do {
            let shops = try JSONDecoder().decode([KebabShop].self, from: data)
            self.allShops = shops
        } catch {
            print("Cache load error: \(error)")
        }
    }
    
    // MARK: - Favorites Methods
    
    func isFavorite(_ shop: KebabShop) -> Bool {
        favoriteIDs.contains(shop.id)
    }
    
    func toggle(_ shop: KebabShop) {
        if favoriteIDs.contains(shop.id) {
            favoriteIDs.remove(shop.id)
        } else {
            favoriteIDs.insert(shop.id)
        }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIDs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // MARK: - Submissions
    
    func submitVerification(shop: KebabShop, completion: @escaping (Bool) -> Void) {
        // Check if already verified by this device
        if hasVerified(shop) {
            completion(false)
            return
        }
        
        // Check if the shop exists in our database
        let isInternal = allShops.contains { $0.id == shop.id }
        
        if isInternal {
            callVerificationRPC(placeId: shop.id) { [weak self] success in
                if success {
                    self?.markAsVerified(shop.id)
                }
                completion(success)
            }
        } else {
            submitShop(
                name: shop.name,
                address: shop.address,
                latitude: shop.coordinate.latitude,
                longitude: shop.coordinate.longitude,
                description: shop.description,
                category: shop.category,
                phone: shop.phone,
                website: shop.website,
                hours: shop.hours,
                openHour: shop.openHour,
                closeHour: shop.closeHour,
                price: shop.price,
                tags: shop.tags,
                hasDelivery: shop.hasDelivery,
                hasDineIn: shop.hasDineIn,
                hasTakeaway: shop.hasTakeaway,
                imageData: nil
            ) { [weak self] success, _ in
                if success {
                    self?.markAsVerified(shop.id)
                }
                completion(success)
            }
        }
    }
    
    private func callVerificationRPC(placeId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/rpc/submit_place_verification") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "p_place_id": placeId,
            "p_submitter_id": NSNull()
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        completion(true)
                    } else {
                        // Log error for debugging if needed
                        if let data = data, let msg = String(data: data, encoding: .utf8) {
                            print("Verification RPC Error: \(msg)")
                        }
                        completion(false)
                    }
                }
            }.resume()
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Report Submission
    
    func submitReport(shop: KebabShop, reason: String, description: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/place_reports") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let body: [String: Any] = [
            "place_id": shop.id,
            "reason": reason,
            "description": description
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        self.markAsReported(shop.id)
                        completion(true)
                    } else {
                        if let data = data, let msg = String(data: data, encoding: .utf8) {
                            print("Report Error: \(msg)")
                        }
                        completion(false)
                    }
                }
            }.resume()
        } catch {
            completion(false)
        }
    }
}

// MARK: - Supabase Shop Data Model

struct SupabaseShopData: Codable {
    let id: String
    let name: String
    let rating: Double
    let reviews: Int
    let address: String
    let latitude: Double
    let longitude: Double
    let tags: [String]
    let price: String
    let hours: String
    let open_hour: Int
    let close_hour: Int
    let description: String
    let category: String
    let phone: String?
    let website: String?
    let popular_dishes: [String]
    let has_delivery: Bool
    let has_dine_in: Bool
    let has_takeaway: Bool
    let image_url: String?
    let is_sponsored: Bool?
    let is_verified: Bool?
    let contributor_id: String?
    let is_active: Bool?
}
