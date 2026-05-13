import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(red: Double((int >> 16) & 0xFF) / 255,
                  green: Double((int >> 8) & 0xFF) / 255,
                  blue: Double(int & 0xFF) / 255)
    }
}

enum HabitColor: String, CaseIterable, Codable {
    case yellow
    case green
    case pink

    var uiColor: Color {
        switch self {
        case .yellow: Color(hex: "#FFD60A")
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
