import SwiftUI

struct TodayView: View {
    @Binding var selectedDate: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DateSelectorBar(selectedDate: $selectedDate)
                    .padding(.top, 8)

                TaskGridView(selectedDate: selectedDate)
                    .padding(.horizontal, 16)

                CountdownCard()
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 20)
        }
        .background(Color.appBackground)
    }
}
