import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let store = StoreManager.shared

    private var monthlyButtonText: String {
        if store.isPurchasing { return "处理中..." }
        if store.monthlyHasTrial { return "免费试用 14 天" }
        return (store.monthlyProduct?.displayPrice ?? "¥3.00") + "/月"
    }

    private var monthlySubtitle: String {
        if store.monthlyHasTrial {
            return "14天后 " + (store.monthlyProduct?.displayPrice ?? "¥3.00") + "/月自动续费"
        }
        return (store.monthlyProduct?.displayPrice ?? "¥3.00") + "/月自动续费"
    }

    var body: some View {
        ScrollView {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(.brand)

            Text("土豆ToDo Pro")
                .font(.system(size: 28, weight: .bold))

            Text(store.paywallReason.rawValue)
                .font(.system(size: 15))
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 14) {
                FeatureRow(icon: "infinity", text: "无限习惯打卡")
                FeatureRow(icon: "timer", text: "无限土豆钟计时")
                FeatureRow(icon: "gift", text: "14 天免费试用")
            }
            .padding(.horizontal, 32)

            // Monthly option
            VStack(spacing: 6) {
                Button(action: { Task { await store.purchaseMonthly() } }) {
                    Text(monthlyButtonText)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brand)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(store.isPurchasing)

                Text(monthlySubtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 32)

            // Lifetime option
            VStack(spacing: 6) {
                Button(action: { Task { await store.purchaseLifetime() } }) {
                    Text(store.isPurchasing ? "处理中..." : (store.lifetimeProduct?.displayPrice ?? "¥30") + " 终身会员")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brand)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(store.isPurchasing)

                Text("一次购买，永久使用")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 32)

            // Restore
            Button("恢复购买") {
                Task { await store.restore() }
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)

            // Error
            if let error = store.purchaseError {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.horizontal, 32)
            }

            // Skip
            Button("继续免费使用") { dismiss() }
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 8)

            // Terms & Privacy
            VStack(spacing: 4) {
                Link("隐私政策", destination: URL(string: "https://c26h26-142857.github.io/potato-todo/privacy-policy")!)
                    .font(.system(size: 11))
                Link("服务条款", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.system(size: 11))
                Text("确认购买即同意以上条款。订阅自动续费，可随时取消。")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.brand)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
            Spacer()
        }
    }
}
