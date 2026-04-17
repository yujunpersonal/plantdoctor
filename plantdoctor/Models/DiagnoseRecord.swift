import Foundation
import SwiftData

@Model
final class DiagnoseRecord {
    var id: UUID = UUID()
    var createdAt: Date = Date()

    @Attribute(.externalStorage) var imageData: Data?

    var plantName: String = ""
    var commonNames: [String] = []
    var condition: String = ""
    var severity: String = "mild"
    var confidence: Double = 0
    var causes: [String] = []
    var fixes: [String] = []
    var careTips: [String] = []
    var rawJSON: String = ""

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        imageData: Data? = nil,
        plantName: String = "",
        commonNames: [String] = [],
        condition: String = "",
        severity: String = "mild",
        confidence: Double = 0,
        causes: [String] = [],
        fixes: [String] = [],
        careTips: [String] = [],
        rawJSON: String = "",
    ) {
        self.id = id
        self.createdAt = createdAt
        self.imageData = imageData
        self.plantName = plantName
        self.commonNames = commonNames
        self.condition = condition
        self.severity = severity
        self.confidence = confidence
        self.causes = causes
        self.fixes = fixes
        self.careTips = careTips
        self.rawJSON = rawJSON
    }

    convenience init(response: DiagnosisResponse, imageData: Data?) {
        let raw = (try? JSONEncoder().encode(response)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        self.init(
            imageData: imageData,
            plantName: response.plantName,
            commonNames: response.commonNames,
            condition: response.condition,
            severity: response.severity,
            confidence: response.confidence,
            causes: response.causes,
            fixes: response.fixes,
            careTips: response.careTips,
            rawJSON: raw,
        )
    }
}

enum Severity: String {
    case healthy, mild, moderate, severe

    var color: String {
        switch self {
        case .healthy: return "leaf"
        case .mild: return "yellow"
        case .moderate: return "orange"
        case .severe: return "red"
        }
    }
}
