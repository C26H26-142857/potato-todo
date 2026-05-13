import SwiftUI
import SwiftData

struct CountdownEditView: View {
    let event: CountdownEvent?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var targetDate: Date = Date()
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("事件名称") {
                    TextField("输入事件名称", text: $name)
                }

                Section("目标日期") {
                    DatePicker("选择日期", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
            }
            .navigationTitle(event == nil ? "新建倒计时" : "编辑倒计时")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("删除", role: .destructive) {
                    if let event = event {
                        modelContext.delete(event)
                        try? modelContext.save()
                        AppConfig.reloadWidgets()
                    }
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("删除后将移除「\(event?.name ?? "")」的倒计时。")
            }
            .onAppear { loadExisting() }

            if event != nil {
                Button("删除倒计时", role: .destructive) {
                    showDeleteAlert = true
                }
                .padding(.horizontal)
            }
        }
    }

    private func loadExisting() {
        guard let event = event else { return }
        name = event.name
        targetDate = event.targetDate
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let event = event {
            event.name = trimmedName
            event.targetDate = targetDate
        } else {
            let newEvent = CountdownEvent(name: trimmedName, targetDate: targetDate)
            modelContext.insert(newEvent)
        }
        try? modelContext.save()
        AppConfig.reloadWidgets()
        dismiss()
    }
}
