import Combine
import Foundation

/// Single source of truth for credit balance + daily subscription quota
/// + rolling 100/hour client cap. Backed by Keychain so state survives
/// reinstall. Thread-safe: mutations funneled through the MainActor.
@MainActor
final class CreditsLedger: ObservableObject {
    @Published private(set) var creditBalance: Int = 0
    @Published private(set) var subDailyCount: Int = 0
    @Published private(set) var subDailyResetDate: Date = Date()

    init() {
        self.creditBalance = Self.readInt(KeychainKey.creditBalance) ?? 0
        self.subDailyCount = Self.readInt(KeychainKey.subDailyCount) ?? 0
        self.subDailyResetDate = Self.readDate(KeychainKey.subDailyResetDate) ?? Date()
        rolloverDailyIfNeeded()
    }

    // MARK: - Free credits bootstrap

    /// Grants `AppLimits.freeStarterCredits` exactly once per user (via Keychain sentinel).
    /// Call after consulting the CloudKit `CreditsMirror` so reinstalls don't re-grant.
    func seedFreeCreditsIfNeeded() {
        guard KeychainHelper.get(KeychainKey.freeCreditsSeeded) == nil else { return }
        creditBalance += AppLimits.freeStarterCredits
        writeBalance()
        KeychainHelper.set("1", for: KeychainKey.freeCreditsSeeded)
    }

    // MARK: - Mutations

    func add(credits: Int) {
        guard credits > 0 else { return }
        creditBalance += credits
        writeBalance()
    }

    func spendCredit() {
        guard creditBalance > 0 else { return }
        creditBalance -= 1
        writeBalance()
    }

    func incrementSubDailyCount() {
        rolloverDailyIfNeeded()
        subDailyCount += 1
        KeychainHelper.set(String(subDailyCount), for: KeychainKey.subDailyCount)
    }

    func rolloverDailyIfNeeded() {
        let cal = Calendar.current
        if !cal.isDate(subDailyResetDate, inSameDayAs: Date()) {
            subDailyCount = 0
            subDailyResetDate = Date()
            KeychainHelper.set(String(subDailyCount), for: KeychainKey.subDailyCount)
            KeychainHelper.set(isoString(subDailyResetDate), for: KeychainKey.subDailyResetDate)
        }
    }

    func subRemaining(for tier: SubscriptionTier?) -> Int {
        guard let tier else { return 0 }
        rolloverDailyIfNeeded()
        return max(0, tier.dailyQuota - subDailyCount)
    }

    // MARK: - Hourly rolling cap

    /// Returns true if spending a diagnose now would exceed the 100/hour cap.
    func wouldExceedHourlyCap(now: Date = .init()) -> Bool {
        let cutoff = now.addingTimeInterval(-3600)
        let ring = loadHourlyRing().filter { $0 > cutoff }
        saveHourlyRing(ring)
        return ring.count >= AppLimits.clientHourlyCap
    }

    func recordHourlyHit(now: Date = .init()) {
        var ring = loadHourlyRing().filter { $0 > now.addingTimeInterval(-3600) }
        ring.append(now)
        saveHourlyRing(ring)
    }

    // MARK: - Persistence helpers

    private func writeBalance() {
        KeychainHelper.set(String(creditBalance), for: KeychainKey.creditBalance)
        let balance = creditBalance
        Task.detached(priority: .background) {
            await CreditsMirror.writeBalance(balance)
        }
    }

    private static func readInt(_ key: String) -> Int? {
        KeychainHelper.get(key).flatMap(Int.init)
    }

    private static func readDate(_ key: String) -> Date? {
        guard let s = KeychainHelper.get(key) else { return nil }
        return ISO8601DateFormatter().date(from: s)
    }

    private func isoString(_ d: Date) -> String {
        ISO8601DateFormatter().string(from: d)
    }

    private func loadHourlyRing() -> [Date] {
        guard let data = KeychainHelper.getData(KeychainKey.hourlyDiagnoseRing),
              let intervals = try? JSONDecoder().decode([TimeInterval].self, from: data)
        else { return [] }
        return intervals.map { Date(timeIntervalSince1970: $0) }
    }

    private func saveHourlyRing(_ dates: [Date]) {
        let intervals = dates.map { $0.timeIntervalSince1970 }
        if let data = try? JSONEncoder().encode(intervals) {
            KeychainHelper.setData(data, for: KeychainKey.hourlyDiagnoseRing)
        }
    }
}
