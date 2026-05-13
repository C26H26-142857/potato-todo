import SwiftUI
import SwiftData

@Observable
final class TimerManager {
    static let shared = TimerManager()

    var activeHabitID: UUID?
    var sessionStart: Date?
    var elapsed: TimeInterval = 0

    private var timer: Timer?

    var isRunning: Bool { activeHabitID != nil }
    var elapsedString: String {
        let total = elapsed
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        let seconds = Int(total) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start(habit: Habit, in context: ModelContext) {
        guard !isRunning else { return }
        activeHabitID = habit.id
        sessionStart = Date()
        elapsed = 0

        let session = TimerSession(startTime: Date(), habit: habit)
        context.insert(session)
        try? context.save()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            if let start = self?.sessionStart {
                self?.elapsed = Date().timeIntervalSince(start)
            }
        }
    }

    func stop(in context: ModelContext) {
        guard let habitID = activeHabitID else { return }

        let now = Date()
        let fetch = FetchDescriptor<Habit>()
        guard let habits = try? context.fetch(fetch),
              let habit = habits.first(where: { $0.id == habitID }),
              let session = habit.timerSessions.first(where: { $0.isRunning }) else {
            reset()
            return
        }

        session.endTime = now
        session.duration = now.timeIntervalSince(session.startTime)

        // Auto check-in
        let today = Calendar.current.startOfDay(for: Date())
        if !habit.isCompleted(for: today) {
            context.insert(CheckIn(date: today, count: 1, habit: habit))
        }

        try? context.save()
        reset()
        AppConfig.reloadWidgets()
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        activeHabitID = nil
        sessionStart = nil
        elapsed = 0
    }
}
