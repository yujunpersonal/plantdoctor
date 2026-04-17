import Combine
import Foundation
import SwiftData
import UIKit

@MainActor
final class DiagnoseViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case analyzing
        case failed(String)
    }

    @Published var selectedImage: UIImage?
    @Published var phase: Phase = .idle
    @Published var result: DiagnosisResponse?
    @Published var resultRecord: DiagnoseRecord?
    @Published var showPaywall: Bool = false
    @Published var showHourlyCapAlert: Bool = false

    private let client: DiagnosisClient
    private let entitlement: EntitlementStore

    init(client: DiagnosisClient? = nil, entitlement: EntitlementStore) {
        self.client = client ?? DiagnosisClient.shared
        self.entitlement = entitlement
    }

    func clear() {
        selectedImage = nil
        phase = .idle
        result = nil
        resultRecord = nil
    }

    func diagnose(context: ModelContext) async {
        guard let image = selectedImage else { return }

        let pre = entitlement.preflight()
        switch pre {
        case .hourlyCapHit:
            showHourlyCapAlert = true
            return
        case .needsPaywall:
            showPaywall = true
            return
        case .okUsingSubscription, .okUsingCredits:
            break
        }

        phase = .analyzing
        do {
            let response = try await client.diagnose(image: image)
            entitlement.commit(using: pre)

            let imageData = ImageResizer.resize(image)
            let record = DiagnoseRecord(response: response, imageData: imageData)
            context.insert(record)
            try? context.save()

            self.result = response
            self.resultRecord = record
            self.phase = .idle
        } catch let error as APIError {
            phase = .failed(error.localizedDescription)
        } catch {
            phase = .failed("Something went wrong. Please try again.")
        }
    }
}
