import SwiftUI

struct RootView: View {
    let entitlement: EntitlementStore

    var body: some View {
        TabView {
            DiagnoseView(entitlement: entitlement)
                .tabItem { Label(L10n.Tabs.diagnose, systemImage: "leaf.fill") }

            HistoryListView()
                .tabItem { Label(L10n.Tabs.history, systemImage: "clock.arrow.circlepath") }

            SettingsView()
                .tabItem { Label(L10n.Tabs.settings, systemImage: "gearshape.fill") }
        }
    }
}
