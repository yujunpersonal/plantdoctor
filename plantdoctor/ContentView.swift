import SwiftUI

struct RootView: View {
    let entitlement: EntitlementStore

    var body: some View {
        TabView {
            DiagnoseView(entitlement: entitlement)
                .tabItem { Label("Diagnose", systemImage: "leaf.fill") }

            HistoryListView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
