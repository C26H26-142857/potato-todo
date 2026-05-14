import Foundation
import SwiftData

enum WidgetContainer {
    private static let container: ModelContainer = {
        let schema = Schema([Habit.self, CheckIn.self, CountdownEvent.self, TimerSession.self])
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.potato.todo")!
        let storeURL = url.appendingPathComponent("default.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    static var context: ModelContext { ModelContext(container) }
}
