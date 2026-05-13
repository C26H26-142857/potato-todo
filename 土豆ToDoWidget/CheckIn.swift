import Foundation
import SwiftData

@Model
final class CheckIn {
    var id: UUID
    var date: Date
    var count: Int
    var habit: Habit?

    init(date: Date, count: Int = 1, habit: Habit? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.count = count
        self.habit = habit
    }
}
