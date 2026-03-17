import Foundation
import CoreLocation

class FoursquareService {
    static let shared = FoursquareService()
    
    // NOTE: Foursquare requires an API Key.
    // User should get one at: https://location.foursquare.com/developer/
    private let apiKey = "fsq3YOUR_KEY_HERE" 
    private let baseURL = "https://api.foursquare.com/v3/places/search"
    
    func searchKebabs(at coordinate: CLLocationCoordinate2D, radius: Double, completion: @escaping ([KebabShop]) -> Void) {
        // If user hasn't provided a key, don't fail, just return empty
        guard apiKey != "fsq3YOUR_KEY_HERE" else {
            completion([])
            return
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "query", value: "kebab"),
            URLQueryItem(name: "categories", value: "13000"), // Dining and Drinking
            URLQueryItem(name: "radius", value: "\(Int(radius))"),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "fields", value: "fsq_id,name,rating,stats,location,geocodes,photos,price,tel,website,hours")
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let fsqResponse = try JSONDecoder().decode(FoursquareResponse.self, from: data)
                let shops = fsqResponse.results.map { result in
                    let photoSuffix = result.photos?.first?.suffix
                    let photoPrefix = result.photos?.first?.prefix
                    let imageUrl = (photoPrefix != nil && photoSuffix != nil) ? "\(photoPrefix!)original\(photoSuffix!)" : ""
                    
                    return KebabShop(
                        id: "fsq-\(result.fsqId)",
                        name: result.name,
                        rating: (result.rating ?? 80.0) / 20.0, // Foursquare is 0-10, we want 0-5
                        reviews: result.stats?.totalRatings ?? 0,
                        address: result.location.address ?? result.location.formattedAddress ?? "Unknown",
                        coordinate: CLLocationCoordinate2D(
                            latitude: result.geocodes.main.latitude,
                            longitude: result.geocodes.main.longitude
                        ),
                        tags: ["Kebab", "Foursquare"],
                        price: String(repeating: "€", count: result.price ?? 2),
                        hours: result.hours?.display ?? "Open Now",
                        openHour: 11,
                        closeHour: 23,
                        description: "Kebab spot verified via Foursquare.",
                        imageName: imageUrl,
                        category: .doner,
                        phone: result.tel ?? "",
                        website: result.website ?? "",
                        popularDishes: ["Mixed Kebab"],
                        hasDelivery: true,
                        hasDineIn: true,
                        hasTakeaway: true
                    )
                }
                completion(shops)
            } catch {
                print("Foursquare Decoding Error: \(error)")
                completion([])
            }
        }.resume()
    }
}

// MARK: - Foursquare API Models

struct FoursquareResponse: Codable {
    let results: [FoursquareResult]
}

struct FoursquareResult: Codable {
    let fsqId: String
    let name: String
    let rating: Double?
    let stats: FoursquareStats?
    let location: FoursquareLocation
    let geocodes: FoursquareGeocodes
    let photos: [FoursquarePhoto]?
    let price: Int?
    let tel: String?
    let website: String?
    let hours: FoursquareHours?
    
    enum CodingKeys: String, CodingKey {
        case name, rating, stats, location, geocodes, photos, price, tel, website, hours
        case fsqId = "fsq_id"
    }
}

struct FoursquareStats: Codable {
    let totalRatings: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalRatings = "total_ratings"
    }
}

struct FoursquareLocation: Codable {
    let address: String?
    let formattedAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case formattedAddress = "formatted_address"
    }
}

struct FoursquareGeocodes: Codable {
    let main: FoursquareLatLng
}

struct FoursquareLatLng: Codable {
    let latitude: Double
    let longitude: Double
}

struct FoursquarePhoto: Codable {
    let prefix: String
    let suffix: String
}

struct FoursquareHours: Codable {
    let display: String?
}
