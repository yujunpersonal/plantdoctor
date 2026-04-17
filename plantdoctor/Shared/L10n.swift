import Foundation

/// Central namespace for user-facing strings and localizable URLs.
///
/// Every string goes through `String(localized:defaultValue:)`, which
/// uses the key for lookup in a Strings Catalog at runtime and falls
/// back to the English default if no translation is available. No
/// catalog is required today — adding `Localizable.xcstrings` later
/// will pick up every key automatically with no source changes.
enum L10n {
    // MARK: - Tabs

    enum Tabs {
        static var diagnose: String {
            String(localized: "tabs.diagnose", defaultValue: "Diagnose")
        }
        static var history: String {
            String(localized: "tabs.history", defaultValue: "History")
        }
        static var settings: String {
            String(localized: "tabs.settings", defaultValue: "Settings")
        }
    }

    // MARK: - Home / Diagnose

    enum Home {
        static var heroTitle: String {
            String(localized: "home.hero.title", defaultValue: "Diagnose your plant")
        }
        static var heroSubtitle: String {
            String(localized: "home.hero.subtitle", defaultValue: "Snap a photo and get care tips in seconds.")
        }
        static func planLabel(_ tierName: String) -> String {
            String(localized: "home.plan.label", defaultValue: "\(tierName) plan")
        }
        static func remainingToday(_ remaining: Int, _ quota: Int) -> String {
            String(localized: "home.plan.remainingToday", defaultValue: "\(remaining) of \(quota) today")
        }
        static var creditsChipLabel: String {
            String(localized: "home.credits.label", defaultValue: "Credits")
        }
        static func creditsCountTitle(_ n: Int) -> String {
            String(localized: "home.credits.countTitle", defaultValue: "\(n) credits")
        }
        static var creditsUpsellSubtitle: String {
            String(localized: "home.credits.upsellSubtitle", defaultValue: "Tap to get more or go unlimited")
        }
        static var emptyPreviewTitle: String {
            String(localized: "home.empty.title", defaultValue: "Add a plant photo")
        }
        static var emptyPreviewSubtitle: String {
            String(localized: "home.empty.subtitle", defaultValue: "Close-up, well-lit, affected leaves included.")
        }
        static var cameraTitle: String {
            String(localized: "home.camera.title", defaultValue: "Camera")
        }
        static var cameraSubtitle: String {
            String(localized: "home.camera.subtitle", defaultValue: "Take a photo")
        }
        static var libraryTitle: String {
            String(localized: "home.library.title", defaultValue: "Library")
        }
        static var librarySubtitle: String {
            String(localized: "home.library.subtitle", defaultValue: "From your photos")
        }
        static var chooseFromLibrary: String {
            String(localized: "home.library.choose", defaultValue: "Choose from Library")
        }
        static var analyzeCTA: String {
            String(localized: "home.cta.analyze", defaultValue: "Analyze plant")
        }
        static var photoTipsHeader: String {
            String(localized: "home.tips.header", defaultValue: "Photo tips")
        }
        static var photoTip1: String {
            String(localized: "home.tips.1", defaultValue: "Fill the frame with the plant")
        }
        static var photoTip2: String {
            String(localized: "home.tips.2", defaultValue: "Include affected leaves up close")
        }
        static var photoTip3: String {
            String(localized: "home.tips.3", defaultValue: "Natural daylight works best")
        }
        static var analyzingTitle: String {
            String(localized: "home.analyzing.title", defaultValue: "Analyzing your plant…")
        }
        static var analyzingSubtitle: String {
            String(localized: "home.analyzing.subtitle", defaultValue: "Reading leaves, color, and texture.")
        }
        static var failureTitle: String {
            String(localized: "home.failure.title", defaultValue: "Couldn't analyze")
        }
        static var tryAgain: String {
            String(localized: "home.failure.tryAgain", defaultValue: "Try again")
        }
        static var hourlyCapAlertTitle: String {
            String(localized: "home.hourlyCap.title", defaultValue: "Slow down a bit")
        }
        static var hourlyCapAlertMessage: String {
            String(localized: "home.hourlyCap.message", defaultValue: "You've done 100 diagnoses in the last hour. Take a short break and try again.")
        }
    }

    // MARK: - Subscription tiers

    enum Tier {
        static var free: String {
            String(localized: "tier.free", defaultValue: "Free")
        }
        static var silver: String {
            String(localized: "tier.silver", defaultValue: "Silver")
        }
        static var gold: String {
            String(localized: "tier.gold", defaultValue: "Gold")
        }
    }

    // MARK: - Paywall

