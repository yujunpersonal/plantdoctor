import Combine
import Foundation

/// Supported display languages. Each case is the BCP-47 code used for
/// `Locale(identifier:)` and for the `AppleLanguages` UserDefaults
/// override that switches the bundle on next launch.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"

    var id: String { rawValue }

    /// Self-identifying display name. Language names are traditionally
    /// shown in their own locale, not translated — so these stay as
    /// static literals rather than going through L10n.
    var displayName: String {
        switch self {
        case .english: return "English"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}

@MainActor
final class LanguageStore: ObservableObject {
    private static let storageKey = "app.language"

    @Published var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: Self.storageKey)
            // Set Apple's built-in override so the next launch picks the
            // matching .lproj bundle. Today only English exists, so this
            // is a no-op; added now so adding a second language later
            // needs no changes here.
            UserDefaults.standard.set([current.rawValue], forKey: "AppleLanguages")
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        self.current = stored.flatMap(AppLanguage.init(rawValue:)) ?? .english
    }
}
