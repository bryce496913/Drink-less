import SwiftUI

enum AppTheme {
    static let background = Color.black
    static let surface = Color(red: 0.12, green: 0.04, blue: 0.2)
    static let accent = Color(red: 0.72, green: 0.29, blue: 0.95)
    static let highlight = Color(red: 0.98, green: 0.32, blue: 0.67)
    static let text = Color.white

    enum TextStyle {
        case pageTitle
        case sectionTitle
        case cardTitle
        case value
        case body
        case secondary
        case statLabel
        case subtitle
        case caption
        case button
        case tabLabel
        case dialogTitle

        fileprivate var definition: (size: CGFloat, weight: Font.Weight) {
            switch self {
            case .pageTitle: return (32, .bold)
            case .sectionTitle: return (24, .semibold)
            case .cardTitle: return (19, .medium)
            case .value: return (26, .bold)
            case .body: return (17, .regular)
            case .secondary: return (15, .regular)
            case .statLabel: return (13, .medium)
            case .subtitle: return (16, .regular)
            case .caption: return (13, .regular)
            case .button: return (16, .semibold)
            case .tabLabel: return (12, .medium)
            case .dialogTitle: return (25, .semibold)
            }
        }
    }

    enum TextColorRole {
        case primaryText
        case secondaryText
        case accentHeading
        case highlightValue
        case mutedText
        case positiveText
        case warningText

        fileprivate var color: Color {
            switch self {
            case .primaryText: return Color.white
            case .secondaryText: return Color.white.opacity(0.88)
            case .accentHeading: return AppTheme.accent
            case .highlightValue: return AppTheme.highlight
            case .mutedText: return Color.white.opacity(0.62)
            case .positiveText: return Color.green
            case .warningText: return Color.orange
            }
        }
    }

    static func font(_ style: TextStyle) -> Font {
        let definition = style.definition
        return font(size: definition.size, weight: definition.weight)
    }

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        switch style {
        case .largeTitle:
            return font(.pageTitle)
        case .title, .title2, .title3:
            return font(.sectionTitle)
        case .headline:
            return font(.cardTitle)
        case .subheadline:
            return font(.secondary)
        case .body, .callout:
            return font(.body)
        case .footnote:
            return font(.secondary)
        case .caption, .caption2:
            return font(.caption)
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
