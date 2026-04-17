import CloudKit
import Foundation

/// Mirrors the local credit balance to the user's iCloud private DB so:
///  - reinstalls on the same iCloud account don't re-grant the 10 free credits;
///  - a user moving to a new device can recover purchased consumable credits
///    (App Store only restores subscriptions automatically).
///
/// We never read the mirror as the source of truth after bootstrap — Keychain
/// wins for day-to-day mutations.
enum CreditsMirror {
    private static let recordType = "CreditsMirror"
    private static let recordName = "singleton"
    private static var container: CKContainer {
        CKContainer(identifier: "iCloud.cn.buddy.plantdoctor")
    }

    static func fetchRemoteBalance() async -> Int? {
        let id = CKRecord.ID(recordName: recordName)
        do {
            let record = try await container.privateCloudDatabase.record(for: id)
            return record["balance"] as? Int
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        } catch {
            return nil
        }
    }

    static func writeBalance(_ balance: Int) async {
        let id = CKRecord.ID(recordName: recordName)
        do {
            let existing = try? await container.privateCloudDatabase.record(for: id)
            let record = existing ?? CKRecord(recordType: recordType, recordID: id)
            record["balance"] = balance as CKRecordValue
            record["updatedAt"] = Date() as CKRecordValue
            _ = try await container.privateCloudDatabase.save(record)
        } catch {
            // Best-effort mirror; swallow errors.
        }
    }
}
