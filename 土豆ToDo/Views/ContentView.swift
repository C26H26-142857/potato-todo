import SwiftUI
import SwiftData

struct ContentView: View {
    @Binding var selectedDate: Date
    @State private var showExpirySelection = false
    private let store = StoreManager.shared

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
        .onAppear { checkExpiry() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkExpiry()
        }
        .onChange(of: store.isSubscribed) { _, subscribed in
            if subscribed { restoreAllHabits() }
        }
        .fullScreenCover(isPresented: $showExpirySelection) {
            ExpirySelectionView { showExpirySelection = false }
        }
    }

    private func checkExpiry() {
        guard !store.isSubscribed else { return }
        let ctx = AppConfig.sharedContainer.mainContext
        var desc = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isHidden })
        desc.fetchLimit = StoreManager.maxFreeHabits + 1
        guard let count = try? ctx.fetchCount(desc), count > StoreManager.maxFreeHabits else { return }
        showExpirySelection = true
    }

    private func restoreAllHabits() {
        let ctx = AppConfig.sharedContainer.mainContext
        guard let habits = try? ctx.fetch(FetchDescriptor<Habit>()) else { return }
        for h in habits where h.isHidden { h.isHidden = false }
        try? ctx.save()
    }
}
