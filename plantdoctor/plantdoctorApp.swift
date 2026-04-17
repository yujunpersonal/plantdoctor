import SwiftData
import SwiftUI

@main
struct plantdoctorApp: App {
    @StateObject private var credits = CreditsLedger()
    @StateObject private var store = StoreManager()
    @StateObject private var entitlement: EntitlementStore
    @StateObject private var language = LanguageStore()

    private let modelContainer: ModelContainer

    init() {
        let credits = CreditsLedger()
        let store = StoreManager()
        let entitlement = EntitlementStore(credits: credits, store: store)
        _credits = StateObject(wrappedValue: credits)
        _store = StateObject(wrappedValue: store)
        _entitlement = StateObject(wrappedValue: entitlement)
        store.bind(credits: credits)

        do {
            let config = ModelConfiguration(
                schema: Schema([DiagnoseRecord.self]),
                cloudKitDatabase: .private("iCloud.cn.buddy.plantdoctor"),
            )
            self.modelContainer = try ModelContainer(for: DiagnoseRecord.self, configurations: config)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(entitlement: entitlement)
                .environmentObject(credits)
                .environmentObject(store)
                .environmentObject(entitlement)
                .environmentObject(language)
                .environment(\.locale, language.current.locale)
                .tint(Theme.leaf)
                .task {
                    store.start()
                    await AppBootstrap.run(credits: credits)
                }
        }
        .modelContainer(modelContainer)
    }
}
