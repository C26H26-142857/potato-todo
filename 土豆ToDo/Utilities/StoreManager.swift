import StoreKit
import SwiftUI

@Observable
final class StoreManager {
    static let shared = StoreManager()

    static let maxFreeHabits = 10
    static let maxFreeTimers = 3

    let monthlyID = "com.potato.todo.pro"
    let lifetimeID = "com.potato.todo.pro.lifetime"
    var monthlyProduct: Product?
    var lifetimeProduct: Product?
    var isSubscribed = false
    var showPaywall = false
    var paywallReason: PaywallReason = .habitsLimit
    var isPurchasing = false
    var purchaseError: String?

    /// Whether the monthly product has an introductory offer (trial) configured in App Store Connect.
    var monthlyHasTrial: Bool {
        monthlyProduct?.subscription?.introductoryOffer != nil
    }

    enum PaywallReason: String {
        case habitsLimit = "免费版最多 10 个习惯"
        case timerLimit = "免费版最多 3 个土豆钟"
    }

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await observeTransactions() }
        Task { await loadProduct() }
        Task { await checkSubscription() }
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
            if txn.productID == lifetimeID {
                active = true
                break
            }
            if txn.productID == monthlyID,
               let exp = txn.expirationDate,
               exp > Date() {
                active = true
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
}
