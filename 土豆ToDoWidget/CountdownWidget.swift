import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Entry
struct CountdownEntry: TimelineEntry {
    let date: Date
    let events: [WidgetCountdownEvent]
}

struct WidgetCountdownEvent {
    let name: String
    let targetDate: Date
    let displayDays: Int
    let isPast: Bool
}

// MARK: - Provider
struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), events: [
            WidgetCountdownEvent(name: "考研上岸", targetDate: Date(), displayDays: 227, isPast: false),
            WidgetCountdownEvent(name: "宝宝出生", targetDate: Date(), displayDays: 483, isPast: true),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let events = loadEvents()
        completion(CountdownEntry(date: Date(), events: events.isEmpty ? placeholderEvents : events))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let events = loadEvents()
        let entry = CountdownEntry(date: Date(), events: events.isEmpty ? placeholderEvents : events)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private var placeholderEvents: [WidgetCountdownEvent] {
        [WidgetCountdownEvent(name: "考研上岸", targetDate: Date(), displayDays: 227, isPast: false)]
    }

    private func loadEvents() -> [WidgetCountdownEvent] {
        let ctx = WidgetContainer.context
        let descriptor = FetchDescriptor<CountdownEvent>(sortBy: [SortDescriptor(\.targetDate)])
        guard let events = try? ctx.fetch(descriptor), !events.isEmpty else { return [] }
        let today = Calendar.current.startOfDay(for: Date())
        return events.map { e in
            let days = Calendar.current.dateComponents([.day], from: today, to: e.targetDate).day ?? 0
            return WidgetCountdownEvent(name: e.name, targetDate: e.targetDate, displayDays: abs(days), isPast: days < 0)
        }
    }
}

// MARK: - View
struct CountdownWidgetView: View {
    var entry: CountdownEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    private var isAccented: Bool {
        guard #available(iOS 18.0, *) else { return false }
        return renderingMode != .fullColor
    }

    var body: some View {
        let maxShow = family == .systemLarge ? 6 : 2
        let display = Array(entry.events.prefix(maxShow))
        let overflow = entry.events.count - maxShow

        VStack(alignment: .leading, spacing: 0) {
            Text("土豆ToDo · 未来已来")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isAccented ? .primary : Color.textPrimary)
                .padding(.bottom, 8)

            ForEach(Array(display.enumerated()), id: \.offset) { index, event in
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.name)
                            .font(.system(size: 14, weight: .bold))
                        Text(formattedDate(event.targetDate))
                            .font(.system(size: 11))
                            .foregroundColor(isAccented ? .primary : .widgetLabel)
                    }
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(event.isPast ? "已过去" : "还剩")
                            .font(.system(size: 10))
                            .foregroundColor(isAccented ? .primary : .widgetLabel)
                        Text("\(event.displayDays)")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(event.isPast
                                             ? (isAccented ? .primary.opacity(0.5) : Color(hex: "#CCCCCC"))
                                             : (isAccented ? .brand : Color(hex: "#FFD60A")))
                            .widgetAccentable(!event.isPast)
                        Text("天")
                            .font(.system(size: 10))
                            .foregroundColor(isAccented ? .primary : .widgetLabel)
                    }
                }
                if index < display.count - 1 {
                    Divider()
                        .padding(.vertical, 10)
                        .opacity(isAccented ? 0.3 : 1)
                }
            }

            if overflow > 0 {
                Text("+\(overflow) 个更多")
                    .font(.system(size: 11))
                    .foregroundColor(isAccented ? .primary : .widgetLabel)
                    .padding(.top, 8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(isAccented ? Color.clear : Color.cardBackground)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy年M月d日"; return f.string(from: date)
    }
}

// MARK: - Widget
struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("倒计时").description("显示未来的倒计时事件")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
