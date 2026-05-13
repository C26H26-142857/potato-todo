import SwiftUI

struct DateSelectorBar: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE"
        return f
    }()
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    private var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-2...2).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }

    var body: some View {
        let now = Date()

        HStack(spacing: 10) {
            ForEach(dates, id: \.self) { date in
                let isToday = calendar.isDate(date, inSameDayAs: now)
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

                VStack(spacing: 2) {
                    Text(isToday ? "Today" : Self.weekdayFormatter.string(from: date))
                        .font(.system(size: 11))
                        .fontWeight(isToday ? .semibold : .regular)
                    Text(Self.dayFormatter.string(from: date))
                        .font(.system(size: 15))
                        .fontWeight(isToday ? .bold : .semibold)
                }
                .frame(width: 48)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? .accent : .clear)
                )
                .foregroundColor(isSelected ? .black : .gray)
                .onTapGesture { selectedDate = date }
            }
        }
    }
}
