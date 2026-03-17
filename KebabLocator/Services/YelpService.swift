import Foundation
import CoreLocation

class YelpService {
    static let shared = YelpService()
    
    private let apiKey = "z-CN92M6Fl60au3W0uFPGZ0TEKEHIWr0q_HbQCNNYUdfpiOm6MKZZuhl-jg5FI4QH9YzOrQNrdUs_MKal_2cdbDF_kqQlE5Qh0xnVJvTjMkg-3zezISiahtgTna4aXYx"
    private let baseURL = "https://api.yelp.com/v3/businesses/search"
    
    func searchKebabs(at coordinate: CLLocationCoordinate2D, radius: Double, completion: @escaping ([KebabShop]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var allShops: [KebabShop] = []
        let lock = NSLock()
        
        // Fetch 2 pages (100 results)
        for offset in [0, 50] {
            dispatchGroup.enter()
            var components = URLComponents(string: baseURL)!
            components.queryItems = [
                URLQueryItem(name: "term", value: "kebab"),
                URLQueryItem(name: "latitude", value: "\(coordinate.latitude)"),
                URLQueryItem(name: "longitude", value: "\(coordinate.longitude)"),
                URLQueryItem(name: "radius", value: "\(Int(radius))"),
                URLQueryItem(name: "limit", value: "50"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "sort_by", value: "best_match")
            ]
            
            guard let url = components.url else { 
                dispatchGroup.leave()
                continue 
            }
            
            var request = URLRequest(url: url)
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { dispatchGroup.leave() }
                guard let data = data, error == nil else { return }
                
                do {
                    let yelpResponse = try JSONDecoder().decode(YelpResponse.self, from: data)
                    let shops = yelpResponse.businesses.map { business in
                        KebabShop(
                            id: business.id,
                            name: business.name,
                            rating: business.rating,
                            reviews: business.reviewCount,
                            address: business.location.address1 ?? business.location.city,
                            coordinate: CLLocationCoordinate2D(
                                latitude: business.coordinates.latitude,
                                longitude: business.coordinates.longitude
                            ),
                            tags: business.categories.map { $0.title },
                            price: business.price?.replacingOccurrences(of: "$", with: "€") ?? "€€",
                            hours: "Open Now",
                            openHour: 11,
                            closeHour: 23,
                            description: "Authentic Kebab found via Yelp.",
                            imageName: business.imageUrl,
                            category: .doner,
                            phone: business.displayPhone ?? "",
                            website: business.url,
                            popularDishes: ["Kebab", "Fries"],
                            hasDelivery: true,
                            hasDineIn: true,
                            hasTakeaway: true
                        )
                    }
                    lock.lock()
                    allShops.append(contentsOf: shops)
                    lock.unlock()
                } catch {
                    print("Yelp Decoding Error: \(error)")
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(allShops)
        }
    }
}

// MARK: - Yelp API Models

struct YelpResponse: Codable {
    let businesses: [YelpBusiness]
}

struct YelpBusiness: Codable {
    let id: String
    let name: String
    let imageUrl: String
    let url: String
    let reviewCount: Int
    let categories: [YelpCategory]
    let rating: Double
    let coordinates: YelpCoordinates
    let location: YelpLocation
    let displayPhone: String?
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, categories, rating, coordinates, location, price
        case imageUrl = "image_url"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
    }
}

struct YelpCategory: Codable {
    let alias: String
    let title: String
}

struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct YelpLocation: Codable {
    let address1: String?
    let city: String
    let zipCode: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case address1, city, country
        case zipCode = "zip_code"
    }
}
