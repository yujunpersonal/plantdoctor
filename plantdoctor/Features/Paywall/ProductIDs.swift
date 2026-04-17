import Foundation

enum ProductID {
    static let subSilver = "cn.buddy.plantdoctor.sub.silver"
    static let subGold = "cn.buddy.plantdoctor.sub.gold"
    static let credits100 = "cn.buddy.plantdoctor.credits.100"
    static let credits500 = "cn.buddy.plantdoctor.credits.500"
    static let credits1200 = "cn.buddy.plantdoctor.credits.1200"

    static let allSubscriptions: [String] = [subSilver, subGold]
    static let allConsumables: [String] = [credits100, credits500, credits1200]
    static let all: [String] = allSubscriptions + allConsumables

    static func creditAmount(for id: String) -> Int? {
        switch id {
        case credits100: return 100
        case credits500: return 500
        case credits1200: return 1200
        default: return nil
        }
    }
}

enum SubscriptionTier: String, CaseIterable {
    case silver, gold

    var productID: String {
        switch self {
        case .silver: return ProductID.subSilver
        case .gold: return ProductID.subGold
        }
    }

    var dailyQuota: Int {
        switch self {
        case .silver: return 10
        case .gold: return 25
        }
    }

    /// Ordering for upgrade/downgrade checks. Higher rank = higher tier.
    var rank: Int {
        switch self {
        case .silver: return 1
        case .gold: return 2
        }
    }

    static func from(productID: String) -> SubscriptionTier? {
        switch productID {
        case ProductID.subSilver: return .silver
        case ProductID.subGold: return .gold
        default: return nil
        }
    }
}

enum AppLimits {
    static let freeStarterCredits = 10
    static let clientHourlyCap = 100
}

enum LegalLinks {
    static let eula = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacy = URL(string: "https://support.buddy.cn/en/privacy-policy")!
}
