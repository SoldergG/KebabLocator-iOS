#if canImport(GoogleMobileAds)
import SwiftUI
import GoogleMobileAds

// MARK: - Banner Ad View (AdMob)
struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let height: CGFloat

    init(adUnitID: String, height: CGFloat) {
        self.adUnitID = adUnitID
        self.height = height
    }

    func makeUIView(context: Context) -> UIView {
        let bannerView = BannerView(adSize: adSizeFor(cgSize: CGSize(width: 320, height: height)))
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = context.coordinator.rootViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: BannerAdView

        init(_ parent: BannerAdView) {
            self.parent = parent
        }

        var rootViewController: UIViewController {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.windows.first?.rootViewController ?? UIViewController()
        }
    }
}

#else

// MARK: - Banner Ad View (Placeholder when GoogleMobileAds is unavailable)
struct BannerAdView: View {
    let adUnitID: String
    let height: CGFloat

    init(adUnitID: String, height: CGFloat) {
        self.adUnitID = adUnitID
        self.height = height
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.06))
            HStack(spacing: 8) {
                Image(systemName: "rectangle.adbadge.fill")
                    .foregroundColor(.textMuted)
                Text("Ad placeholder")
                    .foregroundColor(.textMuted)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 8)
        }
        .frame(height: height)
    }
}

#endif

// MARK: - SwiftUI Banner Ad Wrapper
struct BannerAd: View {
    let adUnitID: String
    let height: CGFloat

    init(adUnitID: String, height: CGFloat = 50) {
        self.adUnitID = adUnitID
        self.height = height
    }

    var body: some View {
        BannerAdView(adUnitID: adUnitID, height: height)
            .frame(height: height)
    }
}
