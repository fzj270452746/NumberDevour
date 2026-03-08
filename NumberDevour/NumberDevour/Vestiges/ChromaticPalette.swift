import SpriteKit
import UIKit

enum ChromaticPalette {

    // MARK: - Echelon Spectrum

    static func hueForEchelon(_ echelon: Int) -> UIColor {
        let spectrumGamut: [(UIColor, UIColor)] = [
            (UIColor(red: 0.30, green: 0.85, blue: 0.55, alpha: 1.0),
             UIColor(red: 0.20, green: 0.70, blue: 0.45, alpha: 1.0)),
            (UIColor(red: 0.25, green: 0.75, blue: 0.90, alpha: 1.0),
             UIColor(red: 0.15, green: 0.60, blue: 0.80, alpha: 1.0)),
            (UIColor(red: 0.55, green: 0.45, blue: 0.95, alpha: 1.0),
             UIColor(red: 0.45, green: 0.35, blue: 0.85, alpha: 1.0)),
            (UIColor(red: 0.95, green: 0.65, blue: 0.20, alpha: 1.0),
             UIColor(red: 0.85, green: 0.55, blue: 0.15, alpha: 1.0)),
            (UIColor(red: 0.95, green: 0.35, blue: 0.45, alpha: 1.0),
             UIColor(red: 0.85, green: 0.25, blue: 0.35, alpha: 1.0)),
            (UIColor(red: 0.90, green: 0.30, blue: 0.70, alpha: 1.0),
             UIColor(red: 0.80, green: 0.20, blue: 0.60, alpha: 1.0)),
            (UIColor(red: 1.00, green: 0.80, blue: 0.20, alpha: 1.0),
             UIColor(red: 0.90, green: 0.70, blue: 0.10, alpha: 1.0)),
            (UIColor(red: 0.20, green: 0.90, blue: 0.85, alpha: 1.0),
             UIColor(red: 0.10, green: 0.80, blue: 0.75, alpha: 1.0)),
        ]

        let idx = ((echelon % spectrumGamut.count) + spectrumGamut.count) % spectrumGamut.count
        return spectrumGamut[idx].0
    }

    static func peripheralHueForEchelon(_ echelon: Int) -> UIColor {
        let luminanceFactor: CGFloat = min(CGFloat(echelon) * 0.08, 0.6)
        return hueForEchelon(echelon).withAlphaComponent(0.4 + luminanceFactor)
    }

    // MARK: - Protagonist Hue

    static func protagonistRadiance(_ echelon: Int) -> UIColor {
        let progression = CGFloat(echelon - 1) / CGFloat(CosmicConstants.apexEchelon - 1)
        let r: CGFloat = 0.20 + progression * 0.75
        let g: CGFloat = 0.85 - progression * 0.40
        let b: CGFloat = 0.95 - progression * 0.30
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    // MARK: - Ambience

    static let cosmicBackdrop = UIColor(red: 0.06, green: 0.07, blue: 0.14, alpha: 1.0)
    static let gridFilament = UIColor(red: 0.12, green: 0.14, blue: 0.25, alpha: 0.4)
    static let interfaceCanvas = UIColor(red: 0.10, green: 0.11, blue: 0.20, alpha: 0.85)
    static let overlayVeil = UIColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 0.90)

    // MARK: - Interface Accents

    static let primaryAccent = UIColor(red: 0.30, green: 0.85, blue: 0.95, alpha: 1.0)
    static let secondaryAccent = UIColor(red: 0.95, green: 0.55, blue: 0.30, alpha: 1.0)
    static let tertiaryAccent = UIColor(red: 0.85, green: 0.30, blue: 0.65, alpha: 1.0)
    static let affirmativeHue = UIColor(red: 0.30, green: 0.90, blue: 0.50, alpha: 1.0)
    static let cautionaryHue = UIColor(red: 0.95, green: 0.35, blue: 0.40, alpha: 1.0)
    static let inscriptionHue = UIColor.white

    // MARK: - Button Gradients

    static let commenceGradient: [UIColor] = [
        UIColor(red: 0.25, green: 0.80, blue: 0.90, alpha: 1.0),
        UIColor(red: 0.35, green: 0.55, blue: 0.95, alpha: 1.0)
    ]

    static let recommenceGradient: [UIColor] = [
        UIColor(red: 0.90, green: 0.45, blue: 0.25, alpha: 1.0),
        UIColor(red: 0.95, green: 0.30, blue: 0.55, alpha: 1.0)
    ]
}
