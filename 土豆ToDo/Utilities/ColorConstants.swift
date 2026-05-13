import SwiftUI

extension Color {
    static let brand = Color(hex: "#FFD60A")
    static let appBackground = Color(hex: "#F5F5F7")
    static let cardBackground = Color.white
    static let taskIncomplete = Color(hex: "#F0F0F0")
    static let taskIncompleteText = Color(hex: "#888888")
    static let textPrimary = Color(hex: "#333333")
    static let textSecondary = Color(hex: "#999999")
    static let textMuted = Color(hex: "#CCCCCC")
    static let dividerColor = Color(hex: "#F0F0F0")
    static let widgetComplete = Color(hex: "#6B6B6B")
    static let widgetIncomplete = Color(hex: "#F5F5F5")
    static let widgetIncompleteIcon = Color(hex: "#999999")
    static let widgetIncompleteText = Color(hex: "#555555")
    static let countdownPast = Color(hex: "#CCCCCC")
    static let statBarEmpty = Color(hex: "#E0E0E0")
    static let heatLow = Color(hex: "#FFF3B0")
    static let heatMid = Color(hex: "#FFE066")
    static let heatHigh = Color(hex: "#FFD60A")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
