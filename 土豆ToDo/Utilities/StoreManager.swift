import StoreKit
import SwiftUI

@Observable
final class StoreManager {
    static let shared = StoreManager()

    let monthlyID = "com.potato.todo.pro"
    let lifetimeID = "com.potato.todo.pro.lifetime"
    var monthlyProduct: Product?
    var lifetimeProduct: Product?
    var isSubscribed = false
    var trialStartDate: Date?
    var showPaywall = false
    var paywallReason: PaywallReason = .habitsLimit
    var isPurchasing = false
    var purchaseError: String?

    enum PaywallReason: String {
        case habitsLimit = "免费版最多 10 个习惯"
        case timerLimit = "免费版最多 3 个土豆钟"
    }

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await observeTransactions() }
        Task { await loadProduct() }
        Task { await checkSubscription() }
        loadTrialDate()
    }

    deinit { updatesTask?.cancel() }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [monthlyID, lifetimeID])
            monthlyProduct = products.first { $0.id == monthlyID }
            lifetimeProduct = products.first { $0.id == lifetimeID }
        } catch {
            print("StoreKit: product load failed: \(error)")
        }
    }

    func purchaseMonthly() async { await purchase(monthlyProduct) }
    func purchaseLifetime() async { await purchase(lifetimeProduct) }

    private func purchase(_ product: Product?) async {
        guard let product = product else {
            purchaseError = "无法连接商店"
            return
        }
        isPurchasing = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let txn):
                    await txn.finish()
                    isSubscribed = true
                    if product.id == monthlyID {
                        trialStartDate = Date()
                        saveTrialDate()
                    }
                    showPaywall = false
                case .unverified:
                    purchaseError = "购买验证失败，请重试"
                }
            case .userCancelled: break
            case .pending: purchaseError = "购买处理中"
            @unknown default: break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    func restore() async {
        isPurchasing = true
        purchaseError = nil
        do {
            try await AppStore.sync()
            await checkSubscription()
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    func checkSubscription() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let txn) = result else { continue }
            // Lifetime: always active
            if txn.productID == lifetimeID {
                active = true
                break
            }
            // Monthly: check expiration
            if txn.productID == monthlyID,
               let exp = txn.expirationDate,
               exp > Date() {
                active = true
                if trialStartDate == nil {
                    trialStartDate = txn.purchaseDate
                    saveTrialDate()
                }
            }
        }
        isSubscribed = active
    }

    private func observeTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let txn) = result else { continue }
            if txn.productID == monthlyID || txn.productID == lifetimeID {
                await checkSubscription()
            }
            await txn.finish()
        }
    }

    // MARK: - Trial
    var trialDaysRemaining: Int {
        guard let start = trialStartDate else { return 14 }
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, 14 - elapsed)
    }

    var trialIsActive: Bool { !isSubscribed && trialDaysRemaining > 0 }
    var trialEndingSoon: Bool { trialIsActive && trialDaysRemaining == 1 }

    private func loadTrialDate() {
        trialStartDate = UserDefaults.standard.object(forKey: "trialStartDate") as? Date
    }

    private func saveTrialDate() {
        UserDefaults.standard.set(trialStartDate, forKey: "trialStartDate")
    }
}
