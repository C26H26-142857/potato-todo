import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Data
struct WidgetHabitItem {
    let id: String
    let name: String
    let isCompleted: Bool
    let isTimerEnabled: Bool
    let isTimerRunning: Bool
    let isCountType: Bool
    let currentCount: Int
    let dailyTarget: Int
}

// MARK: - Intents
struct StartTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "开始计时"
    @Parameter(title: "习惯 ID") var habitID: String
    init() {}
    init(habitID: String) { self.habitID = habitID }
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: habitID) else { return .result() }; let ctx = WidgetContainer.context
        var d = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == uuid }); d.fetchLimit = 1
        guard let h = try? ctx.fetch(d).first else { return .result() }
        ctx.insert(TimerSession(startTime: Date(), habit: h))
        try ctx.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "CheckInWidget")
        return .result()
    }
}

struct StopTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "停止计时"
    @Parameter(title: "习惯 ID") var habitID: String
    init() {}
    init(habitID: String) { self.habitID = habitID }
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: habitID) else { return .result() }; let ctx = WidgetContainer.context
        var d = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == uuid }); d.fetchLimit = 1
        guard let h = try? ctx.fetch(d).first else { return .result() }
        let now = Date()
        if let s = h.timerSessions.first(where: { $0.isRunning }) { s.endTime = now; s.duration = now.timeIntervalSince(s.startTime) }
        let today = Calendar.current.startOfDay(for: now)
        if !h.isCompleted(for: today) { ctx.insert(CheckIn(date: today, count: 1, habit: h)) }
        try ctx.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "CheckInWidget")
        return .result()
    }
}

struct ToggleCheckIntent: AppIntent {
    static var title: LocalizedStringResource = "打卡"
    @Parameter(title: "习惯 ID") var habitID: String
    init() {}
    init(habitID: String) { self.habitID = habitID }
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: habitID) else { return .result() }; let ctx = WidgetContainer.context
        var d = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == uuid }); d.fetchLimit = 1
        guard let h = try? ctx.fetch(d).first else { return .result() }
        let today = Calendar.current.startOfDay(for: Date())
        if h.type == .single {
            if let ex = h.checkIns.first(where: { $0.date == today }) { ctx.delete(ex) }
            else { ctx.insert(CheckIn(date: today, count: 1, habit: h)) }
        } else if h.checkInCount(for: today) < h.dailyTarget {
            ctx.insert(CheckIn(date: today, count: 1, habit: h))
        } else {
            for ci in h.checkIns where ci.date == today { ctx.delete(ci) }
        }
        try ctx.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "CheckInWidget")
        return .result()
    }
}

// MARK: - Entry
struct CheckInEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabitItem]
}

// MARK: - Provider
struct CheckInProvider: TimelineProvider {
    func placeholder(in context: Context) -> CheckInEntry {
        CheckInEntry(date: Date(), habits: [
            WidgetHabitItem(id: "1", name: "喝水", isCompleted: true, isTimerEnabled: false, isTimerRunning: false, isCountType: true, currentCount: 8, dailyTarget: 8),
            WidgetHabitItem(id: "2", name: "跑步", isCompleted: false, isTimerEnabled: true, isTimerRunning: true, isCountType: false, currentCount: 0, dailyTarget: 1),
            WidgetHabitItem(id: "3", name: "阅读", isCompleted: false, isTimerEnabled: false, isTimerRunning: false, isCountType: false, currentCount: 0, dailyTarget: 1),
            WidgetHabitItem(id: "4", name: "冥想", isCompleted: false, isTimerEnabled: true, isTimerRunning: false, isCountType: false, currentCount: 0, dailyTarget: 1),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (CheckInEntry) -> Void) {
        let h = loadHabits()
        completion(CheckInEntry(date: Date(), habits: h))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CheckInEntry>) -> Void) {
        let h = loadHabits()
        completion(Timeline(entries: [CheckInEntry(date: Date(), habits: h)], policy: .after(Date().addingTimeInterval(15 * 60))))
    }

    private func loadHabits() -> [WidgetHabitItem] {
        let ctx = WidgetContainer.context
        var desc = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isHidden }, sortBy: [SortDescriptor(\.sortOrder)])
        guard let habits = try? ctx.fetch(desc), !habits.isEmpty else { return [] }
        let today = Calendar.current.startOfDay(for: Date())
        return habits.map { WidgetHabitItem(id: $0.id.uuidString, name: $0.name, isCompleted: $0.isCompleted(for: today), isTimerEnabled: $0.enableTimer, isTimerRunning: $0.hasRunningTimer(), isCountType: $0.type == .count, currentCount: $0.checkInCount(for: today), dailyTarget: $0.dailyTarget) }
    }
}

