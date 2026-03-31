import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("defaultSearchRadius") var defaultSearchRadius: Double = 10.0
}
