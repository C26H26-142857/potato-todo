import SwiftData
import WidgetKit

enum AppConfig {
    static let appGroupID = "group.com.potato.todo"

    static let sharedContainer: ModelContainer = {
        let schema = Schema([Habit.self, CheckIn.self, CountdownEvent.self, TimerSession.self])
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
        let storeURL = url.appendingPathComponent("default.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    static func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
