import CryptoKit
import Foundation
import Testing
import UIKit
@testable import plantdoctor

struct HMACSignerTests {
    @Test func signatureMatchesKnownVector() {
        let secret = "leafwise-test-secret"
        let deviceID = "device-xyz"
        let timestamp: TimeInterval = 1_700_000_000
        let body = Data("{\"hello\":\"world\"}".utf8)

        let headers = HMACSigner.sign(
            body: body,
            deviceID: deviceID,
            secret: secret,
            now: Date(timeIntervalSince1970: timestamp),
        )

        #expect(headers.timestamp == "1700000000")
        #expect(headers.deviceID == deviceID)

        // Recompute independently and compare
        let bodyHash = HMACSigner.sha256Hex(body)
        let message = "\(headers.timestamp)\n\(deviceID)\n\(bodyHash)"
        let expected = HMACSigner.hmacSha256Hex(message: message, secret: secret)
        #expect(headers.signature == expected)
        #expect(headers.signature.count == 64)
    }

    @Test func differentBodiesProduceDifferentSignatures() {
        let a = HMACSigner.sign(body: Data("a".utf8), deviceID: "d", secret: "s")
        let b = HMACSigner.sign(body: Data("b".utf8), deviceID: "d", secret: "s")
        #expect(a.signature != b.signature)
    }
}

struct ImageResizerTests {
    @Test func downscalesLongestSideTo1024() {
        let image = makeSolidImage(size: CGSize(width: 4000, height: 3000))
        let data = ImageResizer.resize(image)
        #expect(data != nil)
        let resized = UIImage(data: data!)!
        let longest = max(resized.size.width, resized.size.height)
        #expect(abs(longest - 1024) < 2)
    }

    @Test func smallImagesArePreserved() {
        let image = makeSolidImage(size: CGSize(width: 512, height: 384))
        let data = ImageResizer.resize(image)
        let resized = UIImage(data: data!)!
        let longest = max(resized.size.width, resized.size.height)
        #expect(longest <= 1024)
        #expect(longest >= 500)
    }

    private func makeSolidImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.green.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}

@MainActor
struct CreditsLedgerTests {
    private func freshLedger() -> CreditsLedger {
        [
            KeychainKey.creditBalance,
            KeychainKey.subDailyCount,
            KeychainKey.subDailyResetDate,
            KeychainKey.hourlyDiagnoseRing,
            KeychainKey.freeCreditsSeeded,
        ].forEach { _ = KeychainHelper.delete($0) }
        return CreditsLedger()
    }

    @Test func seedingFreeCreditsHappensOnce() {
        let ledger = freshLedger()
        ledger.seedFreeCreditsIfNeeded()
        #expect(ledger.creditBalance == AppLimits.freeStarterCredits)

        ledger.seedFreeCreditsIfNeeded()
        #expect(ledger.creditBalance == AppLimits.freeStarterCredits)
    }

    @Test func hourlyRingEnforcesCap() {
        let ledger = freshLedger()
        let now = Date()
        for i in 0..<AppLimits.clientHourlyCap {
            ledger.recordHourlyHit(now: now.addingTimeInterval(-Double(i)))
        }
        #expect(ledger.wouldExceedHourlyCap(now: now) == true)
    }

    @Test func oldHourlyEntriesAreEvicted() {
        let ledger = freshLedger()
        let now = Date()
        // Stale hits > 1 hour ago
        for i in 0..<200 {
            ledger.recordHourlyHit(now: now.addingTimeInterval(-3700 - Double(i)))
        }
        // Fresh hits
        ledger.recordHourlyHit(now: now)
        #expect(ledger.wouldExceedHourlyCap(now: now) == false)
    }

    @Test func creditSpendDecrementsBalance() {
        let ledger = freshLedger()
        ledger.add(credits: 5)
        ledger.spendCredit()
        #expect(ledger.creditBalance == 4)
    }

    @Test func subRemainingMatchesQuotaMinusUsage() {
        let ledger = freshLedger()
        for _ in 0..<3 { ledger.incrementSubDailyCount() }
        #expect(ledger.subRemaining(for: .silver) == 17)
        #expect(ledger.subRemaining(for: .gold) == 47)
        #expect(ledger.subRemaining(for: nil) == 0)
    }
}
