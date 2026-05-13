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
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    habitSection
                    countdownSection
                    reminderSection
                    appearanceSection
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("设置")
            .preferredColorScheme(darkModeEnabled ? .dark : nil)
            .sheet(isPresented: $showHabitEditor) {
                HabitEditView(habit: editingHabit)
            }
            .sheet(isPresented: $showCountdownEditor) {
                CountdownEditView(event: editingCountdown)
            }
        }
    }

    private var habitSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("习惯管理")

            VStack(spacing: 0) {
                ForEach(habits) { habit in
                    Button {
                        editingHabit = habit
                        showHabitEditor = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: habit.sfSymbol)
                                .font(.system(size: 14))
                                .frame(width: 28, height: 28)
                                .background(habit.color.uiColor.opacity(0.3))
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
                    }
                    .buttonStyle(.plain)

                    if habit != habits.last {
                        Divider().padding(.leading, 54)
                    }
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
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
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
                    .fill(Color.white)
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
                    .fill(Color.white)
            )
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("外观")

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("深色模式")
                            .font(.system(size: 14, weight: .semibold))
                        Text("跟随系统或手动切换")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Toggle("", isOn: $darkModeEnabled)
                        .labelsHidden()
                        .tint(.accent)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

