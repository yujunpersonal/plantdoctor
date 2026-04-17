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

                    subscriptionsSection

                    creditsSection

                    restoreButton

                    legalFooter
                }
                .padding(20)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Go Unlimited")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase", isPresented: Binding(
                get: { store.purchaseError != nil },
                set: { if !$0 { store.purchaseError = nil } }
            )) {
                Button("OK") { store.purchaseError = nil }
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
            Text("Keep Leafwise Growing")
                .font(.title2.bold())
            Text("Subscribe for daily diagnoses, or top up with credits.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("You have \(credits.creditBalance) credits")
                .font(.footnote)
                .foregroundStyle(Theme.leaf)
        }
    }

    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Subscriptions")
            ForEach(store.subscriptions) { product in
                productCard(product)
            }
        }
    }

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Credit Packs")
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
        Button {
            Task { await store.purchase(product) }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: iconName(for: product))
                    .font(.title2)
                    .foregroundStyle(Theme.leaf)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName).font(.body.bold())
                    Text(subtitle(for: product))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.body.bold())
                    .foregroundStyle(Theme.leaf)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(store.isPurchasing)
    }

    private func iconName(for product: Product) -> String {
        if product.type == .autoRenewable {
            return product.id == ProductID.subGold ? "crown.fill" : "star.fill"
        }
        return "leaf.circle.fill"
    }

    private func subtitle(for product: Product) -> String {
        if let tier = SubscriptionTier.from(productID: product.id) {
            return "\(tier.dailyQuota) diagnoses/day · monthly"
        }
        if let amount = ProductID.creditAmount(for: product.id) {
            return "\(amount) diagnose credits"
        }
        return product.description
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restore() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(Theme.leaf)
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 6) {
            Text("Subscriptions auto-renew monthly until cancelled in App Store settings. Credit packs are one-time purchases.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 14) {
                Link("Terms (EULA)", destination: LegalLinks.eula)
                Link("Privacy Policy", destination: LegalLinks.privacy)
            }
            .font(.caption2)
            .foregroundStyle(Theme.leaf)
        }
        .padding(.top, 8)
    }
}
