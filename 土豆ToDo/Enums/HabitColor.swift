import SwiftUI

enum HabitColor: String, CaseIterable, Codable {
    case yellow
    case green
    case pink

    var uiColor: Color {
        switch self {
        case .yellow: .accent
        case .green:  Color(hex: "#34C759")
        case .pink:   Color(hex: "#FF6B6B")
        }
    }

    var displayName: String {
        switch self {
        case .yellow: "活力黄"
        case .green:  "清新绿"
        case .pink:   "温暖粉"
        }
    }
}