    enum Paywall {
        static var navTitle: String {
            String(localized: "paywall.navTitle", defaultValue: "Go Unlimited")
        }
        static var close: String {
            String(localized: "paywall.close", defaultValue: "Close")
        }
        static var headerTitle: String {
            String(localized: "paywall.header.title", defaultValue: "Keep Leafwise Growing")
        }
        static var headerSubtitle: String {
            String(localized: "paywall.header.subtitle", defaultValue: "Subscribe for daily diagnoses, or top up with credits.")
        }
        static func youHaveCredits(_ n: Int) -> String {
            String(localized: "paywall.header.youHaveCredits", defaultValue: "You have \(n) credits")
        }
        static var subscriptionsSection: String {
            String(localized: "paywall.section.subscriptions", defaultValue: "Subscriptions")
        }
        static var creditPacksSection: String {
            String(localized: "paywall.section.creditPacks", defaultValue: "Credit Packs")
        }
        static var currentBadge: String {
            String(localized: "paywall.badge.current", defaultValue: "Current")
        }
        static var includedBadge: String {
            String(localized: "paywall.badge.included", defaultValue: "Included")
        }
        static func subscriptionSubtitle(_ dailyQuota: Int) -> String {
            String(localized: "paywall.subscription.subtitle", defaultValue: "\(dailyQuota) diagnoses/day · monthly")
        }
        static func creditPackSubtitle(_ amount: Int) -> String {
            String(localized: "paywall.creditPack.subtitle", defaultValue: "\(amount) diagnose credits")
        }
        static var restorePurchases: String {
            String(localized: "paywall.restore", defaultValue: "Restore Purchases")
        }
        static var legalDisclaimer: String {
            String(localized: "paywall.legal.disclaimer", defaultValue: "Subscriptions auto-renew monthly until cancelled in App Store settings. Credit packs are one-time purchases.")
        }
        static var termsEula: String {
            String(localized: "paywall.legal.termsEula", defaultValue: "Terms (EULA)")
        }
        static var privacyPolicy: String {
            String(localized: "paywall.legal.privacy", defaultValue: "Privacy Policy")
        }
        static var loadingProducts: String {
            String(localized: "paywall.loading", defaultValue: "Loading plans…")
        }
        static var plansUnavailableTitle: String {
            String(localized: "paywall.unavailable.title", defaultValue: "Plans unavailable")
        }
        static var plansUnavailableMessage: String {
            String(localized: "paywall.unavailable.message", defaultValue: "We couldn't reach the App Store. Check your connection and try again.")
        }
        static var retry: String {
            String(localized: "paywall.retry", defaultValue: "Retry")
        }
        static var purchaseAlertTitle: String {
            String(localized: "paywall.alert.title", defaultValue: "Purchase")
        }
        static var ok: String {
            String(localized: "common.ok", defaultValue: "OK")
        }
    }

    // MARK: - History

    enum History {
        static var navTitle: String {
            String(localized: "history.navTitle", defaultValue: "History")
        }
        static var sectionHeader: String {
            String(localized: "history.sectionHeader", defaultValue: "Recent diagnoses")
        }
        static var emptyTitle: String {
            String(localized: "history.empty.title", defaultValue: "No diagnoses yet")
        }
        static var emptyMessage: String {
            String(localized: "history.empty.message", defaultValue: "Your past plant diagnoses will appear here and sync via iCloud.")
        }
        static var unknownPlant: String {
            String(localized: "history.row.unknownPlant", defaultValue: "Unknown plant")
        }
        static var noCondition: String {
            String(localized: "history.row.noCondition", defaultValue: "No condition detected")
        }
        static var deleteConfirmTitle: String {
            String(localized: "history.delete.title", defaultValue: "Delete this diagnosis?")
        }
        static var deleteConfirmMessage: String {
            String(localized: "history.delete.message", defaultValue: "This diagnosis will be removed from your history. This can't be undone.")
        }
        static var delete: String {
            String(localized: "common.delete", defaultValue: "Delete")
        }
        static var cancel: String {
            String(localized: "common.cancel", defaultValue: "Cancel")
        }
    }

    // MARK: - Settings

