import Foundation

/// Central namespace for user-facing strings and localizable URLs.
///
/// Strings are looked up through `L10n.activeBundle` — a language-specific
/// `.lproj` bundle selected by `LanguageStore`. This bypasses
/// `Bundle.main`'s cached `preferredLocalizations` so mid-session language
/// changes take effect immediately without an app relaunch.
///
/// Each key also carries a `default` English fallback so a missing
/// translation (e.g. after adding a new key before all locales are
/// translated) won't break the UI.
enum L10n {
    /// The `.lproj` bundle currently serving translations. Nil → fall
    /// back to `Bundle.main` (development region).
    nonisolated(unsafe) static var activeBundle: Bundle?

    static func setCurrentLanguage(_ language: AppLanguage) {
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            activeBundle = bundle
        } else {
            activeBundle = nil
        }
    }

    /// Look up a translated string for `key`, or fall back to `default`.
    private static func s(_ key: String, _ `default`: String) -> String {
        let bundle = activeBundle ?? .main
        return bundle.localizedString(forKey: key, value: `default`, table: nil)
    }

    // MARK: - Tabs

    enum Tabs {
        static var diagnose: String { s("tabs.diagnose", "Diagnose") }
        static var history: String { s("tabs.history", "History") }
        static var settings: String { s("tabs.settings", "Settings") }
    }

    // MARK: - Home / Diagnose

    enum Home {
        static var heroTitle: String { s("home.hero.title", "Diagnose your plant") }
        static var heroSubtitle: String { s("home.hero.subtitle", "Snap a photo and get care tips in seconds.") }

        static func planLabel(_ tierName: String) -> String {
            String(format: s("home.plan.label", "%@ plan"), tierName)
        }
        static func remainingToday(_ remaining: Int, _ quota: Int) -> String {
            String(format: s("home.plan.remainingToday", "%1$lld of %2$lld today"), remaining, quota)
        }

        static var creditsChipLabel: String { s("home.credits.label", "Credits") }
        static func creditsCountTitle(_ n: Int) -> String {
            String(format: s("home.credits.countTitle", "%lld credits"), n)
        }
        static var creditsUpsellSubtitle: String {
            s("home.credits.upsellSubtitle", "Tap to get more or go unlimited")
        }

        static var emptyPreviewTitle: String { s("home.empty.title", "Add a plant photo") }
        static var emptyPreviewSubtitle: String { s("home.empty.subtitle", "Close-up, well-lit, affected leaves included.") }

        static var cameraTitle: String { s("home.camera.title", "Camera") }
        static var cameraSubtitle: String { s("home.camera.subtitle", "Take a photo") }
        static var libraryTitle: String { s("home.library.title", "Library") }
        static var librarySubtitle: String { s("home.library.subtitle", "From your photos") }
        static var chooseFromLibrary: String { s("home.library.choose", "Choose from Library") }

        static var analyzeCTA: String { s("home.cta.analyze", "Analyze plant") }

        static var photoTipsHeader: String { s("home.tips.header", "Photo tips") }
        static var photoTip1: String { s("home.tips.1", "Fill the frame with the plant") }
        static var photoTip2: String { s("home.tips.2", "Include affected leaves up close") }
        static var photoTip3: String { s("home.tips.3", "Natural daylight works best") }

        static var analyzingTitle: String { s("home.analyzing.title", "Analyzing your plant…") }
        static var analyzingSubtitle: String { s("home.analyzing.subtitle", "Reading leaves, color, and texture.") }

        static var failureTitle: String { s("home.failure.title", "Couldn’t analyze") }
        static var tryAgain: String { s("home.failure.tryAgain", "Try again") }

        static var hourlyCapAlertTitle: String { s("home.hourlyCap.title", "Slow down a bit") }
        static var hourlyCapAlertMessage: String {
            s("home.hourlyCap.message", "You’ve done 100 diagnoses in the last hour. Take a short break and try again.")
        }
    }

    // MARK: - Subscription tiers

    enum Tier {
        static var free: String { s("tier.free", "Free") }
        static var silver: String { s("tier.silver", "Silver") }
        static var gold: String { s("tier.gold", "Gold") }
    }

    // MARK: - Paywall

    enum Paywall {
        static var navTitle: String { s("paywall.navTitle", "Go Unlimited") }
        static var close: String { s("paywall.close", "Close") }
        static var headerTitle: String { s("paywall.header.title", "Keep Leafwise Growing") }
        static var headerSubtitle: String { s("paywall.header.subtitle", "Subscribe for daily diagnoses, or top up with credits.") }
        static func youHaveCredits(_ n: Int) -> String {
            String(format: s("paywall.header.youHaveCredits", "You have %lld credits"), n)
        }
        static var subscriptionsSection: String { s("paywall.section.subscriptions", "Subscriptions") }
        static var creditPacksSection: String { s("paywall.section.creditPacks", "Credit Packs") }
        static var currentBadge: String { s("paywall.badge.current", "Current") }
        static var includedBadge: String { s("paywall.badge.included", "Included") }
        static func subscriptionSubtitle(_ dailyQuota: Int) -> String {
            String(format: s("paywall.subscription.subtitle", "%lld diagnoses/day · monthly"), dailyQuota)
        }
        static func creditPackSubtitle(_ amount: Int) -> String {
            String(format: s("paywall.creditPack.subtitle", "%lld diagnose credits"), amount)
        }
        static var restorePurchases: String { s("paywall.restore", "Restore Purchases") }
        static var legalDisclaimer: String {
            s("paywall.legal.disclaimer", "Subscriptions auto-renew monthly until cancelled in App Store settings. Credit packs are one-time purchases.")
        }
        static var termsEula: String { s("paywall.legal.termsEula", "Terms (EULA)") }
        static var privacyPolicy: String { s("paywall.legal.privacy", "Privacy Policy") }
        static var loadingProducts: String { s("paywall.loading", "Loading plans…") }
        static var plansUnavailableTitle: String { s("paywall.unavailable.title", "Plans unavailable") }
        static var plansUnavailableMessage: String {
            s("paywall.unavailable.message", "We couldn’t reach the App Store. Check your connection and try again.")
        }
        static var retry: String { s("paywall.retry", "Retry") }
        static var purchaseAlertTitle: String { s("paywall.alert.title", "Purchase") }
        static var ok: String { s("common.ok", "OK") }
    }

    // MARK: - History

    enum History {
        static var navTitle: String { s("history.navTitle", "History") }
        static var sectionHeader: String { s("history.sectionHeader", "Recent diagnoses") }
        static var emptyTitle: String { s("history.empty.title", "No diagnoses yet") }
        static var emptyMessage: String {
            s("history.empty.message", "Your past plant diagnoses will appear here and sync via iCloud.")
        }
        static var unknownPlant: String { s("history.row.unknownPlant", "Unknown plant") }
        static var noCondition: String { s("history.row.noCondition", "No condition detected") }
        static var deleteConfirmTitle: String { s("history.delete.title", "Delete this diagnosis?") }
        static var deleteConfirmMessage: String {
            s("history.delete.message", "This diagnosis will be removed from your history. This can’t be undone.")
        }
        static var delete: String { s("common.delete", "Delete") }
        static var cancel: String { s("common.cancel", "Cancel") }
    }

    // MARK: - Settings

    enum Settings {
        static var navTitle: String { s("settings.navTitle", "Settings") }
        static var currentPlan: String { s("settings.plan.current", "Current plan") }
        static var freeBadge: String { s("settings.plan.freeBadge", "FREE") }
        static var todayLabel: String { s("settings.plan.today", "Today") }
        static func remainingLeft(_ remaining: Int, _ quota: Int) -> String {
            String(format: s("settings.plan.remainingLeft", "%1$lld of %2$lld left"), remaining, quota)
        }
        static var upgradePrompt: String {
            s("settings.plan.upgradePrompt", "Upgrade for daily diagnoses, or top up with credit packs.")
        }
        static var creditsStatLabel: String { s("settings.stats.credits", "Credits") }
        static var todayLeftStatLabel: String { s("settings.stats.todayLeft", "Today left") }
        static var todayLeftNone: String { s("settings.stats.todayLeftNone", "—") }
        static var upgradeOrBuy: String { s("settings.action.upgradeOrBuy", "Upgrade or buy credits") }
        static var managePlan: String { s("settings.action.managePlan", "Manage plan") }
        static var manageSubtitle: String { s("settings.action.manageSubtitle", "Subscriptions and one-time packs") }
        static var restorePurchases: String { s("settings.action.restore", "Restore purchases") }
        static var restoreSubtitle: String {
            s("settings.action.restoreSubtitle", "Recover previous subscriptions and credits")
        }
        static func footer(_ version: String) -> String {
            String(format: s("settings.footer", "Leafwise · v%@"), version)
        }
        static var languageRowTitle: String { s("settings.language.title", "Language") }
        static var languageRowSubtitle: String { s("settings.language.subtitle", "Choose the app language") }
        static var languagePickerTitle: String { s("settings.language.pickerTitle", "Language") }
        static var languageRestartNote: String {
            s("settings.language.restartNote", "Language changes take effect after relaunching the app.")
        }
    }

    // MARK: - Severity

    enum Severity {
        static var healthy: String { s("severity.healthy", "Healthy") }
        static var mild: String { s("severity.mild", "Mild") }
        static var moderate: String { s("severity.moderate", "Moderate") }
        static var severe: String { s("severity.severe", "Severe") }

        /// Map the raw enum value ("healthy" / "mild" / "moderate" / "severe")
        /// returned by the model to its localized display label. Falls back
        /// to a capitalized version of the raw value for unknown inputs.
        static func label(_ raw: String) -> String {
            switch raw.lowercased() {
            case "healthy": return healthy
            case "mild": return mild
            case "moderate": return moderate
            case "severe": return severe
            default: return raw.capitalized
            }
        }
    }

    // MARK: - Result

    enum Result {
        static var navTitle: String { s("result.navTitle", "Diagnosis") }
        static func confidence(_ pct: Int) -> String {
            String(format: s("result.confidence", "Confidence %lld%%"), pct)
        }
        static var sectionCauses: String { s("result.section.causes", "Likely causes") }
        static var sectionFixes: String { s("result.section.fixes", "What to do") }
        static var sectionCareTips: String { s("result.section.careTips", "Care tips") }
        static var done: String { s("result.done", "Done") }
        static var storedDisclaimer: String {
            s("result.storedDisclaimer", "Stored diagnosis. AI guidance, not a substitute for a professional.")
        }
    }

    // MARK: - Errors

    enum Errors {
        static var offline: String { s("error.offline", "You appear to be offline. Check your connection and try again.") }
        static var encodingFailed: String { s("error.encodingFailed", "We couldn’t prepare the photo for upload. Try a different image.") }
        static var authFailed: String { s("error.authFailed", "Authentication failed. Please update the app.") }
        static var rateLimitedDevice: String { s("error.rateLimited.device", "You’ve hit the per-device hourly limit. Try again in a bit.") }
        static var rateLimitedGlobal: String { s("error.rateLimited.global", "Our servers are busy. Please try again in a minute.") }
        static var payloadTooLarge: String { s("error.payloadTooLarge", "The photo is too large. Try a smaller image.") }
        static var server: String { s("error.server", "Diagnosis service is temporarily unavailable. Try again shortly.") }
        static var decoding: String { s("error.decoding", "We got an unexpected response. Please try again.") }
        static var generic: String { s("error.generic", "Something went wrong. Please try again.") }
        static var productsLoadFailed: String { s("error.productsLoadFailed", "Couldn’t load products. Please check your connection.") }
        static func restoreFailed(_ reason: String) -> String {
            String(format: s("error.restoreFailed", "Restore failed: %@"), reason)
        }
    }

    // MARK: - Legal links (URLs)

    /// URLs are picked per `AppLanguage`. EULAs point at Apple's
    /// country-specific App Store terms (Apple's `stdeula` template is
    /// English-only). Privacy policy slugs follow `support.buddy.cn`'s
    /// existing path convention.
    enum Legal {
        static func eulaURL(for language: AppLanguage) -> URL {
            switch language {
            case .english:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
            case .simplifiedChinese:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/cn/terms.html")!
            case .traditionalChinese:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/tw/terms.html")!
            case .german:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/de/terms.html")!
            case .french:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/fr/terms.html")!
            case .japanese:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/jp/terms.html")!
            case .korean:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/kr/terms.html")!
            case .spanish:
                return URL(string: "https://www.apple.com/legal/internet-services/itunes/es/terms.html")!
            }
        }

        static func privacyURL(for language: AppLanguage) -> URL {
            let slug: String
            switch language {
            case .english: slug = "en"
            case .simplifiedChinese: slug = "zh-Hans"
            case .traditionalChinese: slug = "zh-Hant"
            case .german: slug = "de"
            case .french: slug = "fr"
            case .japanese: slug = "ja"
            case .korean: slug = "ko"
            case .spanish: slug = "es"
            }
            return URL(string: "https://support.buddy.cn/\(slug)/privacy-policy")!
        }
    }
}
