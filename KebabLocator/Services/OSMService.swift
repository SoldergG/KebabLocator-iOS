import Foundation
import CoreLocation

class OSMService {
    static let shared = OSMService()
    
    private let baseURL = "https://overpass-api.de/api/interpreter"
    
    func searchKebabs(at coordinate: CLLocationCoordinate2D, radius: Double, completion: @escaping ([KebabShop]) -> Void) {
        let query = """
        [out:json];
        (
          node["amenity"="fast_food"]["cuisine"~"kebab"](around:\(radius),\(coordinate.latitude),\(coordinate.longitude));
          way["amenity"="fast_food"]["cuisine"~"kebab"](around:\(radius),\(coordinate.latitude),\(coordinate.longitude));
          node["restaurant"]["cuisine"~"kebab"](around:\(radius),\(coordinate.latitude),\(coordinate.longitude));
          way["restaurant"]["cuisine"~"kebab"](around:\(radius),\(coordinate.latitude),\(coordinate.longitude));
        );
        out body;
        >;
        out skel qt;
        """
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [URLQueryItem(name: "data", value: query)]
        
        guard let url = components.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let osmResponse = try JSONDecoder().decode(OSMResponse.self, from: data)
                let shops = osmResponse.elements.compactMap { element -> KebabShop? in
                    guard let name = element.tags?["name"] else { return nil }
                    
                    let lat = element.lat ?? 0.0
                    let lon = element.lon ?? 0.0
                    
                    return KebabShop(
                        id: "osm-\(element.id)",
                        name: name,
                        rating: 4.2, // OSM doesn't have ratings
                        reviews: 10,
                        address: element.tags?["addr:street"] ?? "Street unknown",
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        tags: ["Kebab", "OSM"],
                        price: "€",
                        hours: element.tags?["opening_hours"] ?? "Open Now",
                        openHour: 11,
                        closeHour: 23,
                        description: "Community-sourced kebab via OpenStreetMap.",
                        imageName: "kebab_hero", // Fallback
                        category: .doner,
                        phone: element.tags?["phone"] ?? "",
                        website: element.tags?["website"] ?? "",
                        popularDishes: ["Döner"],
                        hasDelivery: true,
                        hasDineIn: true,
                        hasTakeaway: true
                    )
                }
                completion(shops)
            } catch {
                print("OSM Decoding Error: \(error)")
                completion([])
            }
        }.resume()
    }
}

// MARK: - OSM API Models

struct OSMResponse: Codable {
    let elements: [OSMElement]
}

struct OSMElement: Codable {
    let id: Int
    let type: String
    let lat: Double?
    let lon: Double?
    let tags: [String: String]?
}
