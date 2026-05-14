import SwiftUI
import SwiftData

struct ExpirySelectionView: View {
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedHabits: Set<UUID> = []
    @State private var selectedTimers: Set<UUID> = []
    let onDone: () -> Void

    private let maxHabits = 10
    private let maxTimers = 3

    private var visibleHabits: [Habit] { habits.filter { !$0.isHidden } }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Info message
                VStack(alignment: .leading, spacing: 4) {
                    Text("选择保留 \(maxHabits) 个习惯")
                        .font(.system(size: 16, weight: .bold))
                    Text("其余习惯和打卡数据将在重新订阅后恢复")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Count badges
                HStack(spacing: 16) {
                    Text("习惯 \(selectedHabits.count)/\(maxHabits)")
                        .font(.system(size: 13))
                        .foregroundColor(selectedHabits.count == maxHabits ? .brand : .gray)
                    Text("土豆钟 \(selectedTimers.count)/\(maxTimers)")
                        .font(.system(size: 13))
                        .foregroundColor(selectedTimers.count >= maxTimers ? .brand : .gray)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Habit list
                List {
                    ForEach(visibleHabits) { habit in
                        let isKept = selectedHabits.contains(habit.id)
                        let canSelect = isKept || selectedHabits.count < maxHabits

                        VStack(spacing: 0) {
                            HStack(spacing: 10) {
                                // Keep checkbox
                                Button {
                                    toggleKeep(habit.id)
                                } label: {
                                    Image(systemName: isKept ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(canSelect ? .black : .textMuted)
                                }
                                .disabled(!canSelect)

                                // Icon
                                Image(systemName: habit.sfSymbol)
                                    .font(.system(size: 14))
                                    .frame(width: 28, height: 28)
                                    .background(habit.color.uiColor.opacity(0.15))
                                    .clipShape(Circle())

                                // Name
                                Text(habit.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)

                                Spacer()

                                // Timer toggle (only for kept habits)
                                if habit.enableTimer && isKept {
                                    let timerOn = selectedTimers.contains(habit.id)
                                    let canToggle = timerOn || selectedTimers.count < maxTimers
                                    Image(systemName: timerOn ? "timer.circle.fill" : "timer.circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(timerOn ? .brand : .textMuted)
                                        .opacity(canToggle ? 1 : 0.4)
                                        .onTapGesture {
                                            toggleTimer(habit.id)
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)

                // Confirm button
                Button(action: confirm) {
                    Text("确认")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedHabits.count == maxHabits ? Color.brand : Color.gray.opacity(0.3))
                        .foregroundColor(selectedHabits.count == maxHabits ? .black : .gray)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedHabits.count != maxHabits)
                .padding(16)
            }
            .navigationTitle("订阅已到期")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if selectedHabits.isEmpty { preselect() }
            }
        }
    }

    private func preselect() {
        // Keep first 10 visible habits, and first 3 timer habits among them
        let kept = Array(visibleHabits.prefix(maxHabits))
        selectedHabits = Set(kept.map { $0.id })
        let timers = kept.filter { $0.enableTimer }.prefix(maxTimers)
        selectedTimers = Set(timers.map { $0.id })
    }

    private func toggleKeep(_ id: UUID) {
        if selectedHabits.contains(id) {
            selectedHabits.remove(id)
            selectedTimers.remove(id)
        } else if selectedHabits.count < maxHabits {
            selectedHabits.insert(id)
        }
    }

    private func toggleTimer(_ id: UUID) {
        if selectedTimers.contains(id) {
            selectedTimers.remove(id)
        } else if selectedTimers.count < maxTimers {
            selectedTimers.insert(id)
        }
    }

    private func confirm() {
        for habit in visibleHabits {
            habit.isHidden = !selectedHabits.contains(habit.id)
            if habit.isHidden {
                habit.enableTimer = false
            } else if habit.enableTimer && !selectedTimers.contains(habit.id) {
                habit.enableTimer = false
            }
        }
        try? modelContext.save()
        onDone()
    }
}
