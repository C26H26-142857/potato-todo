import SwiftUI
import SwiftData

struct TaskGridView: View {
    @Query(filter: #Predicate<Habit> { !$0.isHidden }, sort: \Habit.sortOrder) private var habits: [Habit]
    let selectedDate: Date
    @State private var timerManager = TimerManager.shared

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(habits) { habit in
                TaskButton(habit: habit, selectedDate: selectedDate)
            }
        }
    }
}

struct TaskButton: View {
    let habit: Habit
    let selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @State private var timerManager = TimerManager.shared

    var body: some View {
        let isDone = habit.isCompleted(for: selectedDate)
        let currentCount = habit.checkInCount(for: selectedDate)
        let duration = habit.todayTotalDuration()
        let isThisTimerRunning = timerManager.activeHabitID == habit.id && timerManager.isRunning

        Button(action: {
            if isThisTimerRunning {
                timerManager.stop(in: modelContext)
            } else if habit.enableTimer && !isDone {
                timerManager.start(habit: habit, in: modelContext)
            } else {
                habit.toggleCheckIn(for: selectedDate, in: modelContext)
                AppConfig.reloadWidgets()
            }
        }) {
            VStack(spacing: 4) {
                if isDone {
                    Text("✓")
                        .font(.system(size: 20, weight: .bold))
                } else if isThisTimerRunning {
                    Text(timerManager.elapsedString)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                } else if habit.enableTimer {
                    Image(systemName: "timer")
                        .font(.system(size: 18))
                } else if habit.type == .count {
                    Text("\(currentCount)/\(habit.dailyTarget)")
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text("○")
                        .font(.system(size: 18))
                }

                Text(habit.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                if duration > 0 && !isThisTimerRunning {
                    Text(formatDuration(duration))
                        .font(.system(size: 10))
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(isDone ? .black : (isThisTimerRunning ? .black : .taskIncompleteText))
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDone ? Color.brand :
                      (isThisTimerRunning ? Color(hex: "#FFE066") : .taskIncomplete))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(isThisTimerRunning ? Color.brand : .clear, lineWidth: 3)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDone)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return "\(h)h\(m)m"
        } else if m > 0 {
            return String(format: "%d:%02d", m, s)
        } else {
            return "\(s)s"
        }
    }
}
