import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(filter: #Predicate<Habit> { !$0.isHidden }, sort: \Habit.sortOrder) private var habits: [Habit]
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
    @State private var showDetail = false

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        return f
    }()

    private var monthStart: Date {
        let comps = calendar.dateComponents([.year, .month], from: currentMonth)
        return calendar.date(from: comps) ?? currentMonth
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in 1...range.count {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart))
        }
        return days
    }

    var body: some View {
        let intensities = computeIntensities()

        ScrollView {
            VStack(spacing: 16) {
                monthHeader
                weekdayHeader
                calendarGrid(intensities: intensities)
                legendRow
                streakCards
            }
            .padding(16)
        }
        .background(Color.appBackground)
        .overlay {
            if showDetail, let date = selectedDate {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showDetail = false }

                VStack {
                    Spacer()
                    DateDetailView(date: date, habits: habits, onClose: { showDetail = false })
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showDetail)
    }

    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left").foregroundColor(.gray)
            }
            Spacer()
            Text(Self.monthFormatter.string(from: currentMonth))
                .font(.system(size: 17, weight: .bold))
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                Text(day).font(.system(size: 11)).foregroundColor(.gray).frame(maxWidth: .infinity)
            }
        }
    }

    private func calendarGrid(intensities: [Date: Double]) -> some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    let dayStart = calendar.startOfDay(for: date)
                    let intensity = intensities[dayStart] ?? 0
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(heatColor(intensity))
                        )
                        .foregroundColor(intensity > 0.3 ? .black : .primary)
                        .onTapGesture {
                            selectedDate = dayStart
                            showDetail = true
                        }
                } else {
                    Text("").frame(maxWidth: .infinity).padding(.vertical, 6)
                }
            }
        }
    }

    private var legendRow: some View {
        HStack(spacing: 6) {
            Text("少").font(.system(size: 11)).foregroundColor(.gray)
            legendDot(.heatLow)
            legendDot(.heatMid)
            legendDot(.heatHigh)
            Text("多").font(.system(size: 11)).foregroundColor(.gray)
        }
    }

    private func legendDot(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 12, height: 12)
    }

    private var streakCards: some View {
        HStack(spacing: 10) {
            StreakCard(title: "当前连续", days: habits.currentStreak())
            StreakCard(title: "历史最长", days: habits.longestStreak())
        }
    }

    private func computeIntensities() -> [Date: Double] {
        let statsHabits = habits.filter { $0.countInStats }
        let totalTargets = statsHabits.reduce(0) { $0 + $1.dailyTarget }
        guard totalTargets > 0 else { return [:] }
        var result: [Date: Double] = [:]
        for date in daysInMonth.compactMap({ $0 }) {
            let dayStart = calendar.startOfDay(for: date)
            let total = statsHabits.reduce(0) { $0 + $1.checkInCount(for: date) }
            result[dayStart] = min(Double(total) / Double(totalTargets), 1.0)
        }
        return result
    }

    private func heatColor(_ intensity: Double) -> Color {
        if intensity <= 0 { return .clear }
        if intensity < 0.3 { return .heatLow }
        if intensity < 0.7 { return .heatMid }
        return .heatHigh
    }

    private func previousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = prev
        }
    }

    private func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = next
        }
    }
}

// MARK: - Date Detail Sheet

struct DateDetailView: View {
    let date: Date
    let habits: [Habit]
    var onClose: (() -> Void)?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 EEEE"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(Self.dateFormatter.string(from: date))
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Button("关闭") { onClose?() }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()

            let completed = habits.filter { $0.checkInCount(for: date) > 0 }
            let uncompleted = habits.filter { $0.checkInCount(for: date) == 0 }

            if habits.isEmpty {
                Text("暂无习惯数据")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    if !completed.isEmpty {
                        Section("已完成") {
                            ForEach(completed) { habit in
                                HStack {
                                    Image(systemName: habit.sfSymbol)
                                        .foregroundColor(.brand)
                                    Text(habit.name)
                                    Spacer()
                                    if habit.type == .count {
                                        Text("\(habit.checkInCount(for: date))/\(habit.dailyTarget)")
                                            .foregroundColor(.brand)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.brand)
                                    }
                                }
                            }
                        }
                    }
                    if !uncompleted.isEmpty {
                        Section("未完成") {
                            ForEach(uncompleted) { habit in
                                HStack {
                                    Image(systemName: habit.sfSymbol)
                                        .foregroundColor(.gray)
                                    Text(habit.name).foregroundColor(.gray)
                                    Spacer()
                                    Text("未打卡").font(.system(size: 13)).foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

// MARK: - StreakCard

struct StreakCard: View {
    let title: String
    let days: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(days)")
                .font(.system(size: 24, weight: .bold))
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
    }
}
