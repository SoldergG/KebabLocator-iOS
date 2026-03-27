import Foundation
import SwiftUI
import CoreLocation
import MapKit

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isUsingManualLocation: Bool = false
    @Published var manualAddress: String = ""
    @Published var isSearchingAddress: Bool = false
    @Published var addressSuggestions: [MKLocalSearchCompletion] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.7167, longitude: -9.1395),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    @Published var liveShops: [KebabShop] = []
    @Published var isFetchingLiveShops: Bool = false
    @Published var searchRadius: Double = 10.0 // Default 10km
    
    // Convenience Stores
    @Published var convenienceStores: [KebabShop] = []
    @Published var isFetchingConvenienceStores: Bool = false
    
    private var lastSearchLocation: CLLocation?
    private let searchCompleter = MKLocalSearchCompleter()
    
    // Cache keys
    private let cachedLiveShopsKey = "cached_live_shops"
    
    // Default: Lisbon
    private let defaultLocation = CLLocation(latitude: 38.7167, longitude: -9.1395)
    
    var effectiveLocation: CLLocation {
        userLocation ?? defaultLocation
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        // Load cached live shops immediately
        loadCachedLiveShops()
        
        // Initial search
        searchNearbyKebabs(at: defaultLocation)
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    // MARK: - Manual Location
    
    func setManualLocation(coordinate: CLLocationCoordinate2D, address: String) {
        isUsingManualLocation = true
        manualAddress = address
        userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
        searchNearbyKebabs(at: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    func useGPSLocation() {
        isUsingManualLocation = false
        manualAddress = ""
        manager.startUpdatingLocation()
    }
    
    // MARK: - Live Search
    
    func searchNearbyKebabs(at location: CLLocation) {
        isFetchingLiveShops = true
        
        let group = DispatchGroup()
        var allFoundShops: [KebabShop] = []
        let lock = NSLock()
        
        // 1. Yelp
        group.enter()
        YelpService.shared.searchKebabs(at: location.coordinate, radius: searchRadius * 1000) { shops in
            lock.lock()
            allFoundShops.append(contentsOf: shops)
            lock.unlock()
            group.leave()
        }
        
        // 2. Google
        group.enter()
        GooglePlacesService.shared.searchKebabs(at: location.coordinate, radius: searchRadius * 1000) { shops in
            lock.lock()
            allFoundShops.append(contentsOf: shops)
            lock.unlock()
            group.leave()
        }
        
        // 3. OSM
        group.enter()
        OSMService.shared.searchKebabs(at: location.coordinate, radius: searchRadius * 1000) { shops in
            lock.lock()
            allFoundShops.append(contentsOf: shops)
            lock.unlock()
            group.leave()
        }
        
        // 4. Foursquare
        group.enter()
        FoursquareService.shared.searchKebabs(at: location.coordinate, radius: searchRadius * 1000) { shops in
            lock.lock()
            allFoundShops.append(contentsOf: shops)
            lock.unlock()
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isFetchingLiveShops = false
            
            // De-duplicate against existing shops to accumulate them
            var uniqueShops: [KebabShop] = self?.liveShops ?? []
            for shop in allFoundShops {
                let isDuplicate = uniqueShops.contains { existing in
                    let nameMatch = existing.name.lowercased() == shop.name.lowercased()
                    let dist = CLLocation(latitude: existing.coordinate.latitude, longitude: existing.coordinate.longitude)
                        .distance(from: CLLocation(latitude: shop.coordinate.latitude, longitude: shop.coordinate.longitude))
                    return nameMatch && dist < 50 // Same name and within 50 meters
                }
                if !isDuplicate {
                    uniqueShops.append(shop)
                }
            }
            
            self?.liveShops = uniqueShops
            self?.cacheLiveShops()
        }
    }
    
    func searchAddress(_ query: String) {
        guard !query.isEmpty else {
            addressSuggestions = []
            return
        }
        searchCompleter.queryFragment = query
    }
    
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        isSearchingAddress = true
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isSearchingAddress = false
                if let placemark = placemarks?.first, let location = placemark.location {
                    completion(location.coordinate)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let address = [
                        placemark.thoroughfare,
                        placemark.subThoroughfare,
                        placemark.locality,
                        placemark.postalCode,
                        placemark.country
                    ].compactMap { $0 }.joined(separator: ", ")
                    completion(address)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        isSearchingAddress = true
        
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearchingAddress = false
                if let coordinate = response?.mapItems.first?.placemark.coordinate {
                    let address = "\(completion.title), \(completion.subtitle)"
                    self?.setManualLocation(coordinate: coordinate, address: address)
                }
            }
        }
    }
    
    // MARK: - Live Shops Caching
    
    private func cacheLiveShops() {
        do {
            let data = try JSONEncoder().encode(liveShops)
            UserDefaults.standard.set(data, forKey: cachedLiveShopsKey)
        } catch {
            print("Cache liveShops save error: \(error)")
        }
    }
    
    private func loadCachedLiveShops() {
        guard let data = UserDefaults.standard.data(forKey: cachedLiveShopsKey) else { return }
        do {
            let shops = try JSONDecoder().decode([KebabShop].self, from: data)
            self.liveShops = shops
        } catch {
            print("Cache liveShops load error: \(error)")
        }
    }
    
    // MARK: - Convenience Store Search
    
    func searchNearbyConvenienceStores(at location: CLLocation? = nil) {
        let targetLocation = location ?? effectiveLocation
        isFetchingConvenienceStores = true
        
        let group = DispatchGroup()
        var allFoundStores: [KebabShop] = []
        let lock = NSLock()
        
        // 1. OpenStreetMap (via ConvenienceStoreService)
        group.enter()
        ConvenienceStoreService.shared.searchAllConveniencePlaces(near: targetLocation) { stores in
            lock.lock()
            allFoundStores.append(contentsOf: stores)
            lock.unlock()
            group.leave()
        }
        
        // 2. Google Places
        group.enter()
        GooglePlacesService.shared.searchConvenienceStores(at: targetLocation.coordinate, radius: searchRadius * 1000) { stores in
            lock.lock()
            allFoundStores.append(contentsOf: stores)
            lock.unlock()
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isFetchingConvenienceStores = false
            
            // De-duplicate by name and rough coordinate
            var uniqueStores: [KebabShop] = []
            for store in allFoundStores {
                let isDuplicate = uniqueStores.contains { existing in
                    let nameMatch = existing.name.lowercased() == store.name.lowercased()
                    let dist = CLLocation(latitude: existing.coordinate.latitude, longitude: existing.coordinate.longitude)
                        .distance(from: CLLocation(latitude: store.coordinate.latitude, longitude: store.coordinate.longitude))
                    return nameMatch && dist < 50
                }
                
                // If it's a "sample" store from ConvenienceStoreService, only keep it if we have no real stores
                if store.id.starts(with: "sample-") && allFoundStores.contains(where: { !$0.id.starts(with: "sample-") && !$0.id.starts(with: "conv_") }) {
                    continue
                }
                
                if !isDuplicate {
                    uniqueStores.append(store)
                }
            }
            
            self.convenienceStores = uniqueStores.sorted {
                $0.distance(from: targetLocation) < $1.distance(from: targetLocation)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isUsingManualLocation else { return }
        userLocation = location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
        
        // Only search if we moved more than 500m or if it's the first search
        if let last = lastSearchLocation {
            if location.distance(from: last) > 500 {
                lastSearchLocation = location
                searchNearbyKebabs(at: location)
            }
        } else {
            lastSearchLocation = location
            searchNearbyKebabs(at: location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.addressSuggestions = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}
