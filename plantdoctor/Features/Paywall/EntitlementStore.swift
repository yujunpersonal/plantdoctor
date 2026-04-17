import Foundation
import Combine

@MainActor
final class EntitlementStore: ObservableObject {
    @Published private(set) var canDiagnose: Bool = false
    @Published private(set) var statusText: String = ""

    private let credits: CreditsLedger
    private let store: StoreManager
    private var cancellables = Set<AnyCancellable>()

    init(credits: CreditsLedger, store: StoreManager) {
        self.credits = credits
        self.store = store
        recompute()

        credits.$creditBalance.sink { [weak self] _ in self?.recompute() }.store(in: &cancellables)
        credits.$subDailyCount.sink { [weak self] _ in self?.recompute() }.store(in: &cancellables)
        store.$activeTier.sink { [weak self] _ in self?.recompute() }.store(in: &cancellables)
    }

    enum Preflight {
        case okUsingSubscription
        case okUsingCredits
        case hourlyCapHit
        case needsPaywall
    }

    /// Check whether a diagnose is allowed right now, without mutating state.
    /// Stacking order: subscription daily quota first, then consumable credits.
    func preflight() -> Preflight {
        if credits.wouldExceedHourlyCap() { return .hourlyCapHit }
        if let tier = store.activeTier, credits.subRemaining(for: tier) > 0 {
            return .okUsingSubscription
        }
        if credits.creditBalance > 0 { return .okUsingCredits }
        return .needsPaywall
    }

    /// Commit a spend after a successful diagnosis. Must pair with `preflight()`.
    func commit(using preflight: Preflight) {
        switch preflight {
        case .okUsingSubscription:
            credits.incrementSubDailyCount()
            credits.recordHourlyHit()
        case .okUsingCredits:
            credits.spendCredit()
            credits.recordHourlyHit()
        case .hourlyCapHit, .needsPaywall:
            break
        }
    }

    private func recompute() {
        let subRemaining = credits.subRemaining(for: store.activeTier)
        canDiagnose = subRemaining > 0 || credits.creditBalance > 0

        if let tier = store.activeTier {
            let label = tier == .gold ? "Gold" : "Silver"
            statusText = "\(label) · \(subRemaining) left today · \(credits.creditBalance) credits"
        } else {
            statusText = "\(credits.creditBalance) credits"
        }
    }
}
