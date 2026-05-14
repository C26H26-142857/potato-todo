import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("最后更新：2026年5月14日")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    Text("你的数据只属于你，永远保存在你的设备上。我们无法访问。")
                        .font(.system(size: 14))

                    Text("本应用不收集任何个人信息，包括姓名、邮箱、位置、设备标识符、使用行为数据、崩溃日志。无需注册账号。")
                        .font(.system(size: 14))

                    Text("数据存储")
                        .font(.system(size: 16, weight: .bold))
                    Text("你创建的习惯、打卡记录、计时数据全部保存在 iPhone 本地。删除 App 即永久删除所有数据。")
                        .font(.system(size: 14))

                    Text("付费")
                        .font(.system(size: 16, weight: .bold))
                    Text("订阅与购买通过 Apple StoreKit 处理。支付信息由 Apple 直接管理。")
                        .font(.system(size: 14))

                    Text("通知")
                        .font(.system(size: 16, weight: .bold))
                    Text("打卡提醒在你设备上本地触发，不经过任何服务器。")
                        .font(.system(size: 14))

                    Text("本应用不使用任何第三方服务。无广告、无追踪、无分析工具。")
                        .font(.system(size: 14))

                    Text("如有隐私相关问题：3934052368@qq.com")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(16)
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}
