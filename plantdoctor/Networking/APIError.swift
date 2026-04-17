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
        case .offline:
            return "You appear to be offline. Check your connection and try again."
        case .encodingFailed:
            return "We couldn't prepare the photo for upload. Try a different image."
        case .authFailed:
            return "Authentication failed. Please update the app."
        case .rateLimited(let scope, _):
            if scope == "device" {
                return "You've hit the per-device hourly limit. Try again in a bit."
            }
            return "Our servers are busy. Please try again in a minute."
        case .payloadTooLarge:
            return "The photo is too large. Try a smaller image."
        case .server:
            return "Diagnosis service is temporarily unavailable. Try again shortly."
        case .decoding:
            return "We got an unexpected response. Please try again."
        }
    }
}
