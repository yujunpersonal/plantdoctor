import Foundation

enum APIError: Error, LocalizedError {
    case offline
    case encodingFailed
    case authFailed
    case rateLimited(scope: String?, retryAfter: Int?)
    case payloadTooLarge
    case server
    case decoding

    var errorDescription: String? {
        switch self {
        case .offline: return L10n.Errors.offline
        case .encodingFailed: return L10n.Errors.encodingFailed
        case .authFailed: return L10n.Errors.authFailed
        case .rateLimited(let scope, _):
            return scope == "device" ? L10n.Errors.rateLimitedDevice : L10n.Errors.rateLimitedGlobal
        case .payloadTooLarge: return L10n.Errors.payloadTooLarge
        case .server: return L10n.Errors.server
        case .decoding: return L10n.Errors.decoding
        }
    }
}
