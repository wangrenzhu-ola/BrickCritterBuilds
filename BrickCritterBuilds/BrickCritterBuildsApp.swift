import SwiftUI

@main
struct BrickCritterBuildsApp: App {
    @StateObject private var store = CritterBuildStore()
    @StateObject private var premiumStore = PremiumStore()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(store)
                .environmentObject(premiumStore)
        }
    }
}
