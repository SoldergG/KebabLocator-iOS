import SwiftUI
import MapKit

// MARK: - Location Input View

struct LocationInputView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var addressText = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSettings = false
    @StateObject private var appSettings = AppSettings()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentOrange.opacity(0.12))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.accentOrange)
                            }
                            .padding(.top, 20)
                            
                            Text("Set Your Location")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                            
                            Text("Tell us where you are so we can find\nthe best kebabs near you")
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.bottom, 8)
                        
                        // GPS Button
                        Button {
                            locationManager.requestPermission()
                            locationManager.useGPSLocation()
                            locationManager.startUpdating()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Use GPS Location")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                    Text(locationManager.isUsingManualLocation ? "Switch to automatic GPS" : (locationManager.userLocation != nil ? "GPS active ✓" : "Allow location access"))
                                        .font(.system(size: 13))
                                        .foregroundColor(.textMuted)
                                }
                                
                                Spacer()
                                
                                if !locationManager.isUsingManualLocation && locationManager.userLocation != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(!locationManager.isUsingManualLocation && locationManager.userLocation != nil ? Color.green.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Banner Ad
                        BannerAd(adUnitID: "ca-app-pub-3553204385387394/8457583900", height: 50)
                            .padding(.top, 8)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                            Text("OR")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.textMuted)
                                .tracking(1)
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 20)
                        
                        // Manual Address Input
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Enter Address Manually")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textMuted)
                                
                                TextField("Search for an address...", text: $addressText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.textPrimary)
                                    .focused($isSearchFocused)
                                    .autocorrectionDisabled()
                                    .onChange(of: addressText) { _, newValue in
                                        locationManager.searchAddress(newValue)
                                    }
                                
                                if !addressText.isEmpty {
                                    Button {
                                        addressText = ""
                                        locationManager.searchAddress("")
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.textMuted)
                                    }
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isSearchFocused ? Color.accentOrange : Color.white.opacity(0.06), lineWidth: 1)
                                    )
                            )
                            
                            // Autocomplete Suggestions
                            if !locationManager.addressSuggestions.isEmpty && isSearchFocused {
                                VStack(spacing: 0) {
                                    ForEach(Array(locationManager.addressSuggestions.prefix(5).enumerated()), id: \.offset) { index, suggestion in
                                        Button {
                                            addressText = "\(suggestion.title), \(suggestion.subtitle)"
                                            locationManager.selectCompletion(suggestion)
                                            isSearchFocused = false
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: "mappin.circle")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.accentOrange)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(suggestion.title)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.textPrimary)
                                                        .lineLimit(1)
                                                    Text(suggestion.subtitle)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.textMuted)
                                                        .lineLimit(1)
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(12)
                                        }
                                        
                                        if index < min(4, locationManager.addressSuggestions.count - 1) {
                                            Divider()
                                                .background(Color.white.opacity(0.06))
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.bgElevated)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                        )
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // Search Button
                            if !addressText.isEmpty {
                                Button {
                                    isSearchFocused = false
                                    locationManager.geocodeAddress(addressText) { coordinate in
                                        if let coord = coordinate {
                                            locationManager.setManualLocation(coordinate: coord, address: addressText)
                                        } else {
                                            errorMessage = "Could not find that address. Try being more specific."
                                            showError = true
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        if locationManager.isSearchingAddress {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                        }
                                        Text("Use This Address")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(LinearGradient.kebabGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(color: .accentGlow, radius: 10, x: 0, y: 4)
                                }
                                .disabled(locationManager.isSearchingAddress)
                            }
                        }
                        
                        // Current Location Info
                        if locationManager.isUsingManualLocation {
                            currentLocationCard
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.bgPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                AppSettingsView()
                    .environmentObject(appSettings)
                    .environmentObject(locationManager)
            }
            .alert("Location Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Current Location Card
    
    private var currentLocationCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
                
                Text("Location Set")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Image(systemName: "mappin")
                    .font(.system(size: 13))
                    .foregroundColor(.accentOrange)
                Text(locationManager.manualAddress)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
