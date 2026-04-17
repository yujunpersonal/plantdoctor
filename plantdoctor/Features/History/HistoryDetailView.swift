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
        .alert(L10n.History.deleteConfirmTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.History.delete, role: .destructive) {
                modelContext.delete(record)
                try? modelContext.save()
                dismiss()
            }
            Button(L10n.History.cancel, role: .cancel) {}
        } message: {
            Text(L10n.History.deleteConfirmMessage)
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
            disclaimer: L10n.Result.storedDisclaimer,
        )
    }
}
