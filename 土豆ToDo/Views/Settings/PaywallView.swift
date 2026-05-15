import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let store = StoreManager.shared

    private var price: String {
        store.monthlyProduct?.displayPrice ?? "¥3.00"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }

                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.brand)

                Text("土豆ToDo Pro")
                    .font(.system(size: 28, weight: .bold))

                Text(store.paywallReason.rawValue)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // Features
            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "infinity", text: "无限习惯打卡")
                FeatureRow(icon: "timer", text: "无限土豆钟计时")
            }
            .padding(.horizontal, 44)
            .padding(.bottom, 20)

            // Purchase options
            VStack(spacing: 10) {
                // Trial card — highlighted
                Button(action: { Task { await store.purchaseMonthly() } }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Text("免费试用")
                                .font(.system(size: 18, weight: .bold))
                            Text("推荐")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.brand)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        Text("14天后 " + price + "/月自动续费，可随时取消")
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background(Color.brand)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(store.isPurchasing)

                // Monthly direct
                Button(action: { Task { await store.purchaseMonthly() } }) {
                    HStack {
                        Text(price + "/月")
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Text("直接订阅")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.brand, lineWidth: 2)
                    )
                }
                .disabled(store.isPurchasing)

                // Lifetime
                Button(action: { Task { await store.purchaseLifetime() } }) {
                    HStack {
                        Text((store.lifetimeProduct?.displayPrice ?? "¥30") + " 终身会员")
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Text("一次购买 · 永久")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.brand, lineWidth: 2)
                    )
                }
                .disabled(store.isPurchasing)
            }
            .padding(.horizontal, 32)

            // Error
            if let error = store.purchaseError {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.top, 12)
                    .padding(.horizontal, 32)
            }

            if store.isPurchasing {
                ProgressView()
                    .padding(.top, 12)
            }

            // Restore
            Button("恢复购买") {
                Task { await store.restore() }
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
            .padding(.top, 16)

            Spacer()

            // Bottom
            VStack(spacing: 8) {
                Button("继续免费使用") { dismiss() }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                VStack(spacing: 4) {
                    Link("隐私政策", destination: URL(string: "https://c26h26-142857.github.io/potato-todo/privacy-policy")!)
                        .font(.system(size: 11))
                    Link("服务条款", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        .font(.system(size: 11))
                    Text("确认购买即同意以上条款")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
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
