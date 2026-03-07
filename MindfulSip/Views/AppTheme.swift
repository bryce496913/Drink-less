import SwiftUI

enum AppTheme {
    static let background = Color.black
    static let surface = Color(red: 0.12, green: 0.04, blue: 0.2)
    static let accent = Color(red: 0.72, green: 0.29, blue: 0.95)
    static let highlight = Color(red: 0.98, green: 0.32, blue: 0.67)
    static let text = Color.white

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let size: CGFloat
        switch style {
        case .largeTitle, .title, .title2, .title3, .headline:
            size = 20
        case .subheadline, .body, .callout:
            size = 15
        case .footnote, .caption, .caption2:
            size = 13
        @unknown default:
            size = 15
        }

        let family: String
        switch weight {
        case .bold: family = "Poppins-Bold"
        case .semibold: family = "Poppins-SemiBold"
        case .medium: family = "Poppins-Medium"
        default: family = "Poppins-Regular"
        }
        return .custom(family, size: size)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.font(.headline, weight: .semibold))
            .foregroundStyle(AppTheme.text)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.font(.subheadline, weight: .medium))
            .foregroundStyle(AppTheme.text)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(AppTheme.surface.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.highlight, lineWidth: 1))
    }
}
