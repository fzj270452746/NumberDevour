import SpriteKit

final class CelestialOrb: SKNode {

    private(set) var currentEchelon: Int = 1
    private(set) var engulfmentTally: Int = 0

    private let orbShell = SKShapeNode()
    private let numeralLabel = SKLabelNode()
    private let luminousHalo = SKShapeNode()

    var orbitalRadius: CGFloat {
        return EchelonBlueprint.retrieveBlueprint(forEchelon: currentEchelon).orbitalDiameter
    }

    override init() {
        super.init()
        zPosition = CosmicConstants.Stratum.protagonistLayer.rawValue
        sculptVisage()
        calibratePhysique()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Sculpting

    private func sculptVisage() {
        let blueprint = EchelonBlueprint.retrieveBlueprint(forEchelon: currentEchelon)
        let radius = blueprint.orbitalDiameter

        luminousHalo.path = CGPath(ellipseIn: CGRect(x: -radius * 1.3, y: -radius * 1.3, width: radius * 2.6, height: radius * 2.6), transform: nil)
        luminousHalo.fillColor = ChromaticPalette.protagonistRadiance(currentEchelon).withAlphaComponent(0.15)
        luminousHalo.strokeColor = .clear
        luminousHalo.zPosition = -2
        addChild(luminousHalo)

        orbShell.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        orbShell.fillColor = ChromaticPalette.protagonistRadiance(currentEchelon)
        orbShell.strokeColor = ChromaticPalette.protagonistRadiance(currentEchelon).withAlphaComponent(0.6)
        orbShell.lineWidth = 2.5
        orbShell.glowWidth = 4
        orbShell.zPosition = -1
        addChild(orbShell)

        numeralLabel.text = "\(blueprint.numericVisage)"
        numeralLabel.fontName = "AvenirNext-Bold"
        numeralLabel.fontSize = radius * 0.7
        numeralLabel.fontColor = .white
        numeralLabel.verticalAlignmentMode = .center
        numeralLabel.horizontalAlignmentMode = .center
        numeralLabel.zPosition = 1
        addChild(numeralLabel)
    }

    private func calibratePhysique() {
        let blueprint = EchelonBlueprint.retrieveBlueprint(forEchelon: currentEchelon)
        let physique = SKPhysicsBody(circleOfRadius: blueprint.orbitalDiameter)
        physique.categoryBitMask = CosmicConstants.protagonistSigil
        physique.contactTestBitMask = CosmicConstants.morselSigil
        physique.collisionBitMask = CosmicConstants.perimeterSigil
        physique.allowsRotation = false
        physique.linearDamping = 3.0
        physique.restitution = 0.3
        physique.mass = 1.0
        self.physicsBody = physique
    }

    // MARK: - Metamorphosis

    func ascendEchelon() {
        guard currentEchelon < CosmicConstants.apexEchelon else { return }
        currentEchelon += 1
        engulfmentTally += 1
        transmuteAppearance()
        calibratePhysique()
        invokeAscensionSpectacle()
    }

    func incrementTally() {
        engulfmentTally += 1
    }

    private func transmuteAppearance() {
        let blueprint = EchelonBlueprint.retrieveBlueprint(forEchelon: currentEchelon)
        let radius = blueprint.orbitalDiameter
        let tint = ChromaticPalette.protagonistRadiance(currentEchelon)

        let morphDuration: TimeInterval = 0.3

        orbShell.run(SKAction.customAction(withDuration: morphDuration) { [weak self] _, elapsed in
            guard let self = self else { return }
            let progress = elapsed / CGFloat(morphDuration)
            let currentRadius = self.orbitalRadius - (self.orbitalRadius - radius) * progress
            self.orbShell.path = CGPath(ellipseIn: CGRect(x: -currentRadius, y: -currentRadius, width: currentRadius * 2, height: currentRadius * 2), transform: nil)
        })

        orbShell.fillColor = tint
        orbShell.strokeColor = tint.withAlphaComponent(0.6)

        luminousHalo.fillColor = tint.withAlphaComponent(0.15)
        luminousHalo.path = CGPath(ellipseIn: CGRect(x: -radius * 1.3, y: -radius * 1.3, width: radius * 2.6, height: radius * 2.6), transform: nil)

        numeralLabel.text = "\(blueprint.numericVisage)"
        numeralLabel.fontSize = radius * 0.7
    }

    private func invokeAscensionSpectacle() {
        let pulseExpand = SKAction.scale(to: 1.3, duration: 0.15)
        let pulseContract = SKAction.scale(to: 1.0, duration: 0.15)
        pulseExpand.timingMode = .easeOut
        pulseContract.timingMode = .easeIn
        run(SKAction.sequence([pulseExpand, pulseContract]))

        spawnRadiantParticles()
    }

    private func spawnRadiantParticles() {
        let tint = ChromaticPalette.protagonistRadiance(currentEchelon)
        let particleCount = 12

        for i in 0..<particleCount {
            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = tint
            particle.strokeColor = .clear
            particle.glowWidth = 2
            particle.zPosition = CosmicConstants.Stratum.particleLayer.rawValue
            particle.position = .zero
            addChild(particle)

            let distance = orbitalRadius * 2.5
            let destination = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)

            let moveAction = SKAction.move(to: destination, duration: 0.4)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.4)
            let removeAction = SKAction.removeFromParent()

            particle.run(SKAction.sequence([
                SKAction.group([moveAction, fadeAction]),
                removeAction
            ]))
        }
    }

    // MARK: - Locomotion

    func propelToward(vector: CGVector) {
        let blueprint = EchelonBlueprint.retrieveBlueprint(forEchelon: currentEchelon)
        let velocity = CosmicConstants.genesisVelocity - CGFloat(currentEchelon) * CosmicConstants.velocityDecrement
        let clampedVelocity = max(velocity, 80)

        let dx = vector.dx * clampedVelocity
        let dy = vector.dy * clampedVelocity
        physicsBody?.velocity = CGVector(dx: dx, dy: dy)

        _ = blueprint
    }

    // MARK: - Detonation

    func detonateOrb(completion: @escaping () -> Void) {
        physicsBody = nil

        let shardCount = 16
        let tint = ChromaticPalette.protagonistRadiance(currentEchelon)

        for i in 0..<shardCount {
            let angle = (CGFloat(i) / CGFloat(shardCount)) * .pi * 2
            let shard = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
            shard.fillColor = tint
            shard.strokeColor = .white.withAlphaComponent(0.5)
            shard.glowWidth = 3
            shard.zPosition = CosmicConstants.Stratum.particleLayer.rawValue
            shard.position = position
            parent?.addChild(shard)

            let distance = CGFloat.random(in: 60...150)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )

            let moveAction = SKAction.move(to: destination, duration: TimeInterval.random(in: 0.3...0.6))
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let scaleAction = SKAction.scale(to: 0.1, duration: 0.5)

            shard.run(SKAction.sequence([
                SKAction.group([moveAction, fadeAction, scaleAction]),
                SKAction.removeFromParent()
            ]))
        }

        let flashNode = SKShapeNode(circleOfRadius: orbitalRadius * 2)
        flashNode.fillColor = .white
        flashNode.strokeColor = .clear
        flashNode.alpha = 0.8
        flashNode.zPosition = CosmicConstants.Stratum.particleLayer.rawValue
        flashNode.position = position
        parent?.addChild(flashNode)

        flashNode.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))

        run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.01, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.run { completion() },
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Tally

    func computeAcumenScore() -> Int {
        return engulfmentTally * currentEchelon
    }
}
