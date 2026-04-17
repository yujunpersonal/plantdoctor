import SwiftUI

struct DiagnosisResultView: View {
    let response: DiagnosisResponse
    let image: UIImage?
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                headerBlock

                DetailSection(title: L10n.Result.sectionCauses, items: response.causes, systemImage: "magnifyingglass")
                DetailSection(title: L10n.Result.sectionFixes, items: response.fixes, systemImage: "wrench.and.screwdriver.fill")
                DetailSection(title: L10n.Result.sectionCareTips, items: response.careTips, systemImage: "leaf.fill")

                Text(response.disclaimer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Button(L10n.Result.done, action: onDone)
                    .buttonStyle(LeafButtonStyle())
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Theme.cream.ignoresSafeArea())
        .navigationTitle(L10n.Result.navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(response.plantName)
                .font(.title.bold())
            if !response.commonNames.isEmpty {
                Text(response.commonNames.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                severityPill
                confidencePill
            }
            Text(response.condition)
                .font(.headline)
                .padding(.top, 4)
        }
    }

    private var severityPill: some View {
        let tint: Color = {
            switch Severity(rawValue: response.severity) ?? .mild {
            case .healthy: return .green
            case .mild: return .yellow
            case .moderate: return .orange
            case .severe: return .red
            }
        }()
        return Text(L10n.Severity.label(response.severity))
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.2))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }

    private var confidencePill: some View {
        Text(L10n.Result.confidence(Int(response.confidence * 100)))
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.leafLight.opacity(0.5))
            .clipShape(Capsule())
    }
}

private struct DetailSection: View {
    let title: String
    let items: [String]
    let systemImage: String

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(Theme.leaf)
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundStyle(Theme.leaf)
                            .padding(.top, 7)
                        Text(item)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
        }
    }
}
