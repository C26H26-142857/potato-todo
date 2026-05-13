import SwiftUI

struct ContentView: View {
    @Binding var selectedDate: Date

    var body: some View {
        TabView {
            TodayView(selectedDate: $selectedDate)
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("今日")
                }

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("日历")
                }

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("统计")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
        }
.tint(.accent)
    }
}
