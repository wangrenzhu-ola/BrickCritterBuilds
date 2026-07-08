import SwiftUI

struct AppView: View {
    @EnvironmentObject private var store: CritterBuildStore
    @State private var path: [AppRoute] = []

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                HomeView(path: $path)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .studio(let draft): CritterBuildStudioView(path: $path, initialDraft: draft)
                        case .detail(let id): CritterBuildDetailView(path: $path, recordID: id)
                        case .paywall: PaywallView()
                        case .privacy: PrivacyBoundaryView()
                        }
                    }
            }
            .tabItem { Label("Scenes", systemImage: "wineglass") }

            NavigationStack { SettingsPrivacyView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .safeAreaInset(edge: .top) {
            if let message = store.lastSuccessMessage {
                SuccessToast(message: message) { store.lastSuccessMessage = nil }
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: store.lastSuccessMessage)
    }
}
