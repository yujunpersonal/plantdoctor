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
            .navigationTitle("History")
            .background(Theme.cream.ignoresSafeArea())
        }
    }

    private var list: some View {
        List {
            ForEach(records) { record in
                NavigationLink(value: record) {
                    HistoryRow(record: record)
                }
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteRecords)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: DiagnoseRecord.self) { record in
            HistoryDetailView(record: record)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(Theme.leaf)
            Text("No diagnoses yet")
                .font(.headline)
            Text("Your past plant diagnoses will appear here and sync via iCloud.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteRecords(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
        try? modelContext.save()
    }
}

private struct HistoryRow: View {
    let record: DiagnoseRecord

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 3) {
                Text(record.plantName.isEmpty ? "Unknown plant" : record.plantName)
                    .font(.body.bold())
                    .lineLimit(1)
                Text(record.condition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(record.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = record.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.leafLight)
                .frame(width: 56, height: 56)
                .overlay(Image(systemName: "leaf.fill").foregroundStyle(Theme.leaf))
        }
    }
}
