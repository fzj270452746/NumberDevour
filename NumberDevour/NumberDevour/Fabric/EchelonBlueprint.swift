import SpriteKit

struct EchelonBlueprint {

    let echelon: Int
    let numericVisage: Int
    let orbitalDiameter: CGFloat

    static let compendium: [EchelonBlueprint] = [
        EchelonBlueprint(echelon: 0, numericVisage: 2, orbitalDiameter: 26),
        EchelonBlueprint(echelon: 1, numericVisage: 4, orbitalDiameter: 30),
        EchelonBlueprint(echelon: 2, numericVisage: 8, orbitalDiameter: 34),
        EchelonBlueprint(echelon: 3, numericVisage: 16, orbitalDiameter: 38),
        EchelonBlueprint(echelon: 4, numericVisage: 32, orbitalDiameter: 42),
        EchelonBlueprint(echelon: 5, numericVisage: 64, orbitalDiameter: 46),
        EchelonBlueprint(echelon: 6, numericVisage: 128, orbitalDiameter: 52),
        EchelonBlueprint(echelon: 7, numericVisage: 256, orbitalDiameter: 58),
        EchelonBlueprint(echelon: 8, numericVisage: 512, orbitalDiameter: 64),
        EchelonBlueprint(echelon: 9, numericVisage: 1024, orbitalDiameter: 70),
        EchelonBlueprint(echelon: 10, numericVisage: 2048, orbitalDiameter: 76),
        EchelonBlueprint(echelon: 11, numericVisage: 4096, orbitalDiameter: 82),
        EchelonBlueprint(echelon: 12, numericVisage: 8192, orbitalDiameter: 88),
        EchelonBlueprint(echelon: 13, numericVisage: 16384, orbitalDiameter: 94),
        EchelonBlueprint(echelon: 14, numericVisage: 32768, orbitalDiameter: 100),
        EchelonBlueprint(echelon: 15, numericVisage: 65536, orbitalDiameter: 106),
    ]

    static func retrieveBlueprint(forEchelon echelon: Int) -> EchelonBlueprint {
        let clampedEchelon = max(0, min(echelon, compendium.count - 1))
        return compendium[clampedEchelon]
    }
}
