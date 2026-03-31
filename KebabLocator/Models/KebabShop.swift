import Foundation
import CoreLocation

// MARK: - Kebab Shop Model

struct KebabShop: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let rating: Double
    let reviews: Int
    let address: String
    let coordinate: CLLocationCoordinate2D
    let tags: [String]
    let price: String
    let hours: String
    let openHour: Int      // 24h format
    let closeHour: Int     // 24h format
    let description: String
    let imageName: String
    let category: KebabCategory
    let phone: String
    let website: String
    let popularDishes: [String]
    let hasDelivery: Bool
    let hasDineIn: Bool
    let hasTakeaway: Bool
    var isSponsored: Bool = false
    var isVerified: Bool = false
    var contributorId: String? = nil
    var imageUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name, rating, reviews, address, latitude, longitude, tags, price, hours, openHour, closeHour, description, imageName, category, phone, website, popularDishes, hasDelivery, hasDineIn, hasTakeaway
        case isSponsored = "is_sponsored"
        case isVerified = "is_verified"
        case contributorId = "contributor_id"
        case imageUrl = "image_url"
    }
    
    init(id: String, name: String, rating: Double, reviews: Int, address: String, coordinate: CLLocationCoordinate2D, tags: [String], price: String, hours: String, openHour: Int, closeHour: Int, description: String, imageName: String, category: KebabCategory, phone: String, website: String, popularDishes: [String], hasDelivery: Bool, hasDineIn: Bool, hasTakeaway: Bool, isSponsored: Bool = false, isVerified: Bool = false, contributorId: String? = nil, imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.rating = rating
        self.reviews = reviews
        self.address = address
        self.coordinate = coordinate
        self.tags = tags
        self.price = price
        self.hours = hours
        self.openHour = openHour
        self.closeHour = closeHour
        self.description = description
        self.imageName = imageName
        self.category = category
        self.phone = phone
        self.website = website
        self.popularDishes = popularDishes
        self.hasDelivery = hasDelivery
        self.hasDineIn = hasDineIn
        self.hasTakeaway = hasTakeaway
        self.isSponsored = isSponsored
        self.isVerified = isVerified
        self.contributorId = contributorId
        self.imageUrl = imageUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        rating = try container.decode(Double.self, forKey: .rating)
        reviews = try container.decode(Int.self, forKey: .reviews)
        address = try container.decode(String.self, forKey: .address)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        tags = try container.decode([String].self, forKey: .tags)
        price = try container.decode(String.self, forKey: .price)
        hours = try container.decode(String.self, forKey: .hours)
        openHour = try container.decode(Int.self, forKey: .openHour)
        closeHour = try container.decode(Int.self, forKey: .closeHour)
        description = try container.decode(String.self, forKey: .description)
        imageName = try container.decode(String.self, forKey: .imageName)
        category = try container.decode(KebabCategory.self, forKey: .category)
        phone = try container.decode(String.self, forKey: .phone)
        website = try container.decode(String.self, forKey: .website)
        popularDishes = try container.decode([String].self, forKey: .popularDishes)
        hasDelivery = try container.decode(Bool.self, forKey: .hasDelivery)
        hasDineIn = try container.decode(Bool.self, forKey: .hasDineIn)
        hasTakeaway = try container.decode(Bool.self, forKey: .hasTakeaway)
        isSponsored = try container.decodeIfPresent(Bool.self, forKey: .isSponsored) ?? false
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        contributorId = try container.decodeIfPresent(String.self, forKey: .contributorId)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(rating, forKey: .rating)
        try container.encode(reviews, forKey: .reviews)
        try container.encode(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(tags, forKey: .tags)
        try container.encode(price, forKey: .price)
        try container.encode(hours, forKey: .hours)
        try container.encode(openHour, forKey: .openHour)
        try container.encode(closeHour, forKey: .closeHour)
        try container.encode(description, forKey: .description)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(category, forKey: .category)
        try container.encode(phone, forKey: .phone)
        try container.encode(website, forKey: .website)
        try container.encode(popularDishes, forKey: .popularDishes)
        try container.encode(hasDelivery, forKey: .hasDelivery)
        try container.encode(hasDineIn, forKey: .hasDineIn)
        try container.encode(hasTakeaway, forKey: .hasTakeaway)
        try container.encode(isSponsored, forKey: .isSponsored)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(contributorId, forKey: .contributorId)
        try container.encode(imageUrl, forKey: .imageUrl)
    }
    
    static func == (lhs: KebabShop, rhs: KebabShop) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Check if the shop is currently open based on device time
    var isOpenNow: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        if closeHour > openHour {
            // Normal hours (e.g. 11:00 – 23:00)
            return hour >= openHour && hour < closeHour
        } else {
            // Overnight hours (e.g. 22:00 – 07:00)
            return hour >= openHour || hour < closeHour
        }
    }
    
    /// Formatted open status string
    var statusText: String {
        isOpenNow ? "Open Now" : "Closed"
    }
}

