import CryptoKit
import Foundation

enum HMACSigner {
    struct SignedHeaders {
        let timestamp: String
        let deviceID: String
        let signature: String
    }

    static func sign(body: Data, deviceID: String, secret: String, now: Date = .init()) -> SignedHeaders {
        let timestamp = String(Int(now.timeIntervalSince1970))
        let bodyHash = sha256Hex(body)
        let message = "\(timestamp)\n\(deviceID)\n\(bodyHash)"
        let signature = hmacSha256Hex(message: message, secret: secret)
        return SignedHeaders(timestamp: timestamp, deviceID: deviceID, signature: signature)
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).hexString
    }

    static func hmacSha256Hex(message: String, secret: String) -> String {
        let key = SymmetricKey(data: Data(secret.utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        return Data(mac).hexString
    }
}

private extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

private extension SHA256.Digest {
    var hexString: String {
        Data(self).hexString
    }
}
