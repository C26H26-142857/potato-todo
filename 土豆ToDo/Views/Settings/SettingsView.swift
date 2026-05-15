import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @Query(sort: \CountdownEvent.targetDate) private var countdowns: [CountdownEvent]
    @Environment(\.modelContext) private var modelContext

    @State private var showHabitEditor = false
    @State private var showCountdownEditor = false
    @State private var editingHabit: Habit?
    @State private var editingCountdown: CountdownEvent?
    @AppStorage("reminderTime") private var reminderHour: Int = 8
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    let store = StoreManager.shared
    @State private var showPaywall = false
    @State private var showFeedback = false
    @State private var showPrivacy = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    subscriptionSection
                    habitSection
                    countdownSection
                    reminderSection
                    feedbackSection

                    #if DEBUG
                    debugSection
                    #endif
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("设置")
            .sheet(isPresented: $showPaywall) { PaywallView().presentationDetents([.medium]).presentationBackground(Color.appBackground) }
            .sheet(isPresented: $showFeedback) { FeedbackView() }
            .sheet(isPresented: $showPrivacy) { PrivacyView() }
            #if DEBUG
            .fullScreenCover(isPresented: $showExpiryTest) {
                ExpirySelectionView { showExpiryTest = false }
            }
            #endif
            .sheet(isPresented: $showHabitEditor) {
                HabitEditView(habit: editingHabit)
            }
            .sheet(isPresented: $showCountdownEditor) {
                CountdownEditView(event: editingCountdown)
            }
        }
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("土豆ToDo Pro")

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.brand)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.isSubscribed ? "Pro 会员" : "免费版")
                            .font(.system(size: 14, weight: .semibold))
                        Text(store.isSubscribed ? "无限习惯 · 无限土豆钟" : "最多 10 个习惯 · 3 个土豆钟")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if store.isSubscribed {
                        Text("已订阅")
                            .font(.system(size: 12))
                            .foregroundColor(.brand)
                    } else {
                        Button("升级") {
                            store.paywallReason = .habitsLimit
                            showPaywall = true
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.brand)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cardBackground)
            )
        }
    }

    private var habitSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("习惯管理")

            VStack(spacing: 8) {
                ForEach(habits) { habit in
                    Button {
                        editingHabit = habit
                        showHabitEditor = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: habit.sfSymbol)
                                .font(.system(size: 14))
                                .frame(width: 28, height: 28)
                                .background(habit.color.uiColor.opacity(0.15))
                                .clipShape(Circle())

                            Text(habit.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(habit.type == .count ? "每天 \(habit.dailyTarget) 次" : "每天 1 次")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.textMuted)
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cardBackground)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    editingHabit = nil
                    showHabitEditor = true
                } label: {
                    Text("+ 添加新习惯")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cardBackground)
                        )
                }
            }
        }
    }

    private var countdownSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("倒计时")

            VStack(spacing: 0) {
                ForEach(countdowns) { event in
                    Button {
                        editingCountdown = event
                        showCountdownEditor = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(formattedDate(event.targetDate))
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.textMuted)
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)

                    if event != countdowns.last {
                        Divider().padding(.leading, 16)
                    }
                }

                Button {
                    editingCountdown = nil
                    showCountdownEditor = true
                } label: {
                    Text("+ 添加倒计时")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cardBackground)
            )
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("提醒")

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("每日提醒")
                            .font(.system(size: 14, weight: .semibold))
                        Text("每天定时推送打卡通知")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    if reminderEnabled {
                        HStack(spacing: 4) {
                            Picker("时", selection: $reminderHour) {
                                ForEach(0..<24, id: \.self) { h in
                                    Text(String(format: "%02d", h)).tag(h)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 50, height: 60)

                            Text(":")
                                .font(.system(size: 14))

                            Picker("分", selection: $reminderMinute) {
                                ForEach(0..<60, id: \.self) { m in
                                    Text(String(format: "%02d", m)).tag(m)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 50, height: 60)
                        }
                    }

                    Toggle("", isOn: $reminderEnabled)
                        .labelsHidden()
                        .tint(.accent)
                        .onChange(of: reminderEnabled) { _, newValue in
                            if newValue {
                                NotificationManager.requestPermission()
                                NotificationManager.scheduleReminder(hour: reminderHour, minute: reminderMinute)
                            } else {
                                NotificationManager.removeAllReminders()
                            }
                        }
                        .onChange(of: reminderHour) { _, newHour in
                            if reminderEnabled {
                                NotificationManager.scheduleReminder(hour: newHour, minute: reminderMinute)
                            }
                        }
                        .onChange(of: reminderMinute) { _, newMinute in
                            if reminderEnabled {
                                NotificationManager.scheduleReminder(hour: reminderHour, minute: newMinute)
                            }
                        }
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cardBackground)
            )
        }
    }

    #if DEBUG
    @State private var showExpiryTest = false

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("调试")

            VStack(spacing: 0) {
                Button(action: seedExtraHabits) {
                    HStack {
                        Text("快速添加 6 个习惯")
                        Spacer()
                        Text("")
                            .font(.system(size: 12)).foregroundColor(.gray)
                    }
                    .padding(.vertical, 13).padding(.horizontal, 16)
                }

                Divider()

                Button(action: simulateExpiry) {
                    HStack {
                        Text("模拟订阅到期")
                        Spacer()
                        Text(StoreManager.shared.isSubscribed ? "已订阅" : "免费版")
                            .font(.system(size: 12)).foregroundColor(.gray)
                    }
                    .padding(.vertical, 13).padding(.horizontal, 16)
                }
            }
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.cardBackground))
        }
    }

    private func seedExtraHabits() {
        let all = (try? modelContext.fetch(FetchDescriptor<Habit>())) ?? []
        let symbols = ["paintpalette.fill", "bicycle", "cup.and.saucer.fill",
                       "moon.stars.fill", "music.note", "leaf.fill"]
        let timerFlags = [true, false, true, true, false, true]
        for (i, symbol) in symbols.enumerated() {
            let h = Habit(name: "测试习惯\(i+1)", sfSymbol: symbol, type: .single,
                          enableTimer: timerFlags[i], sortOrder: all.count + i)
            modelContext.insert(h)
        }
        try? modelContext.save()
        AppConfig.reloadWidgets()
    }

    private func simulateExpiry() {
        StoreManager.shared.isSubscribed = false
        showExpiryTest = true
    }
    #endif

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("建议与反馈")

            VStack(spacing: 0) {
                Button {
                    showFeedback = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("发送反馈")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("告诉我们你的想法和建议")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textMuted)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 16)
                }

                Divider().padding(.leading, 16)

                Button(action: { showPrivacy = true }) {
                    HStack {
                        Text("隐私政策")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textMuted)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 16)
                }

                Divider().padding(.leading, 16)

                HStack {
                    Text("版本")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cardBackground)
            )
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .padding(.leading, 4)
            .padding(.bottom, 6)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func formattedDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }
}

