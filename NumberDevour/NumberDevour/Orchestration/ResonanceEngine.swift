import UIKit

final class ResonanceEngine {

    static let sovereign = ResonanceEngine()

    private var impactGenerator: UIImpactFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?

    private init() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        notificationGenerator = UINotificationFeedbackGenerator()
    }

    func emitEngulfmentPulse() {
        guard PredicationVault.sovereign.isResonanceEnabled else { return }
        impactGenerator?.prepare()
        impactGenerator?.impactOccurred()
    }

    func emitAscensionReverberation() {
        guard PredicationVault.sovereign.isResonanceEnabled else { return }
        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyGenerator.prepare()
        heavyGenerator.impactOccurred()
    }

    func emitDetonationTremor() {
        guard PredicationVault.sovereign.isResonanceEnabled else { return }
        notificationGenerator?.prepare()
        notificationGenerator?.notificationOccurred(.error)
    }

    func emitDeflectionRipple() {
        guard PredicationVault.sovereign.isResonanceEnabled else { return }
        let lightGenerator = UIImpactFeedbackGenerator(style: .light)
        lightGenerator.prepare()
        lightGenerator.impactOccurred()
    }
}
