import SwiftUI
import SwiftData

@main
struct PotatoTodoApp: App {
    @State private var selectedDate = Date()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedDate: $selectedDate)
                .onAppear {
                    seedIfNeeded()
                }
        }
        .modelContainer(AppConfig.sharedContainer)
    }

    private func seedIfNeeded() {
        let ctx = AppConfig.sharedContainer.mainContext
        let descriptor = FetchDescriptor<Habit>()
        guard let count = try? ctx.fetchCount(descriptor), count == 0 else { return }

        let habits: [(String, String, HabitColor, HabitType, Int)] = [
            ("喝水", "drop.fill", .yellow, .count, 8),
            ("跑步", "figure.run", .yellow, .single, 1),
            ("阅读", "book.fill", .yellow, .single, 1),
            ("冥想", "brain.head.profile", .yellow, .single, 1),
            ("英语", "textformat.abc", .yellow, .single, 1),
        ]

        let today = Calendar.current.startOfDay(for: Date())

        for (index, (name, icon, color, type, target)) in habits.enumerated() {
            let habit = Habit(name: name, sfSymbol: icon, color: color, type: type, dailyTarget: target, sortOrder: index)
            ctx.insert(habit)

            for daysAgo in stride(from: 12, through: 1, by: -1) {
                guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
                if daysAgo % 3 == 0 { continue }
                if type == .count {
                    ctx.insert(CheckIn(date: date, count: Int.random(in: 1...target), habit: habit))
                } else {
                    ctx.insert(CheckIn(date: date, count: 1, habit: habit))
                }
            }

            if index < 2 {
                if type == .count {
                    ctx.insert(CheckIn(date: today, count: min(3, target), habit: habit))
                } else {
                    ctx.insert(CheckIn(date: today, count: 1, habit: habit))
                }
            }
        }

        var dateComponents = DateComponents()
        dateComponents.year = 2026; dateComponents.month = 12; dateComponents.day = 26
        if let kaoyan = Calendar.current.date(from: dateComponents) {
            ctx.insert(CountdownEvent(name: "考研上岸", targetDate: kaoyan))
        }
        dateComponents.year = 2027; dateComponents.month = 7; dateComponents.day = 1
        if let jiari = Calendar.current.date(from: dateComponents) {
            ctx.insert(CountdownEvent(name: "暑假开始", targetDate: jiari))
        }

        try? ctx.save()
    }
}
