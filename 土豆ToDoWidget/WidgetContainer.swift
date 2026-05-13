import Foundation
import SwiftData

enum WidgetContainer {
    static func makeContext() -> ModelContext {
        let schema = Schema([Habit.self, CheckIn.self, CountdownEvent.self, TimerSession.self])
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.potato.todo")!
        let storeURL = url.appendingPathComponent("default.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try! ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }
}
