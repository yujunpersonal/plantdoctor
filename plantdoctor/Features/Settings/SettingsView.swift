import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var credits: CreditsLedger
    @EnvironmentObject private var entitlement: EntitlementStore
    @EnvironmentObject private var language: LanguageStore
    @EnvironmentObject private var cloudStatus: CloudKitStatus
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        if !cloudStatus.isAvailable && cloudStatus.state != .unknown {
                            iCloudWarningCard
                        }
                        planCard
                        statsRow
                        actionsCard
                        preferencesCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 56)
                }
                footer
                    .padding(.bottom, 8)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle(L10n.Settings.navTitle)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    // MARK: - iCloud warning

    private var iCloudWarningCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.icloud.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text(L10n.Settings.icloudWarningTitle)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            Text(L10n.Settings.icloudWarningMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text(L10n.Settings.icloudOpenSettings)
                    .font(.footnote.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.orange.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1)
        )
    }

    // MARK: - Plan card

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tierAccent.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: tierIcon)
                        .font(.title2)
                        .foregroundStyle(tierAccent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Settings.currentPlan)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(tierLabel)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                }
                Spacer()
                if store.activeTier == nil {
                    Text(L10n.Settings.freeBadge)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Theme.leafLight)
                        .foregroundStyle(Theme.leaf)
                        .clipShape(Capsule())
                }
            }

            if let tier = store.activeTier {
                dailyProgress(for: tier)
            } else {
                Text(L10n.Settings.upgradePrompt)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    private func dailyProgress(for tier: SubscriptionTier) -> some View {
        let remaining = credits.subRemaining(for: tier)
        let used = tier.dailyQuota - remaining
        let progress = tier.dailyQuota > 0 ? Double(used) / Double(tier.dailyQuota) : 0
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.Settings.todayLabel)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(L10n.Settings.remainingLeft(remaining, tier.dailyQuota))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.primary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.leafLight.opacity(0.5))
                    Capsule()
                        .fill(Theme.leaf)
                        .frame(width: max(0, geo.size.width * (1 - progress)))
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            statPill(icon: "leaf.circle.fill", label: L10n.Settings.creditsStatLabel, value: "\(credits.creditBalance)")
            statPill(icon: "bolt.circle.fill", label: L10n.Settings.todayLeftStatLabel, value: todayLeftText)
        }
    }

    private func statPill(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(Theme.leaf)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    private var todayLeftText: String {
        if let tier = store.activeTier {
            return "\(credits.subRemaining(for: tier))"
        }
        return L10n.Settings.todayLeftNone
    }

    // MARK: - Actions

    private var actionsCard: some View {
        VStack(spacing: 0) {
            Button { showPaywall = true } label: {
                actionRow(
                    icon: "sparkles",
                    title: store.activeTier == nil ? L10n.Settings.upgradeOrBuy : L10n.Settings.managePlan,
                    subtitle: L10n.Settings.manageSubtitle,
                    tint: Theme.leaf,
                    showChevron: true
                )
            }
            .buttonStyle(.plain)

            divider

            Button { Task { await store.restore() } } label: {
                actionRow(
                    icon: "arrow.clockwise",
                    title: L10n.Settings.restorePurchases,
                    subtitle: L10n.Settings.restoreSubtitle,
                    tint: Theme.soil,
                    showChevron: false
                )
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    private var preferencesCard: some View {
        NavigationLink { LanguagePickerView() } label: {
            HStack(spacing: 14) {
                iconBubble("globe", tint: Theme.leaf)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Settings.languageRowTitle)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(language.current.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    private var footer: some View {
        Text(L10n.Settings.footer(appVersion))
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.tertiary)
    }

    // MARK: - Row helpers

    private func actionRow(icon: String, title: String, subtitle: String?, tint: Color, showChevron: Bool) -> some View {
        HStack(spacing: 14) {
            iconBubble(icon, tint: tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func iconBubble(_ name: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(tint.opacity(0.15))
                .frame(width: 34, height: 34)
            Image(systemName: name)
                .font(.callout)
                .foregroundStyle(tint)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.leafLight.opacity(0.5))
            .frame(height: 1)
            .padding(.leading, 64)
    }

    // MARK: - Derived

    private var tierLabel: String {
        switch store.activeTier {
        case .some(.gold): return L10n.Tier.gold
        case .some(.silver): return L10n.Tier.silver
        case .none: return L10n.Tier.free
        }
    }

    private var tierIcon: String {
        switch store.activeTier {
        case .some(.gold): return "crown.fill"
        case .some(.silver): return "star.fill"
        case .none: return "leaf.fill"
        }
    }

    private var tierAccent: Color {
        switch store.activeTier {
        case .some(.gold): return Color(red: 0xB8 / 255, green: 0x8A / 255, blue: 0x1E / 255)
        case .some(.silver): return Color(red: 0x6E / 255, green: 0x7A / 255, blue: 0x8A / 255)
        case .none: return Theme.leaf
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