enum KebabCategory: String, CaseIterable, Codable {
    case doner = "Döner"
    case falafel = "Falafel"
    case durum = "Dürüm"
    case shawarma = "Shawarma"
    case mixed = "Mixed Plate"
    
    var emoji: String {
        switch self {
        case .doner: return "🥙"
        case .falafel: return "🧆"
        case .durum: return "🌯"
        case .shawarma: return "🥩"
        case .mixed: return "🍽️"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .doner: return "flame.fill"
        case .falafel: return "leaf.fill"
        case .durum: return "scroll.fill"
        case .shawarma: return "figure.stand.line.dotted.figure.stand"
        case .mixed: return "takeoutbag.and.cup.and.straw.fill"
        }
    }
}

enum FilterOption: String, CaseIterable {
    case all      = "All"
    case openNow  = "Open Now"
    case topRated = "Top Rated"
    case doner    = "Döner"
    case falafel  = "Falafel"
    case durum    = "Dürüm"
    case shawarma = "Shawarma"
    case lateNight = "Late Night"
    case delivery = "Delivery"
    case budget   = "Budget"
    case dineIn   = "Dine-In"

    var icon: String {
        switch self {
        case .all:       return "flame.fill"
        case .openNow:   return "clock.fill"
        case .topRated:  return "star.fill"
        case .doner:     return "fork.knife"
        case .falafel:   return "leaf.fill"
        case .durum:     return "scroll.fill"
        case .shawarma:  return "takeoutbag.and.cup.and.straw.fill"
        case .lateNight: return "moon.fill"
        case .delivery:  return "bicycle"
        case .budget:    return "eurosign.circle.fill"
        case .dineIn:    return "chair.lounge.fill"
        }
    }
}

enum SortOption: String, CaseIterable {
    case distance = "Distance"
    case rating = "Rating"
    case price = "Price"
    case name = "Name"
    
    var icon: String {
        switch self {
        case .distance: return "location.fill"
        case .rating: return "star.fill"
        case .price: return "eurosign.circle.fill"
        case .name: return "textformat.abc"
        }
    }
}

// MARK: - Distance Helper

extension KebabShop {
    func distance(from location: CLLocation) -> Double {
        let shopLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return shopLocation.distance(from: location) / 1000.0 // km
    }
    
    /// Returns the best available image URL for display
    var displayImageURL: URL? {
        if let url = imageUrl, url.hasPrefix("http"), let parsed = URL(string: url) {
            return parsed
        }
        if imageName.hasPrefix("http"), let parsed = URL(string: imageName) {
            return parsed
        }
        return nil
    }
}

// MARK: - Sample Data

