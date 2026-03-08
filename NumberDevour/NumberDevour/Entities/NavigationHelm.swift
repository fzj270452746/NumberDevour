import SpriteKit

final class NavigationHelm: SKNode {

    private let outerPerimeter: CGFloat
    private let innerPerimeter: CGFloat

    private let outerRing = SKShapeNode()
    private let innerKnob = SKShapeNode()

    private(set) var locomotionVector: CGVector = .zero
    private var isEngaged: Bool = false

    init(outerRadius: CGFloat = CosmicConstants.helmOuterRadius,
         innerRadius: CGFloat = CosmicConstants.helmInnerRadius) {
        self.outerPerimeter = outerRadius
        self.innerPerimeter = innerRadius
        super.init()
        self.zPosition = CosmicConstants.Stratum.helmLayer.rawValue
        self.isUserInteractionEnabled = true
        self.alpha = 0.7
        sculptHelm()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Sculpting

    private func sculptHelm() {
        outerRing.path = CGPath(ellipseIn: CGRect(x: -outerPerimeter, y: -outerPerimeter, width: outerPerimeter * 2, height: outerPerimeter * 2), transform: nil)
        outerRing.fillColor = UIColor.white.withAlphaComponent(0.08)
        outerRing.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        outerRing.lineWidth = 2
        outerRing.glowWidth = 1
        addChild(outerRing)

        innerKnob.path = CGPath(ellipseIn: CGRect(x: -innerPerimeter, y: -innerPerimeter, width: innerPerimeter * 2, height: innerPerimeter * 2), transform: nil)
        innerKnob.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.4)
        innerKnob.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.6)
        innerKnob.lineWidth = 1.5
        innerKnob.glowWidth = 2
        addChild(innerKnob)
    }

    // MARK: - Interaction Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        isEngaged = true
        alpha = 1.0
        refreshKnobDisplacement(touch: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isEngaged else { return }
        refreshKnobDisplacement(touch: touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        disengageHelm()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        disengageHelm()
    }

    private func refreshKnobDisplacement(touch: UITouch) {
        let touchLocation = touch.location(in: self)
        let dx = touchLocation.x
        let dy = touchLocation.y
        let distance = sqrt(dx * dx + dy * dy)

        let clampedDistance = min(distance, outerPerimeter)
        let angle = atan2(dy, dx)

        let knobX = cos(angle) * clampedDistance
        let knobY = sin(angle) * clampedDistance

        innerKnob.position = CGPoint(x: knobX, y: knobY)

        let normalizedMagnitude = clampedDistance / outerPerimeter
        locomotionVector = CGVector(
            dx: cos(angle) * normalizedMagnitude,
            dy: sin(angle) * normalizedMagnitude
        )
    }

    private func disengageHelm() {
        isEngaged = false
        locomotionVector = .zero
        alpha = 0.7

        let returnAction = SKAction.move(to: .zero, duration: 0.15)
        returnAction.timingMode = .easeOut
        innerKnob.run(returnAction)
    }
}
