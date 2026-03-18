import Foundation

enum AchievementCategory: String, Codable, CaseIterable {
    case dryStreak
    case appUseStreak
    case goalMetDays
}

enum AchievementRequirementType: String, Codable, CaseIterable {
    case dryStreak
    case appUseStreak
    case goalMetDays
}

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let requirementType: AchievementRequirementType
    let requirementValue: Int
    let iconName: String
    let emoji: String
    var isUnlocked: Bool
}

struct AchievementStats: Hashable {
    let dryStreak: Int
    let appUseStreak: Int
    let goalMetDays: Int

    func value(for requirementType: AchievementRequirementType) -> Int {
        switch requirementType {
        case .dryStreak:
            return dryStreak
        case .appUseStreak:
            return appUseStreak
        case .goalMetDays:
            return goalMetDays
        }
    }
}
