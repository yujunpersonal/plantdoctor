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

    static let maxAdditionalImages = 2

    @Published var selectedImage: UIImage?
    @Published var phase: Phase = .idle
    @Published var result: DiagnosisResponse?
    @Published var resultRecord: DiagnoseRecord?
    @Published var showPaywall: Bool = false
    @Published var showHourlyCapAlert: Bool = false

    @Published var additionalImages: [UIImage] = []
    @Published var isRediagnosing: Bool = false
    @Published var rediagnoseError: String?

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
        additionalImages = []
        isRediagnosing = false
        rediagnoseError = nil
    }

    func appendAdditionalImage(_ image: UIImage) {
        guard additionalImages.count < Self.maxAdditionalImages else { return }
        additionalImages.append(image)
    }

    func removeAdditionalImage(at index: Int) {
        guard additionalImages.indices.contains(index) else { return }
        additionalImages.remove(at: index)
    }

    func diagnose(context: ModelContext, language: AppLanguage) async {
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
            let response = try await client.diagnose(image: image, language: language.rawValue)
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
            phase = .failed(L10n.Errors.generic)
        }
    }

    func rediagnose(context: ModelContext, language: AppLanguage) async {
        guard let primary = selectedImage,
              !additionalImages.isEmpty,
              !isRediagnosing
        else { return }

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

        rediagnoseError = nil
        isRediagnosing = true
        defer { isRediagnosing = false }

        let allImages = [primary] + additionalImages
        do {
            let response = try await client.diagnose(images: allImages, language: language.rawValue)
            entitlement.commit(using: pre)

            if let record = resultRecord {
                record.plantName = response.plantName
                record.scientificName = response.scientificName
                record.commonNames = response.commonNames
                record.plantDescription = response.description
                record.condition = response.condition
                record.severity = response.severity
                record.confidence = response.confidence
                record.causes = response.causes
                record.fixes = response.fixes
                record.careTips = response.careTips
                record.light = response.light
                record.water = response.water
                record.soil = response.soil
                record.temperature = response.temperature
                record.toxicity = response.toxicity
                if let raw = try? JSONEncoder().encode(response),
                   let str = String(data: raw, encoding: .utf8) {
                    record.rawJSON = str
                }
                try? context.save()
            }

            self.additionalImages = []
            self.result = response
        } catch let error as APIError {
            rediagnoseError = error.localizedDescription
        } catch {
            rediagnoseError = L10n.Errors.generic
        }
    }
}
