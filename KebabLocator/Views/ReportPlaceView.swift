import SwiftUI

// MARK: - Report Place View
struct ReportPlaceView: View {
    let shop: KebabShop
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedReason: ReportReason = .closed
    @State private var description: String = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    
    enum ReportReason: String, CaseIterable {
        case closed = "closed"
        case wrongLocation = "wrong_location"
        case duplicate = "duplicate"
        case inappropriate = "inappropriate"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .closed: return "Permanently Closed"
            case .wrongLocation: return "Wrong Location"
            case .duplicate: return "Duplicate Entry"
            case .inappropriate: return "Inappropriate Content"
            case .other: return "Other"
            }
        }
        
        var icon: String {
            switch self {
            case .closed: return "xmark.circle.fill"
            case .wrongLocation: return "location.slash"
            case .duplicate: return "doc.on.doc.fill"
            case .inappropriate: return "exclamationmark.triangle.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .closed: return .red
            case .wrongLocation: return .orange
            case .duplicate: return .yellow
            case .inappropriate: return .purple
            case .other: return .gray
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Shop Info
                        shopInfoSection
                        
                        // Report Reason
                        reasonSection
                        
                        // Description
                        descriptionSection
                        
                        // Submit Button
                        submitButton
                        
                        // Banner Ad
                        BannerAd(adUnitID: "ca-app-pub-3553204385387394/4253886069", height: 50)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Report Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your report has been submitted. Thank you for helping keep our map accurate.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Something went wrong. Please try again.")
            }
        }
    }
    
    private var shopInfoSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Shop Image
                AsyncImage(url: URL(string: shop.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.surface)
                        .overlay(
                            Image(systemName: "storefront.fill")
                                .foregroundColor(.textMuted)
                                .font(.system(size: 24))
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Shop Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(shop.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text(shop.address)
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.starYellow)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", shop.rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                        
                        if shop.isVerified {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.openGreen)
                                .font(.system(size: 12))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.surface)
            .cornerRadius(16)
        }
    }
    
    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's wrong with this place?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(ReportReason.allCases, id: \.self) { reason in
                    ReportReasonButton(
                        reason: reason,
                        isSelected: selectedReason == reason
                    ) {
                        selectedReason = reason
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Details (Optional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            TextEditor(text: $description)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
                .frame(minHeight: 100)
                .padding(12)
                .background(Color.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    private var submitButton: some View {
        Button {
            submitReport()
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "flag.fill")
                    Text("Submit Report")
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSubmitting)
        .padding(.bottom, 20)
    }
    
    private func submitReport() {
        isSubmitting = true
        
        favoritesManager.submitReport(shop: shop, reason: selectedReason.rawValue, description: description) { success in
            isSubmitting = false
            if success {
                showSuccessAlert = true
            } else {
                errorMessage = "Failed to submit report. Please try again."
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Report Reason Button
struct ReportReasonButton: View {
    let reason: ReportPlaceView.ReportReason
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: reason.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : reason.color)
                    .frame(width: 24)
                
                Text(reason.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? reason.color : Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.clear : reason.color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
