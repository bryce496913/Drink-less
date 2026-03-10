import SwiftUI

enum AppTheme {
    static let background = Color.black
    static let surface = Color(red: 0.12, green: 0.04, blue: 0.2)
    static let accent = Color(red: 0.72, green: 0.29, blue: 0.95)
    static let highlight = Color(red: 0.98, green: 0.32, blue: 0.67)
    static let text = Color.white

    enum Typography {
        case h1
        case h2
        case h3
        case paragraph

        var size: CGFloat {
            switch self {
            case .h1: return 16
            case .h2: return 14
            case .h3: return 12
            case .paragraph: return 10
            }
        }
    }

    static func font(_ typography: Typography, weight: Font.Weight = .regular) -> Font {
        let size = typography.size

        let family: String
        switch weight {
        case .bold: family = "Poppins-Bold"
        case .semibold: family = "Poppins-SemiBold"
        case .medium: family = "Poppins-Medium"
        default: family = "Poppins-Regular"
        }
        return .custom(family, size: size)
    }

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let typography: Typography
        switch style {
        case .largeTitle, .title, .title2, .title3:
            typography = .h1
        case .headline, .subheadline:
            typography = .h2
        case .body, .callout, .footnote, .caption, .caption2:
            typography = .h3
        @unknown default:
            typography = .paragraph
        }
        return font(typography, weight: weight)
    }
}

enum AppLayout {
    static let screenWidth: CGFloat = 393
    static let screenHeight: CGFloat = 852
}

extension View {
    func appFullscreenContainer() -> some View {
        frame(width: AppLayout.screenWidth, height: AppLayout.screenHeight)
            .edgesIgnoringSafeArea(.all)
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
