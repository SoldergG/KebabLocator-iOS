import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    private let radiusOptions: [Double] = [5, 10, 20, 40]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        settingsSection(title: "Search Radius", icon: "scope") {
                            VStack(spacing: 0) {
                                ForEach(radiusOptions, id: \.self) { radius in
                                    Button {
                                        appSettings.defaultSearchRadius = radius
                                        locationManager.searchRadius = radius
                                    } label: {
                                        HStack {
                                            Text("\(Int(radius)) km")
                                                .font(.system(size: 16))
                                                .foregroundColor(.textPrimary)
                                            Spacer()
                                            if appSettings.defaultSearchRadius == radius {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.accentOrange)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                    }
                                    if radius != radiusOptions.last {
                                        Divider().background(Color.white.opacity(0.06))
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        settingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: 0) {
                                infoRow(label: "Version", value: "1.0")
                                Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
                                infoRow(label: "Data sources", value: "OSM · Google · Foursquare")
                            }
                            .background(Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.bgPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentOrange)
                }
            }
        }
    }

    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundColor(.accentOrange)
                Text(title.uppercased()).font(.system(size: 12, weight: .semibold)).foregroundColor(.textMuted).tracking(0.6)
            }
            content()
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 16)).foregroundColor(.textPrimary)
            Spacer()
            Text(value).font(.system(size: 15)).foregroundColor(.textMuted)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}
