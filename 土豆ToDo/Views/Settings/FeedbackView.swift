import SwiftUI
import MessageUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var message: String = ""
    @State private var showMail = false
    @State private var showMailError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("告诉我们你的想法")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: $message)
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button(action: sendFeedback) {
                    Text("发送反馈")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(message.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.gray.opacity(0.3) : Color.brand)
                        .foregroundColor(message.trimmingCharacters(in: .whitespaces).isEmpty
                                         ? .gray : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(message.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(16)
            .navigationTitle("建议与反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showMail) {
            MailView(message: message) { dismiss() }
        }
        .alert("无法发送邮件", isPresented: $showMailError) {
            Button("好", role: .cancel) {}
        } message: {
            Text("请确认设备已配置邮箱账户。\n你也可以直接发送邮件到 3934052368@qq.com")
        }
    }

    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showMail = true
        } else {
            showMailError = true
        }
    }
}

// MARK: - Mail Composer

struct MailView: UIViewControllerRepresentable {
    let message: String
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["3934052368@qq.com"])
        vc.setSubject("土豆ToDo 反馈")
        vc.setMessageBody(message, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void
        init(onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            onDismiss()
        }
    }
}