    enum Settings {
        static var navTitle: String {
            String(localized: "settings.navTitle", defaultValue: "Settings")
        }
        static var currentPlan: String {
            String(localized: "settings.plan.current", defaultValue: "Current plan")
        }
        static var freeBadge: String {
            String(localized: "settings.plan.freeBadge", defaultValue: "FREE")
        }
        static var todayLabel: String {
            String(localized: "settings.plan.today", defaultValue: "Today")
        }
        static func remainingLeft(_ remaining: Int, _ quota: Int) -> String {
            String(localized: "settings.plan.remainingLeft", defaultValue: "\(remaining) of \(quota) left")
        }
        static var upgradePrompt: String {
            String(localized: "settings.plan.upgradePrompt", defaultValue: "Upgrade for daily diagnoses, or top up with credit packs.")
        }
        static var creditsStatLabel: String {
            String(localized: "settings.stats.credits", defaultValue: "Credits")
        }
        static var todayLeftStatLabel: String {
            String(localized: "settings.stats.todayLeft", defaultValue: "Today left")
        }
        static var todayLeftNone: String {
            String(localized: "settings.stats.todayLeftNone", defaultValue: "—")
        }
        static var upgradeOrBuy: String {
            String(localized: "settings.action.upgradeOrBuy", defaultValue: "Upgrade or buy credits")
        }
        static var managePlan: String {
            String(localized: "settings.action.managePlan", defaultValue: "Manage plan")
        }
        static var manageSubtitle: String {
            String(localized: "settings.action.manageSubtitle", defaultValue: "Subscriptions and one-time packs")
        }
        static var restorePurchases: String {
            String(localized: "settings.action.restore", defaultValue: "Restore purchases")
        }
        static var restoreSubtitle: String {
            String(localized: "settings.action.restoreSubtitle", defaultValue: "Recover previous subscriptions and credits")
        }
        static func footer(_ version: String) -> String {
            String(localized: "settings.footer", defaultValue: "Leafwise · v\(version)")
        }
        static var languageRowTitle: String {
            String(localized: "settings.language.title", defaultValue: "Language")
        }
        static var languageRowSubtitle: String {
            String(localized: "settings.language.subtitle", defaultValue: "Choose the app language")
        }
        static var languagePickerTitle: String {
            String(localized: "settings.language.pickerTitle", defaultValue: "Language")
        }
    }

    // MARK: - Result

    enum Result {
        static var navTitle: String {
            String(localized: "result.navTitle", defaultValue: "Diagnosis")
        }
        static func confidence(_ pct: Int) -> String {
            String(localized: "result.confidence", defaultValue: "Confidence \(pct)%")
        }
        static var sectionCauses: String {
            String(localized: "result.section.causes", defaultValue: "Likely causes")
        }
        static var sectionFixes: String {
            String(localized: "result.section.fixes", defaultValue: "What to do")
        }
        static var sectionCareTips: String {
            String(localized: "result.section.careTips", defaultValue: "Care tips")
        }
        static var done: String {
            String(localized: "result.done", defaultValue: "Done")
        }
        static var storedDisclaimer: String {
            String(localized: "result.storedDisclaimer", defaultValue: "Stored diagnosis. AI guidance, not a substitute for a professional.")
        }
    }

    // MARK: - Errors

    enum Errors {
        static var offline: String {
            String(localized: "error.offline", defaultValue: "You appear to be offline. Check your connection and try again.")
        }
        static var encodingFailed: String {
            String(localized: "error.encodingFailed", defaultValue: "We couldn't prepare the photo for upload. Try a different image.")
        }
        static var authFailed: String {
            String(localized: "error.authFailed", defaultValue: "Authentication failed. Please update the app.")
        }
        static var rateLimitedDevice: String {
            String(localized: "error.rateLimited.device", defaultValue: "You've hit the per-device hourly limit. Try again in a bit.")
        }
        static var rateLimitedGlobal: String {
            String(localized: "error.rateLimited.global", defaultValue: "Our servers are busy. Please try again in a minute.")
        }
        static var payloadTooLarge: String {
            String(localized: "error.payloadTooLarge", defaultValue: "The photo is too large. Try a smaller image.")
        }
        static var server: String {
            String(localized: "error.server", defaultValue: "Diagnosis service is temporarily unavailable. Try again shortly.")
        }
        static var decoding: String {
            String(localized: "error.decoding", defaultValue: "We got an unexpected response. Please try again.")
        }
        static var generic: String {
            String(localized: "error.generic", defaultValue: "Something went wrong. Please try again.")
        }
        static var productsLoadFailed: String {
            String(localized: "error.productsLoadFailed", defaultValue: "Couldn't load products. Please check your connection.")
        }
        static func restoreFailed(_ reason: String) -> String {
            String(localized: "error.restoreFailed", defaultValue: "Restore failed: \(reason)")
        }
    }

    // MARK: - Legal links (URLs)

    enum Legal {
        static let eulaURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
        static let privacyURL = URL(string: "https://support.buddy.cn/en/privacy-policy")!
    }
}
