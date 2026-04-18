import CloudKit
import Combine
import Foundation

/// Observable wrapper around `CKContainer.accountStatus()` so the UI can
/// warn users when iCloud isn't signed in and history won't sync or
/// survive a reinstall. Re-checks whenever the system posts
/// `.CKAccountChanged` (triggered when the user signs in or out of
/// iCloud while the app is running).
@MainActor
final class CloudKitStatus: ObservableObject {
    enum State: Equatable {
        case unknown                  // initial, still checking
        case available                // iCloud is good
        case noAccount                // user not signed in
        case restricted               // MDM/parental controls block it
        case temporarilyUnavailable   // transient
    }

    @Published private(set) var state: State = .unknown

    private let container: CKContainer
    private var observerTask: Task<Void, Never>?

    init(containerID: String = "iCloud.cn.buddy.plantdoctor") {
        self.container = CKContainer(identifier: containerID)
        refresh()
        observerTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .CKAccountChanged) {
                await self?.updateStatus()
            }
        }
    }

    deinit { observerTask?.cancel() }

    func refresh() {
        Task { await updateStatus() }
    }

    var isAvailable: Bool { state == .available }

    private func updateStatus() async {
        let next: State
        do {
            switch try await container.accountStatus() {
            case .available: next = .available
            case .noAccount: next = .noAccount
            case .restricted: next = .restricted
            case .temporarilyUnavailable: next = .temporarilyUnavailable
            case .couldNotDetermine: next = .unknown
            @unknown default: next = .unknown
            }
        } catch {
            next = .unknown
        }
        state = next
    }
}
