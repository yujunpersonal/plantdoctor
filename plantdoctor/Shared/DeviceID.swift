import Foundation
import UIKit

enum DeviceID {
    /// Stable per-app-install UUID. Cached in Keychain so it survives app
    /// reinstall (Keychain persists across uninstalls on iOS).
    static func current() -> String {
        if let cached = KeychainHelper.get(KeychainKey.deviceID) {
            return cached
        }
        let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        KeychainHelper.set(id, for: KeychainKey.deviceID)
        return id
    }
}
