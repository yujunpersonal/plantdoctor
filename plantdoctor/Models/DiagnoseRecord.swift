import Foundation
import SwiftData

@Model
final class DiagnoseRecord {
    var id: UUID = UUID()
    var createdAt: Date = Date()

    @Attribute(.externalStorage) var imageData: Data?

    var plantName: String = ""
    var scientificName: String = ""
    var commonNames: [String] = []
    var plantDescription: String = ""
    var condition: String = ""
    var severity: String = "mild"
    var confidence: Double = 0
    var causes: [String] = []
    var fixes: [String] = []
    var careTips: [String] = []
    var light: String = ""
    var water: String = ""
    var soil: String = ""
    var temperature: String = ""
    var toxicity: String = ""
    var rawJSON: String = ""

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        imageData: Data? = nil,
        plantName: String = "",
        scientificName: String = "",
        commonNames: [String] = [],
        plantDescription: String = "",
        condition: String = "",
        severity: String = "mild",
        confidence: Double = 0,
        causes: [String] = [],
        fixes: [String] = [],
        careTips: [String] = [],
        light: String = "",
        water: String = "",
        soil: String = "",
        temperature: String = "",
        toxicity: String = "",
        rawJSON: String = "",
    ) {
        self.id = id
        self.createdAt = createdAt
        self.imageData = imageData
        self.plantName = plantName
        self.scientificName = scientificName
        self.commonNames = commonNames
        self.plantDescription = plantDescription
        self.condition = condition
        self.severity = severity
        self.confidence = confidence
        self.causes = causes
        self.fixes = fixes
        self.careTips = careTips
        self.light = light
        self.water = water
        self.soil = soil
        self.temperature = temperature
        self.toxicity = toxicity
        self.rawJSON = rawJSON
    }

    convenience init(response: DiagnosisResponse, imageData: Data?) {
        let raw = (try? JSONEncoder().encode(response)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        self.init(
            imageData: imageData,
            plantName: response.plantName,
            scientificName: response.scientificName,
            commonNames: response.commonNames,
            plantDescription: response.description,
            condition: response.condition,
            severity: response.severity,
            confidence: response.confidence,
            causes: response.causes,
            fixes: response.fixes,
            careTips: response.careTips,
            light: response.light,
            water: response.water,
            soil: response.soil,
            temperature: response.temperature,
            toxicity: response.toxicity,
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
