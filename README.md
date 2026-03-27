# Kebab Locator - iOS (Premium Edition) 🥙

Kebab Locator is a premium iOS application built with SwiftUI that helps users find the best kebab spots around them. It features high-quality design, real-time map integration, and an owner portal for business growth.

## 🚀 Features

- **Discover**: Find top-rated kebab spots in your area.
- **Interactive Map**: Navigate through a custom premium map to find your next meal.
- **Explore**: Search by category (Döner, Falafel, Dürüm, Shawarma) and filters.
- **Owner Portal**: Shop owners can register and add their own business to the map via Supabase integration.
- **Premium Design**: Dark mode, custom icons, and smooth animations.

## 🛠 Tech Stack

- **Framework**: SwiftUI
- **Database**: Supabase (PostgreSQL)
- **Services**: OpenStreetMap (OSM) Overpass API, Google Places
- **Authentication**: Supabase Auth

## 📦 Getting Started

1. Clone this repository.
2. Open `KebabLocator.xcodeproj` in Xcode.
3. Update `Info.plist` with your API keys.
4. Run the SQL script found in `supabase_setup.sql` in your Supabase project.
5. Run the app on your simulator or physical device!

## 📄 License

This project is licensed under the MIT License.
  Meter anuncios:

  AdMob Investigation & Configuration Guide
I've reviewed your project's AdMob setup and here is the summary of what you need to know and change before submitting the app to the App Store.

🔍 Current Status
App ID (Info.plist): ca-app-pub-3758472607555726~1637933842
This looks like a production ID. Please verify in your AdMob console that this is the correct App ID for your project.
Ad Unit IDs (Views): Currently using Google Test IDs.
Most of your views (Home, Explore, ShopDetail, etc.) are using IDs like ca-app-pub-3940256099942544/.... These will only show test ads and will not generate revenue.
🚀 Steps to Switch to Real Ads
Before submitting to the App Store, you must replace the Test IDs with your own production Ad Unit IDs.

1. Create Ad Units in AdMob
Go to your AdMob Console, select your app, and create Banner ad units. You will get IDs that look like ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY.

2. Update the Code
You need to update the BannerAd(adUnitID: "...", height: 50) calls in the following files:

HomeView.swift (Line 100):
swift
BannerAd(adUnitID: "YOUR_REAL_BANNER_ID", height: 50)
ExploreView.swift (Line 125):
swift
BannerAd(adUnitID: "YOUR_REAL_BANNER_ID", height: 50)
ShopDetailView.swift (Line 177):
swift
BannerAd(adUnitID: "YOUR_REAL_BANNER_ID", height: 50)
Other Views: Also check MapTabView, FavoritesView, LocationInputView, AddKebabView, SubmitVerificationView, and ReportPlaceView.
3. Test on Real Devices
IMPORTANT

When testing with real Ad Unit IDs, never click on your own ads. To test safely, you should add your device as a Test Device in the AdMob console. This allows you to see real ads without the risk of being banned for "invalid activity".

🛡️ App Store Approval
You can and should put the real IDs before sending the app for approval. Apple's reviewers will see the ads (or placeholders if they are not yet filled by Google) as part of the normal app review process.

If you have any more questions about the setup, feel free to ask!