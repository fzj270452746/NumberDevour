import SpriteKit

enum CosmicConstants {

    // MARK: - Terrarium Dimensions

    static let terrariumSpan: CGFloat = 2000
    static let terrariumBreadth: CGFloat = 2000

    // MARK: - Protagonist Defaults

    static let genesisMagnitude: CGFloat = 30
    static let genesisVelocity: CGFloat = 200
    static let velocityDecrement: CGFloat = 5
    static let apexEchelon: Int = 15

    // MARK: - Morsel Population

    static let minimumMorselQuota: Int = 60
    static let maximumMorselQuota: Int = 100

    // MARK: - Chronological Escalation

    static let escalationCadence: TimeInterval = 30
    static let seniorProbabilityAscent: CGFloat = 0.03
    static let populationSurge: Int = 10

    // MARK: - Collision Taxonomy

    static let protagonistSigil: UInt32 = 0x1 << 0
    static let morselSigil: UInt32 = 0x1 << 1
    static let perimeterSigil: UInt32 = 0x1 << 2

    // MARK: - Morsel Spawn Probabilities

    static let genesisDistribution: [(echelon: Int, likelihood: CGFloat)] = [
        (0,  0.250),
        (1,  0.200),
        (2,  0.150),
        (3,  0.100),
        (4,  0.075),
        (5,  0.055),
        (6,  0.040),
        (7,  0.030),
        (8,  0.025),
        (9,  0.020),
        (10, 0.015),
        (11, 0.012),
        (12, 0.010),
        (13, 0.008),
        (14, 0.005),
        (15, 0.005)
    ]

    // MARK: - Joystick Dimensions

    static let helmOuterRadius: CGFloat = 60
    static let helmInnerRadius: CGFloat = 25

    // MARK: - Persistence Keys

    static let apexScoreVault: String = "nd_apex_score_vault"
    static let apexSprintScoreVault: String = "nd_apex_sprint_vault"

    // MARK: - Chrono Sprint Mode

    static let sprintGenesisAllotment: TimeInterval = 5.0
    static let sprintEchelonBonus: TimeInterval = 1.5

    // MARK: - Z Ordering

    enum Stratum: CGFloat {
        case substrate = -10
        case gridMesh = -5
        case morselLayer = 0
        case protagonistLayer = 10
        case particleLayer = 15
        case interfaceLayer = 100
        case helmLayer = 110
        case overlayLayer = 200
    }
}
