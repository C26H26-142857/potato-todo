import Foundation

enum HabitType: String, CaseIterable, Codable {
    case single
    case count

    var displayName: String {
        switch self {
        case .single: "单次打卡"
        case .count:  "多次计数"
        }
    }
}
