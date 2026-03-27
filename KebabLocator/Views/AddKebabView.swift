import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

// MARK: - Add Kebab Step-by-Step View

struct AddKebabView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    // Mode toggle
    @State private var isConvenienceMode: Bool
    
    init(isConvenienceMode: Bool = false) {
        _isConvenienceMode = State(initialValue: isConvenienceMode)
    }
    
    // MARK: - Step Management
    @State private var currentStep: Int = 1
    let totalSteps = 5
    
    // MARK: - Form States
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var description: String = ""
    @State private var category: KebabCategory = .doner
    @State private var price: String = "€"
    @State private var phone: String = ""
    @State private var website: String = ""
    
    // Hours
    @State private var openHour: Int = 11
    @State private var closeHour: Int = 23
    @State private var hasDelivery: Bool = true
    @State private var hasDineIn: Bool = true
    @State private var hasTakeaway: Bool = true
    
    // Tags
    @State private var selectedTags: Set<String> = []
    @State private var customTag: String = ""
    
    // Location
    @State private var useCurrentLocation: Bool = true
    @State private var manualCoordinate: CLLocationCoordinate2D?
    @State private var showLocationPicker: Bool = false
    @State private var locationSearchQuery: String = ""
    @State private var selectedLocation: String = ""
    
    // Photo
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    
    // UI States
    @State private var isUploading: Bool = false
    @State private var uploadProgress: Double = 0
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String?
    @State private var showValidationError: Bool = false
    @State private var isFetchingAddress: Bool = false
    
    // Available tags
    private var availableTags: [String] {
        if isConvenienceMode {
            return [
                "24h", "Late Night", "ATM", "Lottery", "Pharmacy",
                "Snacks", "Drinks", "Hot Food", "Coffee", "Newspapers",
                "Essentials", "Budget", "Local", "Quick Stop"
            ]
        } else {
            return [
                "Halal", "Vegetarian", "Vegan", "Spicy", "Late Night",
                "Family Friendly", "Quick Bite", "Premium", "Outdoor Seating",
                "Local Favorite", "Hidden Gem", "Trendy", "Authentic",
                "Budget", "Student Spot"
            ]
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Mode Toggle Header
                    modeToggleHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Progress Bar
                    progressBar
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Step Title
                    stepTitle
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Step Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case 1:
                                step1BasicInfo
                            case 2:
                                step2Category
                            case 3:
                                step3Location
                            case 4:
                                step4Details
                            case 5:
                                step5Photo
                            default:
                                EmptyView()
                            }
                            
                            // Ad Banner (Large)
                            BannerAd(adUnitID: "ca-app-pub-3940256099942544/2934735716", height: 250)
                                .padding(.top, 16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                    
                    Spacer()
                    
                    // Navigation Buttons
                    navigationButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .background(
                            Color.bgPrimary
                                .ignoresSafeArea(edges: .bottom)
                        )
                }
            }
            .navigationTitle("Add New Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your kebab shop has been submitted for review. It will appear on the map once approved.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Something went wrong. Please try again.")
            }
            .alert("Missing Information", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill in all required fields before continuing.")
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(selectedCoordinate: $manualCoordinate, selectedAddress: $address)
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        if let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                selectedImage = uiImage
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.accentOrange : Color.surface)
                    .frame(height: 4)
                    .overlay(
                        Capsule()
                            .stroke(step <= currentStep ? Color.accentOrange : Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
    
    // MARK: - Step Title
    private var stepTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(currentStep) of \(totalSteps)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentOrange)
            
            Text(stepTitleText)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Text(stepSubtitleText)
                .font(.system(size: 15))
                .foregroundColor(.textMuted)
        }
    }
    
    private var stepTitleText: String {
        switch currentStep {
        case 1: return "Basic Information"
        case 2: return isConvenienceMode ? "Store Type" : "Category & Type"
        case 3: return "Location"
        case 4: return "Details & Hours"
        case 5: return "Photo & Submit"
        default: return ""
        }
    }
    
    private var stepSubtitleText: String {
        switch currentStep {
        case 1: return isConvenienceMode ? "Let's start with the store name and address" : "Let's start with the name and address"
        case 2: return isConvenienceMode ? "What kind of convenience store is this?" : "What kind of kebab shop is this?"
        case 3: return "Where is it located?"
        case 4: return "Add opening hours and features"
        case 5: return "Add a photo and finish"
        default: return ""
        }
    }
    
    // MARK: - Step 1: Basic Info
    private var step1BasicInfo: some View {
        VStack(spacing: 20) {
            // Shop Name
            FormField(title: isConvenienceMode ? "Store Name *" : "Shop Name *", icon: "storefront.fill") {
                TextField(isConvenienceMode ? "e.g., Quick Stop Market" : "e.g., Zahir Kebab House", text: $name)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
            }
            
            // Address
            FormField(title: "Address *", icon: "mappin.and.ellipse") {
                HStack {
                    TextField("e.g., Rua da Palma 123, Lisboa", text: $address)
                        .font(.system(size: 16))
                        .foregroundColor(.textPrimary)
                    
                    if isFetchingAddress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentOrange))
                            .scaleEffect(0.8)
                    } else {
                        Button {
                            useCurrentLocationForAddress()
                        } label: {
                            Image(systemName: "location.fill")
                                .foregroundColor(.accentOrange)
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 32, height: 32)
                                .background(Color.accentOrange.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            // Phone (Optional)
            FormField(title: "Phone (Optional)", icon: "phone.fill") {
                TextField("+351 21 123 4567", text: $phone)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
                    .keyboardType(.phonePad)
            }
            
            // Website (Optional)
            FormField(title: "Website (Optional)", icon: "globe") {
                TextField("www.example.com", text: $website)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
        }
    }
    
    // MARK: - Step 2: Category
    private var step2Category: some View {
        VStack(spacing: 24) {
            // Category Selection
            VStack(alignment: .leading, spacing: 12) {
                Text(isConvenienceMode ? "What type of store? *" : "What type of kebab? *")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                if isConvenienceMode {
                    // Convenience store types
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ConvenienceTypeButton(
                            type: "24h Store",
                            icon: "clock.fill",
                            isSelected: category == .mixed
                        ) {
                            category = .mixed
                        }
                        
                        ConvenienceTypeButton(
                            type: "Mini Market",
                            icon: "basket.fill",
                            isSelected: category == .doner
                        ) {
                            category = .doner
                        }
                        
                        ConvenienceTypeButton(
                            type: "Quick Stop",
                            icon: "bolt.fill",
                            isSelected: category == .shawarma
                        ) {
                            category = .shawarma
                        }
                        
                        ConvenienceTypeButton(
                            type: "Corner Shop",
                            icon: "location.fill",
                            isSelected: category == .durum
                        ) {
                            category = .durum
                        }
                    }
                } else {
                    // Original kebab categories
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                        ForEach(KebabCategory.allCases, id: \.self) { cat in
                            CategoryButton(
                                category: cat,
                                isSelected: category == cat
                            ) {
                                category = cat
                            }
                        }
                    }
                }
            }
            
            // Price Range
            VStack(alignment: .leading, spacing: 12) {
                Text("Price Range *")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 12) {
                    ForEach(["€", "€€", "€€€"], id: \.self) { priceOption in
                        PriceButton(
                            price: priceOption,
                            isSelected: price == priceOption
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                price = priceOption
                            }
                        }
                    }
                }
            }
            
            // Description
            FormField(title: "Description (Optional)", icon: "text.alignleft") {
                TextEditor(text: $description)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
                    .frame(minHeight: 100)
            }
        }
    }
    
    // MARK: - Mode Toggle Header
    private var modeToggleHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Add New Place")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text(isConvenienceMode ? "Convenience Store" : "Kebab Shop")
                    .font(.system(size: 16))
                    .foregroundColor(.textMuted)
            }
            
            Spacer()
            
            // Mode Toggle Button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                isConvenienceMode.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isConvenienceMode ? "bag.fill" : "fork.knife")
                        .font(.system(size: 16, weight: .bold))
                    Text(isConvenienceMode ? "Store" : "Kebab")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isConvenienceMode ? Color.openGreen : Color.accentOrange)
                .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - Step 3: Location
    private var step3Location: some View {
        VStack(spacing: 20) {
            // Location Mode Selection
            VStack(alignment: .leading, spacing: 16) {
                Text("How do you want to set the location?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                // Use Current Location
                LocationModeButton(
                    title: "Use My Current Location",
                    subtitle: "GPS: \(locationManager.isUsingManualLocation ? "Manual" : "Active")",
                    icon: "location.fill",
                    isSelected: useCurrentLocation
                ) {
                    useCurrentLocation = true
                    locationManager.useGPSLocation()
                }
                
                // Pick on Map
                LocationModeButton(
                    title: "Pick on Map",
                    subtitle: manualCoordinate != nil ? "Location selected" : "Tap to open map",
                    icon: "map.fill",
                    isSelected: !useCurrentLocation && manualCoordinate != nil
                ) {
                    useCurrentLocation = false
                    showLocationPicker = true
                }
            }
            
            if !useCurrentLocation, let coord = manualCoordinate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Coordinates:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Text("Lat: \(String(format: "%.5f", coord.latitude)), Lon: \(String(format: "%.5f", coord.longitude))")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.textPrimary)
                }
                .padding()
                .background(Color.surface)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Step 4: Details
    private var step4Details: some View {
        VStack(spacing: 24) {
            // Opening Hours
            VStack(alignment: .leading, spacing: 16) {
                Text("Opening Hours *")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opens")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                        
                        HourPicker(hour: $openHour)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Closes")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                        
                        HourPicker(hour: $closeHour)
                    }
                }
            }
            
            // Services
            VStack(alignment: .leading, spacing: 12) {
                Text("Services Available")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                VStack(spacing: 8) {
                    ToggleRow(icon: "takeoutbag.and.cup.and.straw.fill", title: "Takeaway", isOn: $hasTakeaway)
                    ToggleRow(icon: "bicycle", title: "Delivery", isOn: $hasDelivery)
                    ToggleRow(icon: "chair.lounge.fill", title: "Dine-in", isOn: $hasDineIn)
                }
            }
            
            // Tags
            VStack(alignment: .leading, spacing: 12) {
                Text("Tags (Select all that apply)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                FlowLayout(spacing: 8) {
                    ForEach(availableTags, id: \.self) { tag in
                        TagButton(
                            tag: tag,
                            isSelected: selectedTags.contains(tag)
                        ) {
                            toggleTag(tag)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 5: Photo
    private var step5Photo: some View {
        VStack(spacing: 24) {
            // Photo Preview
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        Button {
                            self.selectedImage = nil
                            self.selectedImageData = nil
                            self.selectedItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(12)
                    )
            } else {
                // Photo Selector
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.accentOrange)
                        
                        Text("Add a Photo (Optional)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        
                        Text("Tap to select from gallery")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color.surface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentOrange.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    )
                }
            }
            
            // Summary Card
            VStack(alignment: .leading, spacing: 12) {
                Text("Summary")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                SummaryRow(icon: "storefront.fill", title: name.isEmpty ? "Not set" : name)
                SummaryRow(icon: "mappin.fill", title: address.isEmpty ? "Not set" : address)
                SummaryRow(icon: "fork.knife", title: category.rawValue)
                SummaryRow(icon: "clock.fill", title: "\(formatHour(openHour)) - \(formatHour(closeHour))")
            }
            .padding()
            .background(Color.surface)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back Button
            if currentStep > 1 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.surface)
                    .cornerRadius(16)
                }
            }
            
            // Next/Submit Button
            Button {
                if currentStep < totalSteps {
                    if validateCurrentStep() {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        showValidationError = true
                    }
                } else {
                    submitShop()
                }
            } label: {
                HStack {
                    Text(currentStep < totalSteps ? "Continue" : "Submit Shop")
                        .font(.system(size: 17, weight: .bold))
                    
                    if currentStep < totalSteps {
                        Image(systemName: "chevron.right")
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.accentOrange, .closedRed],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .disabled(isUploading)
            .opacity(isUploading ? 0.6 : 1)
        }
    }
    
    // MARK: - Helper Methods
    private func toggleTag(_ tag: String) {
        withAnimation(.spring(response: 0.3)) {
            if selectedTags.contains(tag) {
                selectedTags.remove(tag)
            } else {
                selectedTags.insert(tag)
            }
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        return String(format: "%02d:00", hour)
    }
    
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case 1:
            return !name.isEmpty && !address.isEmpty
        case 2:
            return true // Category and price always selected
        case 3:
            return useCurrentLocation || manualCoordinate != nil
        case 4, 5:
            return true
        default:
            return false
        }
    }
    
    private func submitShop() {
        isUploading = true
        
        let latitude = useCurrentLocation ?
            locationManager.effectiveLocation.coordinate.latitude :
            (manualCoordinate?.latitude ?? 0)
        let longitude = useCurrentLocation ?
            locationManager.effectiveLocation.coordinate.longitude :
            (manualCoordinate?.longitude ?? 0)
        
        favoritesManager.submitShop(
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            description: description,
            category: category,
            phone: phone.isEmpty ? nil : phone,
            website: website.isEmpty ? nil : website,
            hours: "\(formatHour(openHour)) - \(formatHour(closeHour))",
            openHour: openHour,
            closeHour: closeHour,
            price: price,
            tags: Array(selectedTags),
            hasDelivery: hasDelivery,
            hasDineIn: hasDineIn,
            hasTakeaway: hasTakeaway,
            imageData: selectedImageData
        ) { success, error in
            isUploading = false
            
            if success {
                showSuccessAlert = true
            } else {
                errorMessage = error
                showErrorAlert = true
            }
        }
    }
    
    private func useCurrentLocationForAddress() {
        guard let location = locationManager.userLocation else {
            errorMessage = "Location not available. Please ensure GPS is enabled."
            showErrorAlert = true
            return
        }
        
        isFetchingAddress = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        locationManager.reverseGeocode(location: location) { fetchedAddress in
            isFetchingAddress = false
            if let fetchedAddress = fetchedAddress {
                withAnimation {
                    self.address = fetchedAddress
                }
            } else {
                errorMessage = "Could not find address for current location."
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Supporting Views

struct FormField<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.accentOrange)
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)
            }
            
            content
                .padding(16)
                .background(Color.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

struct CategoryButton: View {
    let category: KebabCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .black : .textPrimary)
                
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .black : .textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.accentOrange : Color.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentOrange : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PriceButton: View {
    let price: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(price)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isSelected ? .black : .textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isSelected ? Color.accentOrange : Color.surface)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentOrange.opacity(0.2) : Color.surface)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .accentOrange : .textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentOrange)
                }
            }
            .padding(16)
            .background(Color.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentOrange : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HourPicker: View {
    @Binding var hour: Int
    
    var body: some View {
        Menu {
            Picker("Hour", selection: $hour) {
                ForEach(0..<24) { h in
                    Text(String(format: "%02d:00", h))
                        .tag(h)
                }
            }
        } label: {
            HStack {
                Text(String(format: "%02d:00", hour))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.accentOrange)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .accentOrange))
        .padding(16)
        .background(Color.surface)
        .cornerRadius(12)
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .black : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentOrange : Color.surface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.accentOrange : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentOrange)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                      y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Location Picker View

struct LocationPickerView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var selectedAddress: String
    @Environment(\.dismiss) var dismiss
    
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    if let coord = selectedCoordinate {
                        Marker("Selected", coordinate: coord)
                    }
                }
                .mapStyle(.standard)
                .overlay(
                    // Crosshair in center
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.accentOrange)
                        .opacity(0.5)
                )
                
                VStack {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textMuted)
                        
                        TextField("Search location...", text: $searchText)
                            .foregroundColor(.textPrimary)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                searchResults = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textMuted)
                            }
                        }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                    
                    // Search Results
                    if !searchResults.isEmpty {
                        List(searchResults, id: \.self) { item in
                            Button {
                                selectedCoordinate = item.placemark.coordinate
                                selectedAddress = item.name ?? ""
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                    
                                    Text(item.placemark.title ?? "")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textMuted)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        .frame(maxHeight: 300)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Select Button
                    Button {
                        if let region = position.region {
                            selectedCoordinate = region.center
                            selectedAddress = "Custom Location"
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Use This Location")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.accentOrange, .closedRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = position.region ?? MKCoordinateRegion()
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            searchResults = response.mapItems
        }
    }
}

// MARK: - Convenience Type Button Component
struct ConvenienceTypeButton: View {
    let type: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .accentOrange)
                
                Text(type)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentOrange : Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.clear : Color.accentOrange.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
