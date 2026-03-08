import Foundation

enum ArenaVariant: Int {
    case classicEndurance = 0
    case chronoSprint = 1

    var exhibitionTitle: String {
        switch self {
        case .classicEndurance:
            return "CLASSIC"
        case .chronoSprint:
            return "SPRINT"
        }
    }

    var exhibitionSubtitle: String {
        switch self {
        case .classicEndurance:
            return "Devour and grow at your own pace"
        case .chronoSprint:
            return "Level up before time runs out!"
        }
    }

    var persistenceKey: String {
        switch self {
        case .classicEndurance:
            return CosmicConstants.apexScoreVault
        case .chronoSprint:
            return CosmicConstants.apexSprintScoreVault
        }
    }
}
