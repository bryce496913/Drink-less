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

        fileprivate var size: CGFloat {
            switch self {
            case .h1: return 16
            case .h2: return 14
            case .h3: return 12
            case .paragraph: return 10
            }
        }
    }

    enum TextStyle {
        case screenTitle
        case screenSubtitle
        case sectionTitle
        case accordionTitle
        case cardLabel
        case statValue
        case body
        case bodySecondary
        case helper
        case button
        case tabLabel
        case modalTitle
        case modalBody

        fileprivate var definition: (size: CGFloat, weight: Font.Weight) {
            switch self {
            case .screenTitle: return (30, .bold)
            case .screenSubtitle: return (16, .medium)
            case .sectionTitle: return (22, .semibold)
            case .accordionTitle: return (18, .semibold)
            case .cardLabel: return (13, .medium)
            case .statValue: return (24, .bold)
            case .body: return (16, .regular)
            case .bodySecondary: return (15, .regular)
            case .helper: return (13, .regular)
            case .button: return (16, .semibold)
            case .tabLabel: return (11, .medium)
            case .modalTitle: return (24, .semibold)
            case .modalBody: return (16, .regular)
            }
        }
    }

    enum TextColorRole {
        case primaryText
        case secondaryText
        case tertiaryText
        case accentText
        case positiveText
        case warningText
        case mutedText

        fileprivate var color: Color {
            switch self {
            case .primaryText: return Color.white
            case .secondaryText: return Color.white.opacity(0.9)
            case .tertiaryText: return Color.white.opacity(0.74)
            case .accentText: return AppTheme.highlight
            case .positiveText: return Color.green
            case .warningText: return Color.orange
            case .mutedText: return Color.white.opacity(0.58)
            }
        }
    }

    static func font(_ style: TextStyle) -> Font {
        let definition = style.definition
        return font(size: definition.size, weight: definition.weight)
    }

    static func font(_ typography: Typography, weight: Font.Weight = .regular) -> Font {
        font(size: typography.size, weight: weight)
    }

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        switch style {
        case .largeTitle:
            return font(.screenTitle)
        case .title, .title2, .title3:
            return font(size: 20, weight: weight)
        case .headline:
            return font(size: 17, weight: weight)
        case .subheadline:
            return font(size: 15, weight: weight)
        case .body, .callout:
            return font(.body)
        case .footnote:
            return font(.bodySecondary)
        case .caption, .caption2:
            return font(.helper)
        @unknown default:
            return font(.body)
        }
    }

    static func textColor(_ role: TextColorRole) -> Color {
        role.color
    }

    static func font(size: CGFloat, weight: Font.Weight) -> Font {
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

extension View {
    func appFullscreenContainer() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    func appTextStyle(_ style: AppTheme.TextStyle) -> some View {
        font(AppTheme.font(style))
    }

    func appTextColor(_ role: AppTheme.TextColorRole) -> some View {
        foregroundStyle(AppTheme.textColor(role))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appTextStyle(.button)
            .appTextColor(.primaryText)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.72 : 1), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appTextStyle(.button)
            .appTextColor(.primaryText)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(AppTheme.surface.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.highlight, lineWidth: 1))
    }
}
