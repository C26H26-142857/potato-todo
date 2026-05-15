import WidgetKit
import SwiftUI

// MARK: - Entry
struct CalendarEntry: TimelineEntry {
    let date: Date
    let dates: [WidgetDateItem]
}

struct WidgetDateItem {
    let date: Date
    let isToday: Bool
    let weekday: String
    let dayNumber: String
}

// MARK: - Provider
struct CalendarProvider: TimelineProvider {
    private static let weekdayFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE"
        return f
    }()
    private static let dayFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), dates: sampleDates())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: Date(), dates: sampleDates()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let dates = (-2...2).compactMap { offset -> WidgetDateItem? in
            guard let d = Calendar.current.date(byAdding: .day, value: offset, to: today) else { return nil }
            let isToday = Calendar.current.isDate(d, inSameDayAs: today)
            return WidgetDateItem(
                date: d,
                isToday: isToday,
                weekday: isToday ? "Today" : Self.weekdayFmt.string(from: d),
                dayNumber: Self.dayFmt.string(from: d)
            )
        }
        let entry = CalendarEntry(date: Date(), dates: dates)
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func sampleDates() -> [WidgetDateItem] {
        let today = Calendar.current.startOfDay(for: Date())
        return (-2...2).compactMap { offset in
            guard let d = Calendar.current.date(byAdding: .day, value: offset, to: today) else { return nil }
            let isToday = Calendar.current.isDate(d, inSameDayAs: today)
            return WidgetDateItem(date: d, isToday: isToday,
                weekday: isToday ? "Today" : "Mon",
                dayNumber: "\(Calendar.current.component(.day, from: d))")
        }
    }
}

// MARK: - View
struct CalendarWidgetView: View {
    var entry: CalendarEntry
    @Environment(\.widgetRenderingMode) private var renderingMode

    private var isAccented: Bool {
        guard #available(iOS 18.0, *) else { return false }
        return renderingMode != .fullColor
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(entry.dates.indices, id: \.self) { index in
                let d = entry.dates[index]
                VStack(spacing: 2) {
                    Text(d.weekday)
                        .font(.system(size: 11))
                        .fontWeight(d.isToday ? .semibold : .regular)
                    Text(d.dayNumber)
                        .font(.system(size: 15))
                        .fontWeight(d.isToday ? .bold : .semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(d.isToday
                              ? (isAccented ? Color.brand.opacity(0.3) : Color(hex: "#FFD60A"))
                              : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(d.isToday && isAccented ? Color.brand : Color.clear, lineWidth: 1.5)
                )
                .foregroundColor(d.isToday
                                 ? (isAccented ? .primary : .black)
                                 : (isAccented ? .primary : .widgetLabel))
                .widgetAccentable(d.isToday)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isAccented ? Color.clear : Color.appBackground)
    }
}

// MARK: - Widget
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("日历")
        .description("5-day date bar, today centered")
        .supportedFamilies([.systemMedium])
    }
}
