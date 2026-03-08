import SpriteKit

final class MorselSphere: SKNode {

    let echelonRank: Int
    private let orbShell = SKShapeNode()
    private let numeralLabel = SKLabelNode()
    private(set) var isPursuer: Bool

    init(echelonRank: Int, isPursuer: Bool = false) {
        self.echelonRank = echelonRank
        self.isPursuer = isPursuer
        super.init()
        self.name = "morselSphere"
        self.zPosition = CosmicConstants.Stratum.morselLayer.rawValue
        sculptAppearance()
        calibratePhysique()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Sculpting

    private func sculptAppearance() {
        let blueprint = EchelonBlueprint.retrieveBlueprint(forEchelon: echelonRank)
        let radius = blueprint.orbitalDiameter
        let tint = ChromaticPalette.hueForEchelon(echelonRank)

        orbShell.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        orbShell.fillColor = tint
        orbShell.strokeColor = tint.withAlphaComponent(0.4)
        orbShell.lineWidth = 1.5
        orbShell.glowWidth = isPursuer ? 5 : 2
        addChild(orbShell)

        numeralLabel.text = "\(blueprint.numericVisage)"
        numeralLabel.fontName = "AvenirNext-Bold"
        numeralLabel.fontSize = radius * 0.65
        numeralLabel.fontColor = .white
        numeralLabel.verticalAlignmentMode = .center
        numeralLabel.horizontalAlignmentMode = .center
        numeralLabel.zPosition = 1
        addChild(numeralLabel)

        if isPursuer {
            appendPursuerIndicator(radius: radius, tint: tint)
        }

        animateIdleUndulation()
    }

    private func appendPursuerIndicator(radius: CGFloat, tint: UIColor) {
        let auraNode = SKShapeNode(circleOfRadius: radius * 1.4)
        auraNode.fillColor = .clear
        auraNode.strokeColor = ChromaticPalette.cautionaryHue.withAlphaComponent(0.5)
        auraNode.lineWidth = 1.5
        auraNode.glowWidth = 3
        auraNode.zPosition = -1
        addChild(auraNode)

        let pulsateAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.8),
            SKAction.fadeAlpha(to: 0.6, duration: 0.8)
        ])
        auraNode.run(SKAction.repeatForever(pulsateAction))
    }

    private func animateIdleUndulation() {
        let scaleFactor = CGFloat.random(in: 0.95...1.0)
        let duration = TimeInterval.random(in: 1.5...2.5)
        let undulation = SKAction.sequence([
            SKAction.scale(to: scaleFactor, duration: duration),
            SKAction.scale(to: 1.0 / scaleFactor + 0.02, duration: duration)
        ])
        run(SKAction.repeatForever(undulation))
    }

    private func calibratePhysique() {
        let blueprint = EchelonBlueprint.retrieveBlueprint(forEchelon: echelonRank)
        let physique = SKPhysicsBody(circleOfRadius: blueprint.orbitalDiameter)
        physique.categoryBitMask = CosmicConstants.morselSigil
        physique.contactTestBitMask = CosmicConstants.protagonistSigil
        physique.collisionBitMask = CosmicConstants.perimeterSigil | CosmicConstants.morselSigil
        physique.allowsRotation = false
        physique.linearDamping = 5.0
        physique.restitution = 0.5
        physique.isDynamic = !isPursuer
        if isPursuer {
            physique.isDynamic = true
            physique.linearDamping = 2.0
        }
        self.physicsBody = physique
    }

    // MARK: - Pursuer Behavior

    func stalkerLocomotion(toward targetPosition: CGPoint) {
        guard isPursuer else { return }
        let dx = targetPosition.x - position.x
        let dy = targetPosition.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > 1 else { return }

        let pursuitSpeed: CGFloat = 50
        let normalizedDX = dx / distance
        let normalizedDY = dy / distance

        physicsBody?.velocity = CGVector(
            dx: normalizedDX * pursuitSpeed,
            dy: normalizedDY * pursuitSpeed
        )
    }

    // MARK: - Engulfment Spectacle

    func dissolveWithFlourishToward(target: CGPoint) {
        physicsBody = nil

        let moveAction = SKAction.move(to: target, duration: 0.2)
        moveAction.timingMode = .easeIn
        let shrinkAction = SKAction.scale(to: 0.01, duration: 0.2)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)

        run(SKAction.sequence([
            SKAction.group([moveAction, shrinkAction, fadeAction]),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Deflection

    func deflectAwayFrom(origin: CGPoint) {
        let dx = position.x - origin.x
        let dy = position.y - origin.y
        let distance = max(sqrt(dx * dx + dy * dy), 1)
        let impulseStrength: CGFloat = 300

        physicsBody?.applyImpulse(CGVector(
            dx: (dx / distance) * impulseStrength,
            dy: (dy / distance) * impulseStrength
        ))
    }
}
