import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var credits: CreditsLedger
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if store.isLoadingProducts && store.subscriptions.isEmpty && store.consumables.isEmpty {
                        loadingState
                    } else if store.subscriptions.isEmpty && store.consumables.isEmpty {
                        emptyState
                    } else {
                        subscriptionsSection
                        creditsSection
                    }

                    restoreButton

                    legalFooter
                }
                .padding(20)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle(L10n.Paywall.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Paywall.close) { dismiss() }
                }
            }
            .alert(L10n.Paywall.purchaseAlertTitle, isPresented: Binding(
                get: { store.purchaseError != nil },
                set: { if !$0 { store.purchaseError = nil } }
            )) {
                Button(L10n.Paywall.ok) { store.purchaseError = nil }
            } message: {
                Text(store.purchaseError ?? "")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 54))
                .foregroundStyle(Theme.leaf)
            Text(L10n.Paywall.headerTitle)
                .font(.title2.bold())
            Text(L10n.Paywall.headerSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(L10n.Paywall.youHaveCredits(credits.creditBalance))
                .font(.footnote)
                .foregroundStyle(Theme.leaf)
        }
    }

    private var loadingState: some View {
        VStack(spacing: 10) {
            ProgressView()
            Text(L10n.Paywall.loadingProducts)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.orange)
            Text(L10n.Paywall.plansUnavailableTitle)
                .font(.headline)
            Text(L10n.Paywall.plansUnavailableMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(L10n.Paywall.retry) {
                Task { await store.loadProducts() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.leaf)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(L10n.Paywall.subscriptionsSection)
            ForEach(store.subscriptions) { product in
                productCard(product)
            }
        }
    }

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(L10n.Paywall.creditPacksSection)
            ForEach(store.consumables) { product in
                productCard(product)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private func productCard(_ product: Product) -> some View {
        let state = purchaseState(for: product)
        return Button {
            guard state.isPurchasable else { return }
            Task { await store.purchase(product) }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: iconName(for: product))
                    .font(.title2)
                    .foregroundStyle(state.isPurchasable ? Theme.leaf : .secondary)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName).font(.body.bold())
                    Text(subtitle(for: product))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                trailingLabel(for: product, state: state)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(state.isPurchasable ? Theme.leafLight : Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .opacity(state.isPurchasable ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(store.isPurchasing || !state.isPurchasable)
    }

    @ViewBuilder
    private func trailingLabel(for product: Product, state: ProductPurchaseState) -> some View {
        switch state {
        case .purchasable:
            Text(product.displayPrice)
                .font(.body.bold())
                .foregroundStyle(Theme.leaf)
        case .current:
            badge(text: L10n.Paywall.currentBadge, tint: Theme.leaf)
        case .lowerTier:
            badge(text: L10n.Paywall.includedBadge, tint: .secondary)
        }
    }

    private func badge(text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 8).padding(.vertical, 4)
            .foregroundStyle(tint)
            .background(tint.opacity(0.15))
            .clipShape(Capsule())
    }

    private enum ProductPurchaseState {
        case purchasable
        case current
        case lowerTier
        var isPurchasable: Bool { if case .purchasable = self { return true }; return false }
    }

    private func purchaseState(for product: Product) -> ProductPurchaseState {
        guard let productTier = SubscriptionTier.from(productID: product.id) else {
            return .purchasable
        }
        guard let active = store.activeTier else { return .purchasable }
        if productTier == active { return .current }
        if productTier.rank < active.rank { return .lowerTier }
        return .purchasable
    }

    private func iconName(for product: Product) -> String {
        if product.type == .autoRenewable {
            return product.id == ProductID.subGold ? "crown.fill" : "star.fill"
        }
        return "leaf.circle.fill"
    }

    private func subtitle(for product: Product) -> String {
        if let tier = SubscriptionTier.from(productID: product.id) {
            return L10n.Paywall.subscriptionSubtitle(tier.dailyQuota)
        }
        if let amount = ProductID.creditAmount(for: product.id) {
            return L10n.Paywall.creditPackSubtitle(amount)
        }
        return product.description
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restore() }
        } label: {
            Text(L10n.Paywall.restorePurchases)
                .font(.subheadline)
                .foregroundStyle(Theme.leaf)
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 6) {
            Text(L10n.Paywall.legalDisclaimer)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 14) {
                Link(L10n.Paywall.termsEula, destination: L10n.Legal.eulaURL)
                Link(L10n.Paywall.privacyPolicy, destination: L10n.Legal.privacyURL)
            }
            .font(.caption2)
            .foregroundStyle(Theme.leaf)
        }
        .padding(.top, 8)
    }
}
