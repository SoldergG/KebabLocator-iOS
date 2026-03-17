import Foundation
import CoreLocation

class GooglePlacesService {
    static let shared = GooglePlacesService()
    
    private let apiKey = "AIzaSyC6KOmVTLqopKiYE1cN9kT23VoPBCahNRw"
    private let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    func searchKebabs(at coordinate: CLLocationCoordinate2D, radius: Double, pageToken: String? = nil, completion: @escaping ([KebabShop]) -> Void) {
        var components = URLComponents(string: baseURL)!
        var queryItems = [
            URLQueryItem(name: "location", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "\(Int(radius))"),
            URLQueryItem(name: "keyword", value: "kebab"),
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        if let token = pageToken {
            queryItems.append(URLQueryItem(name: "pagetoken", value: token))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let googleResponse = try JSONDecoder().decode(GoogleResponse.self, from: data)
                
                if googleResponse.status != "OK" {
                    print("Google API Status Error: \(googleResponse.status)")
                    if let errorMessage = googleResponse.errorMessage {
                        print("Google API Message: \(errorMessage)")
                    }
                    completion([])
                    return
                }
                
                let shops = googleResponse.results.map { result in
                    let photoReference = result.photos?.first?.photoReference
                    let imageUrl = photoReference != nil ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=\(photoReference!)&key=\(self.apiKey)" : ""
                    
                    return KebabShop(
                        id: result.placeId,
                        name: result.name,
                        rating: result.rating ?? 4.0,
                        reviews: result.userRatingsTotal ?? 0,
                        address: result.vicinity ?? "Unknown Address",
                        coordinate: CLLocationCoordinate2D(
                            latitude: result.geometry.location.lat,
                            longitude: result.geometry.location.lng
                        ),
                        tags: ["Kebab", "Google"],
                        price: String(repeating: "€", count: result.priceLevel ?? 2),
                        hours: "Open Now",
                        openHour: 11,
                        closeHour: 23,
                        description: "Found via Google Places.",
                        imageName: imageUrl,
                        category: .doner,
                        phone: "", // Need Place Details for phone
                        website: "", // Need Place Details for website
                        popularDishes: ["Döner"],
                        hasDelivery: true,
                        hasDineIn: true,
                        hasTakeaway: true
                    )
                }
                completion(shops)
            } catch {
                print("Google Decoding Error: \(error)")
                completion([])
            }
        }.resume()
    }
}

// MARK: - Google API Models

struct GoogleResponse: Codable {
    let status: String
    let errorMessage: String?
    let results: [GoogleResult]
    let nextPageToken: String?
    
    enum CodingKeys: String, CodingKey {
        case status, results
        case errorMessage = "error_message"
        case nextPageToken = "next_page_token"
    }
}

struct GoogleResult: Codable {
    let placeId: String
    let name: String
    let rating: Double?
    let userRatingsTotal: Int?
    let vicinity: String?
    let priceLevel: Int?
    let geometry: GoogleGeometry
    let photos: [GooglePhoto]?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name, rating, vicinity, geometry, photos
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
    }
}

struct GoogleGeometry: Codable {
    let location: GoogleLocation
}

struct GoogleLocation: Codable {
    let lat: Double
    let lng: Double
}

struct GooglePhoto: Codable {
    let photoReference: String
    
    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}
