import SwiftUI

struct TodayView: View {
    @Binding var selectedDate: Date
    @State private var selectedCountdown: CountdownEvent?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DateSelectorBar(selectedDate: $selectedDate)
                    .padding(.top, 8)

                TaskGridView(selectedDate: selectedDate)
                    .padding(.horizontal, 16)

                CountdownCard(onTap: { selectedCountdown = $0 })
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 20)
        }
        .background(Color.appBackground)
        .sheet(item: $selectedCountdown) { event in
            CountdownEditView(event: event)
        }
    }
}