// MARK: - Views
struct CheckInWidgetView: View {
    var entry: CheckInEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let cfg: (Int, Int) = family == .systemSmall ? (1, 3) : family == .systemLarge ? (4, 16) : (4, 8)
        let sorted = entry.habits.sorted { !$0.isCompleted && $1.isCompleted }
        let display = Array(sorted.prefix(cfg.1))

        if display.isEmpty {
            Text("暂无习惯\n打开App添加")
                .font(.system(size: 12)).multilineTextAlignment(.center).foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: cfg.0), spacing: 10) {
                ForEach(display.indices, id: \.self) { i in CheckInCardView(habit: display[i]) }
            }
            .padding(12)
        }
    }
}

struct CheckInCardView: View {
    let habit: WidgetHabitItem

    var body: some View {
        if habit.isTimerEnabled {
            TimerCardContent(habit: habit)
        } else {
            NormalCardContent(habit: habit)
        }
    }
}

struct NormalCardContent: View {
    let habit: WidgetHabitItem

    var body: some View {
        Button(intent: ToggleCheckIntent(habitID: habit.id)) {
            VStack(spacing: 6) {
                if habit.isCompleted {
                    Text("✓").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                } else if habit.isCountType {
                    Text("\(habit.currentCount)/\(habit.dailyTarget)").font(.system(size: 16, weight: .bold)).foregroundColor(Color.taskIncompleteText)
                } else {
                    Circle().stroke(Color(hex: "#999999"), lineWidth: 2.5).frame(width: 16, height: 16)
                }
                Text(habit.name).font(.system(size: 12, weight: .medium)).foregroundColor(habit.isCompleted ? .white : Color.widgetIncompleteText).lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity).aspectRatio(1.0, contentMode: .fit)
            .background(RoundedRectangle(cornerRadius: 16).fill(habit.isCompleted ? Color.widgetComplete : Color.widgetIncomplete))
        }
        .buttonStyle(.plain)
    }
}

struct TimerCardContent: View {
    let habit: WidgetHabitItem

    var body: some View {
        if habit.isCompleted {
            // Completed timer habit: show ✓ (same as normal completed)
            Button(intent: ToggleCheckIntent(habitID: habit.id)) {
                VStack(spacing: 6) {
                    Text("✓").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    Text(habit.name).font(.system(size: 12, weight: .medium)).foregroundColor(.white).lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).aspectRatio(1.0, contentMode: .fit)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.widgetComplete))
            }
            .buttonStyle(.plain)
        } else if habit.isTimerRunning {
            // Timer running: yellow + "todo中"
            Button(intent: StopTimerIntent(habitID: habit.id)) {
                VStack(spacing: 6) {
                    Text("todo中").font(.system(size: 13, weight: .bold)).foregroundColor(.black)
                    Text(habit.name).font(.system(size: 12, weight: .medium)).foregroundColor(.black).lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).aspectRatio(1.0, contentMode: .fit)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#FFD60A")))
            }
            .buttonStyle(.plain)
        } else {
            // Timer not started: timer icon
            Button(intent: StartTimerIntent(habitID: habit.id)) {
                VStack(spacing: 6) {
                    Image(systemName: "timer").font(.system(size: 18)).foregroundColor(Color.taskIncompleteText)
                    Text(habit.name).font(.system(size: 12, weight: .medium)).foregroundColor(Color.widgetIncompleteText).lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).aspectRatio(1.0, contentMode: .fit)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.widgetIncomplete))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Widget
struct CheckInWidget: Widget {
    let kind: String = "CheckInWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CheckInProvider()) { entry in
            CheckInWidgetView(entry: entry)
        }
        .configurationDisplayName("打卡").description("桌面直接打卡，可调尺寸")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
