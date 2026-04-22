import Foundation
import UIKit

nonisolated struct DiagnosisResponse: Codable, Equatable, Sendable {
    let plantName: String
    let scientificName: String
    let commonNames: [String]
    let description: String
    let condition: String
    let severity: String
    let confidence: Double
    let causes: [String]
    let fixes: [String]
    let careTips: [String]
    let light: String
    let water: String
    let soil: String
    let temperature: String
    let toxicity: String
    let disclaimer: String

    init(
        plantName: String,
        scientificName: String = "",
        commonNames: [String] = [],
        description: String = "",
        condition: String,
        severity: String,
        confidence: Double,
        causes: [String] = [],
        fixes: [String] = [],
        careTips: [String] = [],
        light: String = "",
        water: String = "",
        soil: String = "",
        temperature: String = "",
        toxicity: String = "",
        disclaimer: String,
    ) {
        self.plantName = plantName
        self.scientificName = scientificName
        self.commonNames = commonNames
        self.description = description
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
        self.disclaimer = disclaimer
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        plantName = try c.decode(String.self, forKey: .plantName)
        scientificName = try c.decodeIfPresent(String.self, forKey: .scientificName) ?? ""
        commonNames = try c.decodeIfPresent([String].self, forKey: .commonNames) ?? []
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        condition = try c.decode(String.self, forKey: .condition)
        severity = try c.decode(String.self, forKey: .severity)
        confidence = try c.decode(Double.self, forKey: .confidence)
        causes = try c.decodeIfPresent([String].self, forKey: .causes) ?? []
        fixes = try c.decodeIfPresent([String].self, forKey: .fixes) ?? []
        careTips = try c.decodeIfPresent([String].self, forKey: .careTips) ?? []
        light = try c.decodeIfPresent(String.self, forKey: .light) ?? ""
        water = try c.decodeIfPresent(String.self, forKey: .water) ?? ""
        soil = try c.decodeIfPresent(String.self, forKey: .soil) ?? ""
        temperature = try c.decodeIfPresent(String.self, forKey: .temperature) ?? ""
        toxicity = try c.decodeIfPresent(String.self, forKey: .toxicity) ?? ""
        disclaimer = try c.decode(String.self, forKey: .disclaimer)
    }
}

private struct DiagnoseRequestBody: Codable {
    let images: [String]
    let mime: String
    let locale: String
    let language: String
}

private struct RateLimitErrorBody: Codable {
    let error: String
    let scope: String?
    let retryAfter: Int?
}

final class DiagnosisClient {
    static let shared = DiagnosisClient()

    private let session: URLSession
    private let baseURL: URL
    private let sharedSecret: String

    init(
        session: URLSession = .shared,
        baseURL: URL = Secrets.apiBaseURL,
        sharedSecret: String = Secrets.sharedSecret,
    ) {
        self.session = session
        self.baseURL = baseURL
        self.sharedSecret = sharedSecret
    }

    func diagnose(
        image: UIImage,
        language: String,
        locale: String = Locale.current.identifier,
    ) async throws -> DiagnosisResponse {
        try await diagnose(images: [image], language: language, locale: locale)
    }

    func diagnose(
        images: [UIImage],
        language: String,
        locale: String = Locale.current.identifier,
    ) async throws -> DiagnosisResponse {
        guard !images.isEmpty else { throw APIError.encodingFailed }
        let capped = Array(images.prefix(3))
        var encoded: [String] = []
        encoded.reserveCapacity(capped.count)
        for img in capped {
            guard let jpeg = ImageResizer.resize(img) else {
                throw APIError.encodingFailed
            }
            encoded.append(jpeg.base64EncodedString())
        }

        let body = DiagnoseRequestBody(
            images: encoded,
            mime: "image/jpeg",
            locale: locale,
            language: language,
        )
        let bodyData = try JSONEncoder().encode(body)

        let url = baseURL.appendingPathComponent("diagnose")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let headers = HMACSigner.sign(body: bodyData, deviceID: DeviceID.current(), secret: sharedSecret)
        request.setValue(headers.timestamp, forHTTPHeaderField: "X-PD-Timestamp")
        request.setValue(headers.deviceID, forHTTPHeaderField: "X-PD-Device")
        request.setValue(headers.signature, forHTTPHeaderField: "X-PD-Signature")
        request.httpBody = bodyData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.offline
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.server }

        switch http.statusCode {
        case 200:
            do {
                return try JSONDecoder().decode(DiagnosisResponse.self, from: data)
            } catch {
                throw APIError.decoding
            }
        case 401:
            throw APIError.authFailed
        case 413:
            throw APIError.payloadTooLarge
        case 429:
            let info = try? JSONDecoder().decode(RateLimitErrorBody.self, from: data)
            throw APIError.rateLimited(scope: info?.scope, retryAfter: info?.retryAfter)
        default:
            throw APIError.server
        }
    }
}
