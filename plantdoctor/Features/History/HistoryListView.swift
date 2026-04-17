import SwiftData
import SwiftUI

struct HistoryListView: View {
    @Query(sort: \DiagnoseRecord.createdAt, order: .reverse)
    private var records: [DiagnoseRecord]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle(L10n.History.navTitle)
            .navigationBarTitleDisplayMode(.large)
            .background(Theme.cream.ignoresSafeArea())
        }
    }

    private var list: some View {
        List {
            Section {
                ForEach(records) { record in
                    ZStack {
                        NavigationLink(value: record) { EmptyView() }.opacity(0)
                        HistoryCard(record: record)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteRecords)
            } header: {
                sectionHeader
                    .textCase(nil)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 4, trailing: 20))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: DiagnoseRecord.self) { record in
            HistoryDetailView(record: record)
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text(L10n.History.sectionHeader)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            Spacer()
            Text("\(records.count)")
                .font(.caption.bold().monospacedDigit())
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Theme.leafLight)
                .foregroundStyle(Theme.leaf)
                .clipShape(Capsule())
        }
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.leafLight.opacity(0.6))
                        .frame(width: 88, height: 88)
                    Image(systemName: "leaf.arrow.triangle.circlepath")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.leaf)
                }
                VStack(spacing: 6) {
                    Text(L10n.History.emptyTitle)
                        .font(.title3.bold())
                    Text(L10n.History.emptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func deleteRecords(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
        try? modelContext.save()
    }
}

private struct HistoryCard: View {
    let record: DiagnoseRecord

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    severityDot
                    Text(record.plantName.isEmpty ? L10n.History.unknownPlant : record.plantName)
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                Text(record.condition.isEmpty ? L10n.History.noCondition : record.condition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label(record.createdAt.formatted(.relative(presentation: .named)), systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    if record.confidence > 0 {
                        Text("\(Int(record.confidence * 100))%")
                            .font(.caption2.monospacedDigit())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Theme.leafLight.opacity(0.7))
                            .foregroundStyle(Theme.leaf)
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = record.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.leafLight, lineWidth: 0.5)
                )
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.leafLight.opacity(0.6))
                .frame(width: 68, height: 68)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.leaf)
                )
        }
    }

    private var severityDot: some View {
        Circle()
            .fill(severityColor)
            .frame(width: 8, height: 8)
    }

    private var severityColor: Color {
        switch Severity(rawValue: record.severity.lowercased()) {
        case .healthy: return Theme.leaf
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        case .none: return .gray
        }
    }
}
