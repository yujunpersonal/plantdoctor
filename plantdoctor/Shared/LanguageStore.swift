import Combine
import Foundation

/// Supported display languages. Each case is the BCP-47 code used for
/// `Locale(identifier:)` and for the `AppleLanguages` UserDefaults
/// override that switches the bundle on next launch.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case german = "de"
    case french = "fr"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"

    var id: String { rawValue }

    /// Self-identifying display name. Language names are traditionally
    /// shown in their own locale, not translated — so these stay as
    /// static literals rather than going through L10n.
    var displayName: String {
        switch self {
        case .english: return "English"
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .spanish: return "Español"
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
            // Keep `AppleLanguages` in sync so system-provided strings
            // (e.g. StoreKit dialogs) pick the new language on next launch.
            UserDefaults.standard.set([current.rawValue], forKey: "AppleLanguages")
            L10n.setCurrentLanguage(current)
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        let initial = stored.flatMap(AppLanguage.init(rawValue:)) ?? .english
        self.current = initial
        // didSet doesn't fire on init; seed the language bundle manually
        // so first render uses the selected language.
        L10n.setCurrentLanguage(initial)
    }
}
