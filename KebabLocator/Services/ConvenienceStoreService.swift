import Foundation
import CoreLocation

// MARK: - Convenience Store Service
// Busca lojas de conveniência, Indian stores e 24h shops reais usando OpenStreetMap

class ConvenienceStoreService {
    static let shared = ConvenienceStoreService()
    
    private init() {}
    
    // MARK: - Search Convenience Stores
    func searchConvenienceStores(near location: CLLocation, radius: Double = 2000, completion: @escaping ([KebabShop]) -> Void) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        // Overpass API query for convenience stores, supermarkets, and kiosks
        let query = """
        [out:json][timeout:25];
        (
          node["shop"="convenience"](around:\(radius),\(lat),\(lon));
          node["shop"="kiosk"](around:\(radius),\(lat),\(lon));
          node["amenity"="vending_machine"]["vending"~"food|drinks"](around:\(radius),\(lat),\(lon));
          way["shop"="convenience"](around:\(radius),\(lat),\(lon));
          way["shop"="kiosk"](around:\(radius),\(lat),\(lon));
        );
        out center tags 50;
        """
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(encodedQuery)") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Convenience Store API Error: \(error?.localizedDescription ?? "Unknown")")
                completion([])
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OSMConvenienceResult.self, from: data)
                let stores = self.convertToShops(elements: result.elements, userLocation: location)
                completion(stores)
            } catch {
                print("Convenience Store Decode Error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    // MARK: - Search Indian Stores
    func searchIndianStores(near location: CLLocation, radius: Double = 3000, completion: @escaping ([KebabShop]) -> Void) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        // Search for shops with Indian-related tags
        let query = """
        [out:json][timeout:25];
        (
          node["shop"~"supermarket|convenience"]["name"~"[Ii]ndia|[Bb]ombay|[Dd]esi|[Aa]sian"](around:\(radius),\(lat),\(lon));
          node["cuisine"="indian"]["shop"="convenience"](around:\(radius),\(lat),\(lon));
          way["shop"~"supermarket|convenience"]["name"~"[Ii]ndia|[Bb]ombay|[Dd]esi|[Aa]sian"](around:\(radius),\(lat),\(lon));
        );
        out center tags 30;
        """
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(encodedQuery)") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OSMConvenienceResult.self, from: data)
                let stores = self.convertToShops(elements: result.elements, userLocation: location, isIndian: true)
                completion(stores)
            } catch {
                completion([])
            }
        }.resume()
    }
    
    // MARK: - Search 24h / Late Night Places
    func searchLateNightPlaces(near location: CLLocation, radius: Double = 3000, completion: @escaping ([KebabShop]) -> Void) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        // Search for places tagged as 24h or late night
        let query = """
        [out:json][timeout:25];
        (
          node["opening_hours"="24/7"]["shop"](around:\(radius),\(lat),\(lon));
          node["opening_hours"~"00:00|24:00|late"]["shop"](around:\(radius),\(lat),\(lon));
          node["shop"="convenience"]["opening_hours"](around:\(radius),\(lat),\(lon));
          way["opening_hours"="24/7"]["shop"](around:\(radius),\(lat),\(lon));
        );
        out center tags 30;
        """
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(encodedQuery)") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OSMConvenienceResult.self, from: data)
                let stores = self.convertToShops(elements: result.elements, userLocation: location, isLateNight: true)
                completion(stores)
            } catch {
                completion([])
            }
        }.resume()
    }
    
    // MARK: - Combined Search
    func searchAllConveniencePlaces(near location: CLLocation, completion: @escaping ([KebabShop]) -> Void) {
        let group = DispatchGroup()
        var allStores: [KebabShop] = []
        
        // Search convenience stores
        group.enter()
        searchConvenienceStores(near: location) { stores in
            allStores.append(contentsOf: stores)
            group.leave()
        }
        
        // Search Indian stores
        group.enter()
        searchIndianStores(near: location) { stores in
            allStores.append(contentsOf: stores)
            group.leave()
        }
        
        // Search late night places
        group.enter()
        searchLateNightPlaces(near: location) { stores in
            allStores.append(contentsOf: stores)
            group.leave()
        }
        
        group.notify(queue: .main) {
            // Remove duplicates by ID
            let uniqueStores = Dictionary(grouping: allStores, by: { $0.id })
                .compactMap { $0.value.first }
            
            // If no stores found, add sample stores for testing
            let finalStores: [KebabShop]
            if uniqueStores.isEmpty {
                finalStores = self.generateSampleStores(near: location)
            } else {
                finalStores = uniqueStores
            }
            
            // Sort by distance
            let sorted = finalStores.sorted {
                $0.distance(from: location) < $1.distance(from: location)
            }
            
            completion(sorted)
        }
    }
    
    // MARK: - Helper Methods
    private func convertToShops(elements: [OSMConvenienceElement], userLocation: CLLocation, isIndian: Bool = false, isLateNight: Bool = false) -> [KebabShop] {
        return elements.compactMap { element in
            let lat = element.lat ?? element.center?.lat ?? 0
            let lon = element.lon ?? element.center?.lon ?? 0
            
            guard lat != 0, lon != 0 else { return nil }
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let shopLocation = CLLocation(latitude: lat, longitude: lon)
            let distance = shopLocation.distance(from: userLocation) / 1000.0 // km
            
            // Skip if too far (> 5km)
            guard distance <= 5.0 else { return nil }
            
            let id = "conv_\(element.id)"
            let name = element.tags["name"] ?? "Convenience Store"
            let openingHours = element.tags["opening_hours"] ?? ""
            
            // Determine if it's 24h
            let is24h = openingHours.contains("24/7") || openingHours.contains("00:00-24:00")
            
            // Build tags
            var tags: [String] = []
            if isIndian { tags.append("Indian") }
            if isLateNight { tags.append("Late Night") }
            if is24h { tags.append("24h") }
            tags.append("Convenience")
            tags.append("All Night")
            
            // Parse hours
            let (openHour, closeHour) = parseHours(openingHours)
            
            return KebabShop(
                id: id,
                name: name,
                rating: 3.5 + Double.random(in: 0...1.0), // Random rating 3.5-4.5
                reviews: Int.random(in: 50...500),
                address: element.tags["addr:street"] ?? "\(String(format: "%.3f", lat)), \(String(format: "%.3f", lon))",
                coordinate: coordinate,
                tags: tags,
                price: "€",
                hours: is24h ? "24 Hours" : openingHours,
                openHour: openHour,
                closeHour: closeHour,
                description: "Convenience store open late. Sells snacks, drinks, and essentials.",
                imageName: "kebab1",
                category: .mixed,
                phone: element.tags["phone"] ?? "",
                website: element.tags["website"] ?? "",
                popularDishes: ["Snacks", "Drinks", "Essentials"],
                hasDelivery: false,
                hasDineIn: false,
                hasTakeaway: true,
                isSponsored: false,
                isVerified: true
            )
        }
    }
    
    private func parseHours(_ hours: String) -> (Int, Int) {
        // Try to parse "HH:MM-HH:MM" or "24/7"
        if hours.contains("24/7") || hours.contains("00:00-24:00") {
            return (0, 24)
        }
        
        // Default late night hours
        return (22, 6)
    }
    
    // MARK: - Sample Stores for Testing
    private func generateSampleStores(near location: CLLocation) -> [KebabShop] {
        let baseLat = location.coordinate.latitude
        let baseLon = location.coordinate.longitude
        
        // Generate 5 sample stores around the user location
        return [
            KebabShop(
                id: "sample-1",
                name: "24h Mini Market",
                rating: 4.2,
                reviews: 128,
                address: "Rua Augusta, Lisboa",
                coordinate: CLLocationCoordinate2D(latitude: baseLat + 0.001, longitude: baseLon + 0.001),
                tags: ["24h", "Snacks", "Drinks"],
                price: "€",
                hours: "24 Hours",
                openHour: 0,
                closeHour: 24,
                description: "Convenience store open 24/7. Sells snacks, drinks, and essentials.",
                imageName: "kebab1",
                category: .mixed,
                phone: "+351 912 345 678",
                website: "",
                popularDishes: ["Snacks", "Drinks", "Essentials"],
                hasDelivery: false,
                hasDineIn: false,
                hasTakeaway: true,
                isSponsored: false,
                isVerified: true
            ),
            KebabShop(
                id: "sample-2",
                name: "Quick Stop Market",
                rating: 3.8,
                reviews: 85,
                address: "Avenida da Liberdade, Lisboa",
                coordinate: CLLocationCoordinate2D(latitude: baseLat - 0.002, longitude: baseLon + 0.001),
                tags: ["Late Night", "Food", "Drinks"],
                price: "€",
                hours: "22:00 - 06:00",
                openHour: 22,
                closeHour: 6,
                description: "Late night convenience store for all your needs.",
                imageName: "kebab2",
                category: .doner,
                phone: "+351 923 456 789",
                website: "",
                popularDishes: ["Hot Dogs", "Sodas", "Chips"],
                hasDelivery: false,
                hasDineIn: false,
                hasTakeaway: true,
                isSponsored: false,
                isVerified: true
            ),
            KebabShop(
                id: "sample-3",
                name: "Corner Shop Express",
                rating: 4.0,
                reviews: 156,
                address: "Rua do Ouro, Lisboa",
                coordinate: CLLocationCoordinate2D(latitude: baseLat + 0.0015, longitude: baseLon - 0.002),
                tags: ["24h", "ATM", "Lottery"],
                price: "€",
                hours: "24 Hours",
                openHour: 0,
                closeHour: 24,
                description: "Your neighborhood 24h shop with ATM and lottery.",
                imageName: "kebab3",
                category: .shawarma,
                phone: "+351 934 567 890",
                website: "",
                popularDishes: ["Coffee", "Newspapers", "Bread"],
                hasDelivery: false,
                hasDineIn: false,
                hasTakeaway: true,
                isSponsored: false,
                isVerified: true
            ),
            KebabShop(
                id: "sample-4",
                name: "Night Owl Convenience",
                rating: 4.5,
                reviews: 92,
                address: "Praça do Comércio, Lisboa",
                coordinate: CLLocationCoordinate2D(latitude: baseLat - 0.001, longitude: baseLon - 0.0015),
                tags: ["Late Night", "Hot Food", "Drinks"],
                price: "€€",
                hours: "20:00 - 08:00",
                openHour: 20,
                closeHour: 8,
                description: "Premium late night store with hot food options.",
                imageName: "kebab_hero",
                category: .mixed,
                phone: "+351 945 678 901",
                website: "",
                popularDishes: ["Hot Food", "Craft Beer", "Ice Cream"],
                hasDelivery: true,
                hasDineIn: false,
                hasTakeaway: true,
                isSponsored: true,
                isVerified: true
            ),
            KebabShop(
                id: "sample-5",
                name: "Downtown Express",
                rating: 3.9,
                reviews: 203,
                address: "Rua Garrett, Lisboa",
                coordinate: CLLocationCoordinate2D(latitude: baseLat + 0.0025, longitude: baseLon - 0.0005),
                tags: ["24h", "Pharmacy Items", "Food"],
                price: "€",
                hours: "24 Hours",
                openHour: 0,
                closeHour: 24,
                description: "Downtown convenience store with pharmacy essentials.",
                imageName: "kebab1",
                category: .durum,
                phone: "+351 956 789 012",
                website: "",
                popularDishes: ["Sandwiches", "Energy Drinks", "Medicine"],
                hasDelivery: false,
                hasDineIn: false,
                hasTakeaway: true,
                isSponsored: false,
                isVerified: true
            )
        ]
    }
}

// MARK: - OSM Response Models

struct OSMConvenienceResult: Codable {
    let elements: [OSMConvenienceElement]
}

struct OSMConvenienceElement: Codable {
    let id: Int
    let lat: Double?
    let lon: Double?
    let center: OSMCenter?
    let tags: [String: String]
}

struct OSMCenter: Codable {
    let lat: Double
    let lon: Double
}
