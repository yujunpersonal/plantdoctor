import Combine
import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var consumables: [Product] = []
    @Published private(set) var activeTier: SubscriptionTier?
    @Published private(set) var isPurchasing = false
    @Published private(set) var isLoadingProducts = false
    @Published var purchaseError: String?

    private var updatesTask: Task<Void, Never>?
    private weak var credits: CreditsLedger?

    func bind(credits: CreditsLedger) {
        self.credits = credits
    }

    func start() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            await self?.listenForTransactionUpdates()
        }
        Task { await refreshEntitlements() }
        Task { await loadProducts() }
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Loading

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let products = try await Product.products(for: ProductID.all)
            let subs = products.filter { $0.type == .autoRenewable }
            let cons = products.filter { $0.type == .consumable }
            self.subscriptions = subs.sorted { priceSort($0, $1) }
            self.consumables = cons.sorted { priceSort($0, $1) }
        } catch {
            purchaseError = "Couldn't load products. Please check your connection."
        }
    }

    private func priceSort(_ a: Product, _ b: Product) -> Bool {
        a.price < b.price
    }

    // MARK: - Purchasing

    func purchase(_ product: Product) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let tx = try checkVerified(verification)
                await handle(transaction: tx)
                await tx.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Entitlement refresh

    func refreshEntitlements() async {
        var best: SubscriptionTier?
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let tx) = entitlement else { continue }
            guard tx.revocationDate == nil else { continue }
            if let t = SubscriptionTier.from(productID: tx.productID) {
                if best == nil || t.rank > best!.rank { best = t }
            }
        }
        self.activeTier = best
    }

    // MARK: - Transaction processing

    private func listenForTransactionUpdates() async {
        for await update in Transaction.updates {
            guard case .verified(let tx) = update else { continue }
            await handle(transaction: tx)
            await tx.finish()
        }
    }

    private func handle(transaction tx: Transaction) async {
        if let amount = ProductID.creditAmount(for: tx.productID) {
            credits?.add(credits: amount)
        }
        // Optimistic tier bump so UI reflects the purchase immediately,
        // even if `currentEntitlements` hasn't caught up yet (StoreKit
        // local testing can lag on crossgrades within a sub group).
        if tx.revocationDate == nil, let t = SubscriptionTier.from(productID: tx.productID) {
            if activeTier == nil || t.rank > (activeTier?.rank ?? 0) {
                activeTier = t
            }
        }
        await refreshEntitlements()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified: throw StoreError.unverified
        }
    }

    enum StoreError: Error { case unverified }
}