extension KebabShop {
    static let sampleData: [KebabShop] = [
        KebabShop(
            id: "1",
            name: "Zahir Kebab",
            rating: 4.8,
            reviews: 1243,
            address: "Av. Almirante Reis 11B, Lisboa",
            coordinate: CLLocationCoordinate2D(latitude: 38.7230, longitude: -9.1355),
            tags: ["Legendary", "Lamb", "Late Night"],
            price: "€€",
            hours: "11:00 – 04:00",
            openHour: 11,
            closeHour: 4,
            description: "Widely considered by locals as one of the best spots in Lisbon. They actually marinate their lamb properly instead of using frozen minced meat blocks. The garlic sauce is intense.",
            imageName: "kebab1",
            category: .doner,
            phone: "+351 21 814 1234",
            website: "",
            popularDishes: ["Lamb Döner", "Spicy Chicken Box", "Ayran"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "2",
            name: "Lebanese Corner",
            rating: 4.9,
            reviews: 892,
            address: "Largo do Rato 4, Lisboa",
            coordinate: CLLocationCoordinate2D(latitude: 38.7202, longitude: -9.1540),
            tags: ["Lebanese", "Premium", "Fresh"],
            price: "€€€",
            hours: "12:00 – 22:30",
            openHour: 12,
            closeHour: 22,
            description: "A step up in quality. Slightly pricier, but they use grilled red peppers, fresh red onion, and real harissa. The shawarma is tender and the homemade pita holds everything together perfectly.",
            imageName: "kebab2",
            category: .shawarma,
            phone: "+351 21 387 5555",
            website: "lebanesecorner.pt",
            popularDishes: ["Beef Shawarma Wrap", "Hummus with Pine Nuts", "Falafel Plate"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "3",
            name: "Turkish Kebab House",
            rating: 4.6,
            reviews: 2104,
            address: "Rua do Benformoso 160, Lisboa",
            coordinate: CLLocationCoordinate2D(latitude: 38.7188, longitude: -9.1350),
            tags: ["Authentic", "Halal", "Busy"],
            price: "€",
            hours: "10:30 – 02:00",
            openHour: 10,
            closeHour: 2,
            description: "A staple in the Intendente area. Massive portions, cheap prices, and very friendly staff. Their mixed Dürüm is heavy enough to skip dinner.",
            imageName: "kebab3",
            category: .durum,
            phone: "+351 91 123 4567",
            website: "",
            popularDishes: ["Mixed Meat Dürüm", "Chicken Shish", "Baklava"],
            hasDelivery: true,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "4",
            name: "Mezze",
            rating: 4.8,
            reviews: 1560,
            address: "Mercado de Arroios, Lisboa",
            coordinate: CLLocationCoordinate2D(latitude: 38.7320, longitude: -9.1340),
            tags: ["Middle Eastern", "Social Project", "Charcoal Grill"],
            price: "€€",
            hours: "12:00 – 22:00",
            openHour: 12,
            closeHour: 22,
            description: "More than just a kebab joint, this is a restaurant run by Syrian refugees. The food is staggeringly good—try the baba ganoush alongside a real charcoal chicken kebab. Always packed.",
            imageName: "kebab4",
            category: .mixed,
            phone: "+351 21 000 0000",
            website: "mezze.pt",
            popularDishes: ["Shish Taouk", "Baba Ganoush", "Fatoush Salad"],
            hasDelivery: false,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "5",
            name: "Alibaba Kebab House",
            rating: 4.3,
            reviews: 940,
            address: "Rua da Palma 240, Martim Moniz",
            coordinate: CLLocationCoordinate2D(latitude: 38.7161, longitude: -9.1352),
            tags: ["Fast", "Halal", "Cheap"],
            price: "€",
            hours: "11:00 – 05:00",
            openHour: 11,
            closeHour: 5,
            description: "The classic post-night-out lifesaver right by Martim Moniz. It’s fast, greasy in a good way, and the guys behind the counter are impressively quick even at 4 AM.",
            imageName: "kebab5",
            category: .doner,
            phone: "+351 93 456 7890",
            website: "",
            popularDishes: ["Chicken Döner in Pita", "Fries with Sauce", "Falafel"],
            hasDelivery: true,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "6",
            name: "Istanbul Kebab Baixa",
            rating: 4.4,
            reviews: 1820,
            address: "Rua das Portas de Santo Antão 52",
            coordinate: CLLocationCoordinate2D(latitude: 38.7155, longitude: -9.1400),
            tags: ["Central", "Family Friendly"],
            price: "€€",
            hours: "11:00 – 00:00",
            openHour: 11,
            closeHour: 0,
            description: "Solid spot right in the tourist center but maintains good quality. Their Iskender Kebab with the hot tomato sauce and melted butter over pita bread is incredible.",
            imageName: "kebab6",
            category: .mixed,
            phone: "+351 21 342 0987",
            website: "istanbulkebab.pt",
            popularDishes: ["Iskender Kebab", "Lahmacun", "Veal Döner"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "7",
            name: "Halal Counter",
            rating: 4.5,
            reviews: 630,
            address: "Rua Dom Carlos I 45, Santos",
            coordinate: CLLocationCoordinate2D(latitude: 38.7075, longitude: -9.1550),
            tags: ["Student Spot", "Halal", "Crispy Falafel"],
            price: "€",
            hours: "12:00 – 02:00",
            openHour: 12,
            closeHour: 2,
            description: "A tiny hole-in-the-wall near IADE and the Santos bars. The falafels are super green inside, very herby, and fried to order so they never feel soggy.",
            imageName: "kebab7",
            category: .falafel,
            phone: "",
            website: "",
            popularDishes: ["Falafel Wrap", "Chicken Box", "Sweet Potato Fries"],
            hasDelivery: true,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "8",
            name: "Pita Shoarma (Joshua's)",
            rating: 3.9,
            reviews: 3200,
            address: "Armazéns do Chiado, Food Court",
            coordinate: CLLocationCoordinate2D(latitude: 38.7110, longitude: -9.1398),
            tags: ["Mall Food", "Shoarma", "Chain"],
            price: "€€",
            hours: "10:00 – 23:00",
            openHour: 10,
            closeHour: 23,
            description: "It's a shopping mall staple in Portugal. Not the traditional gritty kebab shop, but their garlic mayonnaise is legendary and the pita bread is surprisingly soft.",
            imageName: "kebab8",
            category: .shawarma,
            phone: "+351 21 322 0000",
            website: "joshuashoarma.pt",
            popularDishes: ["Pita Shoarma Menu", "Veggie Pita", "Wedges"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "9",
            name: "O Rei do Kebab - Alcântara",
            rating: 4.2,
            reviews: 450,
            address: "Calçada da Tapada 12, Alcântara",
            coordinate: CLLocationCoordinate2D(latitude: 38.7050, longitude: -9.1800),
            tags: ["Local", "Big Portions"],
            price: "€",
            hours: "11:30 – 23:30",
            openHour: 11,
            closeHour: 23,
            description: "A local joint feeding university students from ISA. You get an immense amount of food for under 6 euros. The spicy sauce actually packs a punch.",
            imageName: "kebab9",
            category: .durum,
            phone: "+351 92 111 2222",
            website: "",
            popularDishes: ["Student Dürüm", "Kebab Plate with Rice", "Fries"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "10",
            name: "Lisbon Café & Shisha",
            rating: 4.1,
            reviews: 800,
            address: "Bairro Alto, Rua da Rosa 105",
            coordinate: CLLocationCoordinate2D(latitude: 38.7125, longitude: -9.1455),
            tags: ["Shisha", "Drinks", "Late Night"],
            price: "€€",
            hours: "18:00 – 03:00",
            openHour: 18,
            closeHour: 3,
            description: "Come for the shisha and tea, stay for the kebab. It's darker and louder than a normal restaurant, but eating a Döner while having a cold drink before clubbing is unmatched.",
            imageName: "kebab10",
            category: .doner,
            phone: "+351 21 888 7777",
            website: "",
            popularDishes: ["Mixed Plate", "Mint Tea", "Chicken Dürüm"],
            hasDelivery: false,
            hasDineIn: true,
            hasTakeaway: false
        ),
        KebabShop(
            id: "11",
            name: "Zubir Churrasqueira Halal",
            rating: 4.8,
            reviews: 650,
            address: "Rua do Benformoso 182, Intendente",
            coordinate: CLLocationCoordinate2D(latitude: 38.7190, longitude: -9.1350),
            tags: ["Desi Fusion", "BBQ", "Hidden Gem"],
            price: "€",
            hours: "12:00 – 23:00",
            openHour: 12,
            closeHour: 23,
            description: "Not a traditional Döner place, but a fantastic Halal BBQ spot blending South Asian and Middle Eastern flavors. Their charcoal-grilled chicken tikka in a wrap rivals any kebab in the city.",
            imageName: "kebab1",
            category: .shawarma,
            phone: "+351 96 555 4444",
            website: "",
            popularDishes: ["Chicken Tikka Roll", "Lamb Seekh Kebab", "Mango Lassi"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "12",
            name: "Alif Kebab House",
            rating: 4.3,
            reviews: 540,
            address: "Rua Morais Soares 45",
            coordinate: CLLocationCoordinate2D(latitude: 38.7280, longitude: -9.1330),
            tags: ["Pizza & Kebab", "Family", "Halal"],
            price: "€",
            hours: "11:00 – 01:00",
            openHour: 11,
            closeHour: 1,
            description: "A classic hybrid shop selling both pizzas and kebabs. The 'Kebab Pizza' is an absolute unit of a meal if you hate making choices.",
            imageName: "kebab2",
            category: .mixed,
            phone: "+351 21 333 2222",
            website: "",
            popularDishes: ["Kebab Pizza", "Döner Sandwich", "Garlic Bread"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "13",
            name: "I Love Kebab",
            rating: 4.0,
            reviews: 890,
            address: "Campo Pequeno Shopping Center",
            coordinate: CLLocationCoordinate2D(latitude: 38.7420, longitude: -9.1450),
            tags: ["Mall", "Fast", "Clean"],
            price: "€€",
            hours: "11:00 – 22:00",
            openHour: 11,
            closeHour: 22,
            description: "Modern, brightly lit, and very clean. The meat is slightly thicker cut. Good option if you're catching a movie or concert at Campo Pequeno.",
            imageName: "kebab3",
            category: .doner,
            phone: "+351 21 999 8888",
            website: "ilovekebab.pt",
            popularDishes: ["Mega Dürüm", "Kebab Box with Rice", "Nuggets"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "14",
            name: "Shawarma Royale",
            rating: 4.7,
            reviews: 320,
            address: "Rua de São Paulo 100, Cais do Sodré",
            coordinate: CLLocationCoordinate2D(latitude: 38.7070, longitude: -9.1440),
            tags: ["Gourmet", "Shawarma", "Cocktails"],
            price: "€€€",
            hours: "18:00 – 02:00",
            openHour: 18,
            closeHour: 2,
            description: "A trendy, upscale take on Middle Eastern street food. They serve craft cocktails alongside deeply spiced, slow-roasted beef shawarma in freshly baked saj bread.",
            imageName: "kebab4",
            category: .shawarma,
            phone: "+351 21 444 3333",
            website: "shawarmaroyale.pt",
            popularDishes: ["Beef Shawarma Saj", "Truffle Hummus", "Pomegranate Margarita"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: false
        ),
        KebabShop(
            id: "15",
            name: "Graça Kebab View",
            rating: 4.5,
            reviews: 410,
            address: "Largo da Graça",
            coordinate: CLLocationCoordinate2D(latitude: 38.7160, longitude: -9.1300),
            tags: ["Scenic", "Sunset", "Beers"],
            price: "€€",
            hours: "15:00 – 01:00",
            openHour: 15,
            closeHour: 1,
            description: "Technically a small kiosk/shop near the Miradouro. Grab a falafel wrap, a cold Super Bock, and sit on the wall watching the sunset over the castle.",
            imageName: "kebab5",
            category: .falafel,
            phone: "",
            website: "",
            popularDishes: ["Sunset Falafel Wrap", "Chicken Box", "Draft Beer"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "16",
            name: "Sultan Döner",
            rating: 4.2,
            reviews: 550,
            address: "Avenida de Roma 45",
            coordinate: CLLocationCoordinate2D(latitude: 38.7450, longitude: -9.1390),
            tags: ["Local", "Neighborhood", "Friendly"],
            price: "€",
            hours: "11:00 – 23:00",
            openHour: 11,
            closeHour: 23,
            description: "A quiet neighborhood favorite in Avenidas Novas. The owner knows everyone by name and usually sneaks extra fries into the box.",
            imageName: "kebab6",
            category: .doner,
            phone: "+351 21 777 6666",
            website: "",
            popularDishes: ["Classic Döner", "Cheese Fries", "Baklava"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "17",
            name: "Berlin Gemuse Kebab",
            rating: 4.8,
            reviews: 890,
            address: "Rua da Boavista 18, Cais do Sodré",
            coordinate: CLLocationCoordinate2D(latitude: 38.7080, longitude: -9.1460),
            tags: ["German Style", "Roasted Veggies", "Trendy"],
            price: "€€",
            hours: "12:00 – 00:00",
            openHour: 12,
            closeHour: 0,
            description: "Modeled entirely after Mustafa's in Berlin. They put roasted potatoes, carrots, and eggplant inside the kebab, topped with crumbled feta cheese and a squeeze of lemon.",
            imageName: "kebab7",
            category: .doner,
            phone: "+351 91 888 7777",
            website: "berlingemuse.pt",
            popularDishes: ["Gemüse Chicken Döner", "Halloumi Wrap", "Club Mate"],
            hasDelivery: true,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "18",
            name: "Oásis Vegetariano",
            rating: 4.6,
            reviews: 340,
            address: "Picoas, Rua Andrade Corvo",
            coordinate: CLLocationCoordinate2D(latitude: 38.7300, longitude: -9.1480),
            tags: ["Vegan Only", "Healthy", "Lunch"],
            price: "€€",
            hours: "11:00 – 16:00",
            openHour: 11,
            closeHour: 16,
            description: "Only open for lunch. Everything is plant-based. They do a 'fake meat' seitan kebab that is surprisingly incredibly spiced and textured. Highly popular with office workers.",
            imageName: "kebab8",
            category: .falafel,
            phone: "+351 21 555 4444",
            website: "oasisveg.pt",
            popularDishes: ["Seitan Dürüm", "Falafel Salad", "Fresh Ginger Lemonade"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "19",
            name: "Tariq's Halal Grill",
            rating: 4.4,
            reviews: 620,
            address: "Odivelas, Av. D. Dinis",
            coordinate: CLLocationCoordinate2D(latitude: 38.7900, longitude: -9.1800),
            tags: ["Suburbs", "Huge Portions", "Family"],
            price: "€",
            hours: "12:00 – 23:00",
            openHour: 12,
            closeHour: 23,
            description: "A bit outside the center but worth the trip if you live nearby. Tariq piles the meat so high on the Dürüm that it's physically difficult to close it. Excellent value.",
            imageName: "kebab9",
            category: .durum,
            phone: "+351 21 222 1111",
            website: "",
            popularDishes: ["Monster Dürüm", "Samosas", "Mango Milkshake"],
            hasDelivery: true,
            hasDineIn: true,
            hasTakeaway: true
        ),
        KebabShop(
            id: "20",
            name: "Kebab & Co. Cascais",
            rating: 4.3,
            reviews: 510,
            address: "Cascais Centro, Largo Praia da Rainha",
            coordinate: CLLocationCoordinate2D(latitude: 38.6960, longitude: -9.4200),
            tags: ["Beach", "Touristy", "Clean"],
            price: "€€€",
            hours: "10:00 – 00:00",
            openHour: 10,
            closeHour: 0,
            description: "Located right by the beach in Cascais. It's more expensive than Lisbon spots, but grabbing a Doner box and eating it on the sand while watching the waves is a great experience.",
            imageName: "kebab10",
            category: .doner,
            phone: "+351 21 888 9999",
            website: "",
            popularDishes: ["Beach Kebab Box", "Pita Falafel", "Sangria"],
            hasDelivery: true,
            hasDineIn: false,
            hasTakeaway: true
        ),
        // MARK: - Convenience Stores & Late Night Shops
        KebabShop(
            id: "21",
            name: "Casa da India - Late Night",
            rating: 4.5,
            reviews: 320,
            address: "Rua da Palma 145, Martim Moniz",
            coordinate: CLLocationCoordinate2D(latitude: 38.7158, longitude: -9.1355),
            tags: ["Indian", "Convenience", "Late Night", "24h", "All Night"],
            price: "€",
            hours: "00:00 – 24:00",
            openHour: 0,
            closeHour: 24,
            description: "Small Indian convenience store open 24 hours. Sells snacks, drinks, phone chargers, and basic groceries at any time of night. Popular with night shift workers and late-night party-goers.",
            imageName: "kebab1",
            category: .mixed,
            phone: "+351 91 234 5678",
            website: "",
            popularDishes: ["Samosa", "Indian Snacks", "Energy Drinks"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "22",
            name: "SPAR 24H Convenience",
            rating: 4.2,
            reviews: 890,
            address: "Av. Almirante Reis 88, Arroios",
            coordinate: CLLocationCoordinate2D(latitude: 38.7245, longitude: -9.1340),
            tags: ["Convenience", "24h", "Grocery", "All Night"],
            price: "€€",
            hours: "00:00 – 24:00",
            openHour: 0,
            closeHour: 24,
            description: "24-hour convenience store with hot snacks, fresh coffee, sandwiches, and all essentials. ATM inside and accepts contactless payments.",
            imageName: "kebab2",
            category: .mixed,
            phone: "+351 21 123 4567",
            website: "",
            popularDishes: ["Hot Dogs", "Fresh Coffee", "Sandwiches"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "23",
            name: "Late Night Supermercado",
            rating: 4.0,
            reviews: 450,
            address: "Rua do Benformoso 200, Intendente",
            coordinate: CLLocationCoordinate2D(latitude: 38.7195, longitude: -9.1360),
            tags: ["Late Night", "Convenience", "24h", "Grocery"],
            price: "€",
            hours: "22:00 – 08:00",
            openHour: 22,
            closeHour: 8,
            description: "Night-only convenience store serving the Intendente area. Open exclusively during night hours for shift workers and late crowds. Cheap snacks and drinks.",
            imageName: "kebab3",
            category: .mixed,
            phone: "+351 92 345 6789",
            website: "",
            popularDishes: ["Chips", "Soft Drinks", "Cigarettes"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "24",
            name: "Indian Mini Mart - Baixa",
            rating: 4.3,
            reviews: 280,
            address: "Rua da Prata 45, Baixa",
            coordinate: CLLocationCoordinate2D(latitude: 38.7075, longitude: -9.1380),
            tags: ["Indian", "Convenience", "Late Night"],
            price: "€",
            hours: "08:00 – 02:00",
            openHour: 8,
            closeHour: 2,
            description: "Indian family-run convenience store in Baixa. Sells Indian spices, snacks, and late-night essentials. Known for their warm chai and friendly service even at 1 AM.",
            imageName: "kebab4",
            category: .mixed,
            phone: "+351 93 456 7890",
            website: "",
            popularDishes: ["Masala Chai", "Indian Sweets", "Spices"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "25",
            name: "All Night Shop - Cais do Sodré",
            rating: 3.9,
            reviews: 670,
            address: "Rua de São Paulo 78, Cais do Sodré",
            coordinate: CLLocationCoordinate2D(latitude: 38.7065, longitude: -9.1445),
            tags: ["All Night", "Convenience", "24h", "Party Area"],
            price: "€€",
            hours: "00:00 – 24:00",
            openHour: 0,
            closeHour: 24,
            description: "The go-to spot for night owls in Cais do Sodré. Open 24/7 with alcohol, snacks, phone chargers, and even umbrella rentals. Prices are higher but it's always open when you need it most.",
            imageName: "kebab5",
            category: .mixed,
            phone: "+351 91 567 8901",
            website: "",
            popularDishes: ["Beer", "Chips", "Cigarettes"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "26",
            name: "Mini Preço Express 24H",
            rating: 4.1,
            reviews: 520,
            address: "Av. da Liberdade 120",
            coordinate: CLLocationCoordinate2D(latitude: 38.7220, longitude: -9.1465),
            tags: ["Convenience", "24h", "Grocery", "All Night"],
            price: "€€",
            hours: "00:00 – 24:00",
            openHour: 0,
            closeHour: 24,
            description: "24-hour mini supermarket on Avenida da Liberdade. Fresh bread delivery at 6 AM, hot coffee always available, and complete grocery selection even at 3 AM.",
            imageName: "kebab6",
            category: .mixed,
            phone: "+351 21 789 0123",
            website: "",
            popularDishes: ["Fresh Bread", "Coffee", "Ready Meals"],
            hasDelivery: true,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "27",
            name: "Bombay Corner Store",
            rating: 4.4,
            reviews: 340,
            address: "Rua do Benformoso 175, Intendente",
            coordinate: CLLocationCoordinate2D(latitude: 38.7192, longitude: -9.1358),
            tags: ["Indian", "Convenience", "Late Night"],
            price: "€",
            hours: "10:00 – 04:00",
            openHour: 10,
            closeHour: 4,
            description: "Authentic Indian convenience store selling spices, Bollywood DVDs, Indian snacks, and phone accessories. Open until 4 AM for the late-night crowd. Bollywood music always playing.",
            imageName: "kebab7",
            category: .mixed,
            phone: "+351 92 678 9012",
            website: "",
            popularDishes: ["Samosas", "Indian Sweets", "Chai"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "28",
            name: "24H Gas Station Shop",
            rating: 3.8,
            reviews: 210,
            address: "Av. Brasília, Belém",
            coordinate: CLLocationCoordinate2D(latitude: 38.6950, longitude: -9.2050),
            tags: ["24h", "Convenience", "All Night", "Gas Station"],
            price: "€€",
            hours: "00:00 – 24:00",
            openHour: 0,
            closeHour: 24,
            description: "24-hour convenience store attached to gas station. Hot dogs, coffee, energy drinks, and car essentials available around the clock.",
            imageName: "kebab8",
            category: .mixed,
            phone: "+351 21 345 6789",
            website: "",
            popularDishes: ["Hot Dogs", "Coffee", "Snacks"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "29",
            name: "Night Owl Convenience",
            rating: 4.0,
            reviews: 180,
            address: "Rua Nova do Carvalho 32, Pink Street",
            coordinate: CLLocationCoordinate2D(latitude: 38.7070, longitude: -9.1435),
            tags: ["Late Night", "Convenience", "Party Area"],
            price: "€€",
            hours: "20:00 – 06:00",
            openHour: 20,
            closeHour: 6,
            description: "Night-only convenience store in Pink Street area. Opens at 8 PM and stays open until 6 AM specifically for the nightlife crowd. Energy drinks, snacks, and after-party essentials.",
            imageName: "kebab9",
            category: .mixed,
            phone: "+351 91 789 0123",
            website: "",
            popularDishes: ["Energy Drinks", "Snacks", "Water"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        ),
        KebabShop(
            id: "30",
            name: "Desi Grocery & Snacks",
            rating: 4.5,
            reviews: 290,
            address: "Rua de Arroios 67",
            coordinate: CLLocationCoordinate2D(latitude: 38.7310, longitude: -9.1320),
            tags: ["Indian", "Convenience", "Late Night"],
            price: "€",
            hours: "09:00 – 02:00",
            openHour: 9,
            closeHour: 2,
            description: "Indian grocery store with fresh samosas made daily, Indian spices, Bollywood magazines, and late-night snacks. Family-run business with authentic Indian products hard to find elsewhere.",
            imageName: "kebab10",
            category: .mixed,
            phone: "+351 92 890 1234",
            website: "",
            popularDishes: ["Fresh Samosas", "Indian Sweets", "Spices"],
            hasDelivery: false,
            hasDineIn: false,
            hasTakeaway: true
        )
    ]
}
