import Foundation

extension Array where Element == Habit {
    func currentStreak(from date: Date = Date()) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var cursor = calendar.startOfDay(for: date)
        while containsCheckIn(on: cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    func longestStreak() -> Int {
        let calendar = Calendar.current
        guard let earliest = earliestCheckInDate() else { return 0 }
        var longest = 0
        var current = 0
        var cursor = earliest
        let today = calendar.startOfDay(for: Date())
        while cursor <= today {
            if containsCheckIn(on: cursor) {
                current += 1
                longest = Swift.max(longest, current)
            } else {
                current = 0
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return longest
    }

    func containsCheckIn(on date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        return contains { habit in
            habit.checkIns.contains { $0.date == dayStart && $0.count > 0 }
        }
    }

    private func earliestCheckInDate() -> Date? {
        flatMap { $0.checkIns }.map(\.date).min()
    }
}
