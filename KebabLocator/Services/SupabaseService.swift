import Foundation
import CoreLocation

class SupabaseService {
    static let shared = SupabaseService()
    
    private let supabaseUrl = "https://omwvsocbyqqriictjyfx.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9td3Zzb2NieXFxcmlpY3RqeWZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3NTU3NjMsImV4cCI6MjA4OTMzMTc2M30.621TXLX7f3oYQ0wMI6W_-fAG8041TwOVilLASvlqT-8"
    
    func fetchShops(completion: @escaping ([KebabShop]) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/kebab_shops?select=*") else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let dbShops = try JSONDecoder().decode([SupabaseShop].self, from: data)
                let shops = dbShops.map { db in
                    KebabShop(
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
                        hasTakeaway: db.has_takeaway
                    )
                }
                completion(shops)
            } catch {
                print("Supabase Fetch Error: \(error)")
                completion([])
            }
        }.resume()
    }
}

struct SupabaseShop: Codable {
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
}
