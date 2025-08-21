import SwiftUI

extension Color {
    static let donnerBackground = Color(red: 0.15, green: 0.16, blue: 0.20)
    static let donnerDarkBackground = Color(red: 0.10, green: 0.11, blue: 0.15)
    static let donnerLightning = Color(red: 1.0, green: 0.85, blue: 0.3)
    static let donnerLightningGlow = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let donnerAccent = Color(red: 1.0, green: 0.7, blue: 0.25)
    static let donnerTextPrimary = Color.white
    static let donnerTextSecondary = Color(white: 0.7)
    static let donnerCardBackground = Color(red: 0.18, green: 0.19, blue: 0.24).opacity(0.8)
}

extension LinearGradient {
    static let donnerLightningGradient = LinearGradient(
        colors: [
            Color.donnerLightning,
            Color.donnerLightningGlow
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let donnerButtonGradient = LinearGradient(
        colors: [
            Color.donnerLightning.opacity(0.9),
            Color.donnerLightningGlow.opacity(0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let donnerBackgroundGradient = LinearGradient(
        colors: [
            Color.donnerDarkBackground,
            Color.donnerBackground
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func glow(color: Color = .donnerLightningGlow, radius: CGFloat = 10) -> some View {
        self.modifier(GlowModifier(color: color, radius: radius))
    }
}
