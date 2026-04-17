import SwiftData
import SwiftUI

struct HistoryDetailView: View {
    let record: DiagnoseRecord

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        DiagnosisResultView(
            response: response,
            image: image,
            onDone: { dismiss() },
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete this diagnosis?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible,
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(record)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var image: UIImage? {
        record.imageData.flatMap(UIImage.init(data:))
    }

    private var response: DiagnosisResponse {
        DiagnosisResponse(
            plantName: record.plantName,
            commonNames: record.commonNames,
            condition: record.condition,
            severity: record.severity,
            confidence: record.confidence,
            causes: record.causes,
            fixes: record.fixes,
            careTips: record.careTips,
            disclaimer: "Stored diagnosis. AI guidance, not a substitute for a professional.",
        )
    }
}
