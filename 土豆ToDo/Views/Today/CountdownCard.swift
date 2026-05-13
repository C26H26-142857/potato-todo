import SwiftUI
import SwiftData

struct CountdownCard: View {
    @Query(sort: \CountdownEvent.targetDate) private var events: [CountdownEvent]

    var body: some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("土豆ToDo · 未来已来")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, 14)

                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    CountdownRow(event: event)
                    if index < events.count - 1 {
                        Divider()
                            .padding(.vertical, 12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            )
        }
    }
}

struct CountdownRow: View {
    let event: CountdownEvent

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(event.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Text(formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(event.isPast ? "已过去" : "还剩")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text("\(event.displayDays)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(event.isPast ? .countdownPast : .accent)
                Text("天")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: event.targetDate)
    }
}
