import Foundation
import SwiftData

@Model
final class TimerSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var habit: Habit?

    var isRunning: Bool { endTime == nil }

    init(startTime: Date = Date(), habit: Habit? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.duration = 0
        self.habit = habit
    }

    func stop() {
        endTime = Date()
        duration = endTime!.timeIntervalSince(startTime)
    }
}
