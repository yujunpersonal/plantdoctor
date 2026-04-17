import Foundation

/// First-launch bootstrap: shared secret stash, device ID warm-up,
/// free-credit seeding (guarded by CloudKit mirror to avoid re-granting
/// on reinstall into the same iCloud account).
enum AppBootstrap {
    static func run(credits: CreditsLedger) async {
        if KeychainHelper.get(KeychainKey.sharedSecret) == nil {
            KeychainHelper.set(Secrets.sharedSecret, for: KeychainKey.sharedSecret)
        }
        _ = DeviceID.current()

        if KeychainHelper.get(KeychainKey.freeCreditsSeeded) == nil {
            if let remoteBalance = await CreditsMirror.fetchRemoteBalance() {
                await MainActor.run {
                    credits.add(credits: max(0, remoteBalance - credits.creditBalance))
                }
                KeychainHelper.set("1", for: KeychainKey.freeCreditsSeeded)
            } else {
                await MainActor.run {
                    credits.seedFreeCreditsIfNeeded()
                }
            }
        }
    }
}
