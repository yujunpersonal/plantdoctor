import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var credits: CreditsLedger
    @EnvironmentObject private var entitlement: EntitlementStore
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section("Your plan") {
                    HStack {
                        Text("Subscription")
                        Spacer()
                        Text(tierLabel)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Credits")
                        Spacer()
                        Text("\(credits.creditBalance)")
                            .foregroundStyle(.secondary)
                    }
                    if let tier = store.activeTier {
                        HStack {
                            Text("Today")
                            Spacer()
                            Text("\(credits.subRemaining(for: tier)) / \(tier.dailyQuota) left")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button("Upgrade or buy credits") { showPaywall = true }
                        .tint(Theme.leaf)
                    Button("Restore purchases") {
                        Task { await store.restore() }
                    }
                    .tint(Theme.leaf)
                }

                Section("About") {
                    Link(destination: LegalLinks.eula) {
                        Label("Terms of Use (EULA)", systemImage: "doc.text")
                    }
                    Link(destination: LegalLinks.privacy) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private var tierLabel: String {
        switch store.activeTier {
        case .some(.gold): return "Gold"
        case .some(.silver): return "Silver"
        case .none: return "Free"
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
