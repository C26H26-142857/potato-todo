import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var sfSymbol: String
    var colorRaw: String
    var typeRaw: String
    var dailyTarget: Int
    var countInStats: Bool
    var enableTimer: Bool
    var isHidden: Bool
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade) var checkIns: [CheckIn] = []
    @Relationship(deleteRule: .cascade) var timerSessions: [TimerSession] = []

    var color: HabitColor {
        get { HabitColor(rawValue: colorRaw) ?? .yellow }
        set { colorRaw = newValue.rawValue }
    }

    var type: HabitType {
        get { HabitType(rawValue: typeRaw) ?? .single }
        set { typeRaw = newValue.rawValue }
    }

    init(
        name: String,
        sfSymbol: String = "star.fill",
        color: HabitColor = .yellow,
        type: HabitType = .single,
        dailyTarget: Int = 1,
        countInStats: Bool = true,
        enableTimer: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.sfSymbol = sfSymbol
        self.colorRaw = color.rawValue
        self.typeRaw = type.rawValue
        self.dailyTarget = dailyTarget
        self.countInStats = countInStats
        self.enableTimer = enableTimer
        self.isHidden = false
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }

    func checkInCount(for date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return checkIns.lazy
            .filter { $0.date == dayStart }
            .reduce(0) { $0 + $1.count }
    }

    func isCompleted(for date: Date) -> Bool {
        checkInCount(for: date) >= dailyTarget
    }

    func todayTotalDuration() -> TimeInterval {
        let today = Calendar.current.startOfDay(for: Date())
        return timerSessions
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: today) && $0.endTime != nil }
            .reduce(0) { $0 + $1.duration }
    }

    func hasRunningTimer() -> Bool {
        timerSessions.contains { $0.isRunning }
    }

    func toggleCheckIn(for date: Date, in context: ModelContext) {
        let dayStart = Calendar.current.startOfDay(for: date)

        if type == .single {
            if let existing = checkIns.first(where: { $0.date == dayStart }) {
                context.delete(existing)
            } else {
                context.insert(CheckIn(date: dayStart, count: 1, habit: self))
            }
        } else if checkInCount(for: date) < dailyTarget {
            context.insert(CheckIn(date: dayStart, count: 1, habit: self))
        } else {
            for ci in checkIns where ci.date == dayStart {
                context.delete(ci)
            }
        }
    }
}
