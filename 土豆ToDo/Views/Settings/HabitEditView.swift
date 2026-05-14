import SwiftUI
import SwiftData

struct HabitEditView: View {
    let habit: Habit?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let store = StoreManager.shared
    @State private var name: String = ""
    @State private var selectedSymbol: String = "star.fill"
    @State private var selectedType: HabitType = .single
    @State private var dailyTarget: Int = 1
    @State private var countInStats: Bool = true
    @State private var enableTimer: Bool = false
    @State private var showDeleteAlert = false
    @State private var showPaywall = false

    @Query(filter: #Predicate<Habit> { !$0.isHidden }, sort: \Habit.sortOrder) private var existingHabits: [Habit]

    private let commonSymbols = [
        "drop.fill", "flame.fill", "book.fill", "figure.run",
        "bed.double.fill", "pencil.line", "brain.head.profile",
        "heart.fill", "leaf.fill", "dumbbell.fill",
        "music.note", "paintpalette.fill", "cup.and.saucer.fill",
        "sun.max.fill", "moon.stars.fill", "bicycle"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("习惯名称") {
                    TextField("输入习惯名称", text: $name)
                }

                Section("图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(commonSymbols, id: \.self) { symbol in
                            Image(systemName: symbol)
                                .font(.system(size: 22))
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedSymbol == symbol ? .accent.opacity(0.3) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedSymbol == symbol ? .accent : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture { selectedSymbol = symbol }
                        }
                    }
                }

                Section("打卡类型") {
                    Picker("类型", selection: $selectedType) {
                        ForEach(HabitType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) { _, newType in
                        if newType == .count {
                            enableTimer = false
                        }
                    }

                    if selectedType == .count {
                        Stepper("每日目标: \(dailyTarget) 次", value: $dailyTarget, in: 1...99)
                    }
                }

                Section {
                    Toggle("计入历史统计", isOn: $countInStats)
                } header: {
                    Text("热力图显示")
                } footer: {
                    Text("关闭后此习惯的打卡数据不会出现在日历热力图和统计中")
                }

                Section {
                    Toggle("土豆钟", isOn: $enableTimer)
                        .onChange(of: enableTimer) { _, newValue in
                            if newValue {
                                selectedType = .single
                            }
                        }
                } header: {
                    Text("计时模式")
                } footer: {
                    Text("开启后打卡类型自动切为单次，桌面小组件可直接开始计时")
                }

                if habit != nil {
                    Section {
                        Button("删除习惯", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(habit == nil ? "新建习惯" : "编辑习惯")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
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
                    if let habit = habit {
                        modelContext.delete(habit)
                        AppConfig.reloadWidgets()
                    }
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("删除「\(habit?.name ?? "")」后将无法恢复打卡数据。")
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let habit = habit else { return }
        name = habit.name
        selectedSymbol = habit.sfSymbol
        selectedType = habit.type
        dailyTarget = habit.dailyTarget
        countInStats = habit.countInStats
        enableTimer = habit.enableTimer
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // Check limits for new habits
        if habit == nil && !store.isSubscribed {
            let habitCount = existingHabits.count
            let timerCount = existingHabits.filter { $0.enableTimer }.count

            if habitCount >= StoreManager.maxFreeHabits {
                store.paywallReason = .habitsLimit
                showPaywall = true
                return
            }
            if enableTimer && timerCount >= StoreManager.maxFreeTimers {
                store.paywallReason = .timerLimit
                showPaywall = true
                return
            }
        } else if let existing = habit, !store.isSubscribed, enableTimer, !existing.enableTimer {
            let timerCount = existingHabits.filter { $0.enableTimer }.count
            if timerCount >= StoreManager.maxFreeTimers {
                store.paywallReason = .timerLimit
                showPaywall = true
                return
            }
        }

        if let habit = habit {
            habit.name = trimmedName
            habit.sfSymbol = selectedSymbol
            habit.color = .yellow
            habit.type = selectedType
            habit.dailyTarget = selectedType == .count ? dailyTarget : 1
            habit.countInStats = countInStats
            habit.enableTimer = enableTimer
        } else {
            let newHabit = Habit(
                name: trimmedName,
                sfSymbol: selectedSymbol,
                color: .yellow,
                type: selectedType,
                dailyTarget: selectedType == .count ? dailyTarget : 1,
                countInStats: countInStats,
                enableTimer: enableTimer,
                sortOrder: existingHabits.count
            )
            modelContext.insert(newHabit)
        }
        try? modelContext.save()
        AppConfig.reloadWidgets()
        dismiss()
    }
}
