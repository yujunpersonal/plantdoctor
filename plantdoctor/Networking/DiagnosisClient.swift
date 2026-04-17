import Foundation
import UIKit

nonisolated struct DiagnosisResponse: Codable, Equatable, Sendable {
    let plantName: String
    let commonNames: [String]
    let condition: String
    let severity: String
    let confidence: Double
    let causes: [String]
    let fixes: [String]
    let careTips: [String]
    let disclaimer: String
}

private struct DiagnoseRequestBody: Codable {
    let imageBase64: String
    let mime: String
    let locale: String
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

    func diagnose(image: UIImage, locale: String = Locale.current.identifier) async throws -> DiagnosisResponse {
        guard let jpeg = ImageResizer.resize(image) else {
            throw APIError.encodingFailed
        }

        let body = DiagnoseRequestBody(
            imageBase64: jpeg.base64EncodedString(),
            mime: "image/jpeg",
            locale: locale,
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
