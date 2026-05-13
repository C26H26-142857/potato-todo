import Foundation
import SwiftData

@Model
final class CountdownEvent {
    var id: UUID
    var name: String
    var targetDate: Date

    init(name: String, targetDate: Date) {
        self.id = UUID()
        self.name = name
        self.targetDate = Calendar.current.startOfDay(for: targetDate)
    }

    var daysRemaining: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: targetDate)
        let components = Calendar.current.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }

    var isPast: Bool {
        daysRemaining < 0
    }

    var displayDays: Int {
        abs(daysRemaining)
    }
}
