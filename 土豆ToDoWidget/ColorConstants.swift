import SwiftUI

extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(hex: hex)
        })
    }

    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Dynamic Color Constants (light / dark)
extension Color {
    // Always same
    static let brand = Color(hex: "#FFD60A")

    // Backgrounds
    static let appBackground = Color(light: "#F5F5F7", dark: "#000000")
    static let cardBackground = Color(light: "#FFFFFF", dark: "#1C1C1E")

    // Task button
    static let taskIncomplete = Color(light: "#F0F0F0", dark: "#2C2C2E")
    static let taskIncompleteText = Color(light: "#888888", dark: "#A0A0A0")

    // Text
    static let textPrimary = Color(light: "#333333", dark: "#E5E5E5")
    static let textSecondary = Color(light: "#999999", dark: "#8E8E93")
    static let textMuted = Color(light: "#CCCCCC", dark: "#555555")

    // Dividers
    static let dividerColor = Color(light: "#F0F0F0", dark: "#38383A")

    // Widget — gray in light, white in dark
    static let widgetLabel = Color(light: "#999999", dark: "#FFFFFF")

    // Widget
    static let widgetComplete = Color(light: "#6B6B6B", dark: "#3A3A3C")
    static let widgetIncomplete = Color(light: "#F5F5F5", dark: "#1C1C1E")
    static let widgetIncompleteIcon = Color(light: "#999999", dark: "#CCCCCC")
    static let widgetIncompleteText = Color(light: "#555555", dark: "#FFFFFF")

    // Countdown / Stats
    static let countdownPast = Color(light: "#CCCCCC", dark: "#666666")
    static let statBarEmpty = Color(light: "#E0E0E0", dark: "#3A3A3C")

    // Heat map (works in both modes)
    static let heatLow = Color(hex: "#FFF3B0")
    static let heatMid = Color(hex: "#FFE066")
    static let heatHigh = Color(hex: "#FFD60A")

    // Scope picker
    static let scopePickerBg = Color(light: "#E8E8E8", dark: "#2C2C2E")
}
