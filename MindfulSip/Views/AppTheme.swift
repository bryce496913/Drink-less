import SwiftUI

enum AppTheme {
    static let background = Color.black
    static let surface = Color(red: 0.12, green: 0.04, blue: 0.2)
    static let accent = Color(red: 0.72, green: 0.29, blue: 0.95)
    static let highlight = Color(red: 0.98, green: 0.32, blue: 0.67)
    static let text = Color.white
    static let holiday = Color(red: 0.45, green: 0.72, blue: 0.9)

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
            case .pageTitle: return (16, .semibold)   // h1
            case .sectionTitle: return (14, .semibold) // h2
            case .cardTitle: return (14, .semibold)    // h2
            case .value: return (14, .semibold)        // h2 for highlighted stats
            case .body: return (12, .regular)          // h3
            case .secondary: return (10, .regular)     // paragraph
            case .statLabel: return (10, .medium)      // paragraph
            case .subtitle: return (12, .regular)      // h3
            case .caption: return (10, .regular)       // paragraph
            case .button: return (12, .semibold)       // h3
            case .tabLabel: return (10, .medium)       // paragraph
            case .dialogTitle: return (16, .semibold)  // h1
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
            case .primaryText: return AppTheme.text
            case .secondaryText: return AppTheme.text.opacity(0.82)
            case .accentHeading: return AppTheme.highlight
            case .highlightValue: return AppTheme.highlight
            case .mutedText: return AppTheme.text.opacity(0.75)
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

    func pageTitleStyle() -> some View {
        appTextStyle(.pageTitle).appTextColor(.primaryText)
    }

    func sectionTitleStyle() -> some View {
        appTextStyle(.sectionTitle).appTextColor(.primaryText)
    }

    func accordionTitleStyle() -> some View {
        appTextStyle(.cardTitle).appTextColor(.accentHeading)
    }

    func bodyTextStyle() -> some View {
        appTextStyle(.body).appTextColor(.primaryText)
    }

    func secondaryTextStyle() -> some View {
        appTextStyle(.secondary).appTextColor(.secondaryText)
    }

    func statLabelStyle() -> some View {
        appTextStyle(.statLabel).appTextColor(.secondaryText)
    }

    func statValueStyle() -> some View {
        appTextStyle(.value).appTextColor(.highlightValue)
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
