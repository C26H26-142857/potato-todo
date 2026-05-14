import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isHidden }, sort: \Habit.sortOrder) private var habits: [Habit]
    @State private var selectedScope: Scope = .week

    enum Scope: String, CaseIterable {
        case week = "周"
        case month = "月"
    }

    private let calendar = Calendar.current

    private var scopeDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        let count = selectedScope == .week ? 7 : 30
        return (0..<count).compactMap {
            calendar.date(byAdding: .day, value: -(count - 1 - $0), to: today)
        }
    }

    private var dailyCounts: [Int] {
        scopeDates.map { dailyCheckInCount(for: $0) }
    }

    private var completionRateLabel: String {
        let rate = completionRate
        if rate <= 0 { return "暂无数据" }
        if rate >= 1 { return "已完成" }
        return "完成率"
    }

    var body: some View {
        let counts = dailyCounts

        ScrollView {
            VStack(spacing: 14) {
                scopePicker

                CompletionRateCard(
                    rate: completionRate,
                    label: completionRateLabel
                )

                BarChartView(
                    dates: scopeDates,
                    values: counts,
                    maxTarget: habits.reduce(0) { $0 + $1.dailyTarget }
                )

                HStack(spacing: 10) {
                    StreakCard(title: "当前连续", days: habits.currentStreak())
                    StreakCard(title: "历史最长", days: habits.longestStreak())
                }
            }
            .padding(16)
        }
        .background(Color.appBackground)
    }

    private var scopePicker: some View {
        HStack(spacing: 0) {
            ForEach(Scope.allCases, id: \.self) { scope in
                let isSelected = selectedScope == scope
                Button(scope.rawValue) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedScope = scope
                    }
                }
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.cardBackground : .clear)
                )
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.scopePickerBg))
    }

    private var completionRate: Double {
        let totalTarget = habits.reduce(0) { $0 + $1.dailyTarget }
        guard totalTarget > 0 else { return 0 }

        let today = calendar.startOfDay(for: Date())
        var totalDone = 0
        var totalGoal = 0
        for date in scopeDates {
            guard date <= today else { continue }
            totalGoal += totalTarget
            totalDone += habits.reduce(0) { $0 + $1.checkInCount(for: date) }
        }
        return totalGoal > 0 ? Double(totalDone) / Double(totalGoal) : 0
    }

    private func dailyCheckInCount(for date: Date) -> Int {
        habits.reduce(0) { $0 + $1.checkInCount(for: date) }
    }
}

// MARK: - Sub-views

struct CompletionRateCard: View {
    let rate: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Text(String(format: "%.0f%%", rate * 100))
                .font(.system(size: 32, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardBackground)
        )
    }
}

struct BarChartView: View {
    let dates: [Date]
    let values: [Int]
    let maxTarget: Int

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "EEE"
        return f
    }()

    var body: some View {
        let maxVal = max(values.max() ?? 1, maxTarget, 1)

        VStack(alignment: .leading, spacing: 12) {
            Text("每日打卡数")
                .font(.system(size: 13))
                .foregroundColor(.gray)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                    VStack(spacing: 4) {
                        let height = maxVal > 0
                            ? CGFloat(values[index]) / CGFloat(maxVal) * 80
                            : 0

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(values[index] > 0 ? .accent : .statBarEmpty)
                            .frame(height: max(height, values[index] > 0 ? 4 : 2))

                        Text(String(Self.weekdayFormatter.string(from: date).prefix(1)))
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardBackground)
        )
    }
}
