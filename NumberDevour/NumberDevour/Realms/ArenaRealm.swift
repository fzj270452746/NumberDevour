import SpriteKit

final class ArenaRealm: SKScene, SKPhysicsContactDelegate {

    // MARK: - Entities

    private var protagonist: CelestialOrb!
    private var navigationHelm: NavigationHelm!
    private let worldCanvas = SKNode()
    private let cameraLens = SKCameraNode()
    private let interfaceStratum = SKNode()

    // MARK: - HUD Elements

    private let echelonLabel = SKLabelNode()
    private let echelonValueLabel = SKLabelNode()
    private let acumenLabel = SKLabelNode()
    private let acumenValueLabel = SKLabelNode()
    private var suspendButton: SKNode!

    // MARK: - Chrono Sprint HUD

    private let countdownLabel = SKLabelNode()
    private let countdownArcBackground = SKShapeNode()
    private let countdownArcForeground = SKShapeNode()
    private let countdownContainer = SKNode()

    // MARK: - State

    private let arenaVariant: ArenaVariant
    private var isArenaActive: Bool = false
    private var elapsedDuration: TimeInterval = 0
    private var previousFrameTimestamp: TimeInterval = 0
    private var escalationTimer: TimeInterval = 0
    private var currentMorselCeiling: Int = CosmicConstants.maximumMorselQuota
    private var seniorProbabilityBonus: CGFloat = 0
    private var viewportDimensions: CGSize = .zero

    // MARK: - Chrono Sprint State

    private var sprintRemainder: TimeInterval = 0
    private var sprintAllotment: TimeInterval = 0

    // MARK: - Initializer

    init(size: CGSize, variant: ArenaVariant = .classicEndurance) {
        self.arenaVariant = variant
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        self.arenaVariant = .classicEndurance
        super.init(coder: aDecoder)
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        viewportDimensions = view.bounds.size
        backgroundColor = ChromaticPalette.cosmicBackdrop

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        erect()

        if arenaVariant == .chronoSprint {
            calibrateSprintClock()
            erectSprintChronometer()
        }

        isArenaActive = true
    }

    // MARK: - Construction

    private func erect() {
        erectWorldCanvas()
        erectPerimeterBarricade()
        erectSubstrateGrid()
        erectProtagonist()
        erectMorselPopulation()
        erectCameraLens()
        erectInterfaceStratum()
        erectNavigationHelm()
    }

    private func erectWorldCanvas() {
        addChild(worldCanvas)
    }

    private func erectPerimeterBarricade() {
        let terrarium = CGRect(
            x: 0, y: 0,
            width: CosmicConstants.terrariumSpan,
            height: CosmicConstants.terrariumBreadth
        )

        let barricade = SKPhysicsBody(edgeLoopFrom: terrarium)
        barricade.categoryBitMask = CosmicConstants.perimeterSigil
        barricade.collisionBitMask = CosmicConstants.protagonistSigil | CosmicConstants.morselSigil
        barricade.friction = 0
        barricade.restitution = 0.5
        worldCanvas.physicsBody = barricade
    }

    private func erectSubstrateGrid() {
        let gridSpacing: CGFloat = 80
        let gridColor = ChromaticPalette.gridFilament

        let gridNode = SKNode()
        gridNode.zPosition = CosmicConstants.Stratum.gridMesh.rawValue

        for x in stride(from: CGFloat(0), through: CosmicConstants.terrariumSpan, by: gridSpacing) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: CosmicConstants.terrariumBreadth))
            line.path = path
            line.strokeColor = gridColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        for y in stride(from: CGFloat(0), through: CosmicConstants.terrariumBreadth, by: gridSpacing) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: CosmicConstants.terrariumSpan, y: y))
            line.path = path
            line.strokeColor = gridColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        worldCanvas.addChild(gridNode)
    }

    private func erectProtagonist() {
        protagonist = CelestialOrb()
        protagonist.position = CGPoint(
            x: CosmicConstants.terrariumSpan / 2,
            y: CosmicConstants.terrariumBreadth / 2
        )
        worldCanvas.addChild(protagonist)
    }

    private func erectMorselPopulation() {
        let initialCount = Int.random(in: CosmicConstants.minimumMorselQuota...CosmicConstants.maximumMorselQuota)
        for _ in 0..<initialCount {
            spawnSolitaryMorsel()
        }
    }

    private func erectCameraLens() {
        cameraLens.position = protagonist.position
        addChild(cameraLens)
        camera = cameraLens
    }

    private func erectInterfaceStratum() {
        interfaceStratum.zPosition = CosmicConstants.Stratum.interfaceLayer.rawValue
        cameraLens.addChild(interfaceStratum)

        let safeAreaTop = viewportDimensions.height / 2

        // Echelon display (left)
        let leftX = -viewportDimensions.width / 2 + 20
        let topY = safeAreaTop - 55

        let echelonBg = fabricateHUDPill(width: 100, height: 52)
        echelonBg.position = CGPoint(x: leftX + 50, y: topY - 10)
        interfaceStratum.addChild(echelonBg)

        echelonLabel.text = "LEVEL"
        echelonLabel.fontName = "AvenirNext-Medium"
        echelonLabel.fontSize = adaptiveFontScale(base: 11)
        echelonLabel.fontColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.7)
        echelonLabel.horizontalAlignmentMode = .left
        echelonLabel.verticalAlignmentMode = .center
        echelonLabel.position = CGPoint(x: leftX + 12, y: topY)
        interfaceStratum.addChild(echelonLabel)

        echelonValueLabel.text = "1"
        echelonValueLabel.fontName = "AvenirNext-Bold"
        echelonValueLabel.fontSize = adaptiveFontScale(base: 20)
        echelonValueLabel.fontColor = ChromaticPalette.inscriptionHue
        echelonValueLabel.horizontalAlignmentMode = .left
        echelonValueLabel.verticalAlignmentMode = .center
        echelonValueLabel.position = CGPoint(x: leftX + 12, y: topY - 20)
        interfaceStratum.addChild(echelonValueLabel)

        // Score display (left, below level)
        let scoreBg = fabricateHUDPill(width: 110, height: 52)
        scoreBg.position = CGPoint(x: leftX + 55, y: topY - 72)
        interfaceStratum.addChild(scoreBg)

        acumenLabel.text = "SCORE"
        acumenLabel.fontName = "AvenirNext-Medium"
        acumenLabel.fontSize = adaptiveFontScale(base: 11)
        acumenLabel.fontColor = ChromaticPalette.secondaryAccent.withAlphaComponent(0.7)
        acumenLabel.horizontalAlignmentMode = .left
        acumenLabel.verticalAlignmentMode = .center
        acumenLabel.position = CGPoint(x: leftX + 12, y: topY - 62)
        interfaceStratum.addChild(acumenLabel)

        acumenValueLabel.text = "0"
        acumenValueLabel.fontName = "AvenirNext-Bold"
        acumenValueLabel.fontSize = adaptiveFontScale(base: 20)
        acumenValueLabel.fontColor = ChromaticPalette.inscriptionHue
        acumenValueLabel.horizontalAlignmentMode = .left
        acumenValueLabel.verticalAlignmentMode = .center
        acumenValueLabel.position = CGPoint(x: leftX + 12, y: topY - 82)
        interfaceStratum.addChild(acumenValueLabel)

        // Pause button (right)
        let rightX = viewportDimensions.width / 2 - 45
        erectSuspendButton(at: CGPoint(x: rightX, y: topY - 10))
    }

    private func fabricateHUDPill(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = UIBezierPath(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: 12)
        let pill = SKShapeNode(path: path.cgPath)
        pill.fillColor = ChromaticPalette.interfaceCanvas
        pill.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.15)
        pill.lineWidth = 1
        return pill
    }

    private func erectSuspendButton(at position: CGPoint) {
        let container = SKNode()
        container.name = "suspendVestige"
        container.position = position

        let bg = SKShapeNode(circleOfRadius: 22)
        bg.fillColor = ChromaticPalette.interfaceCanvas
        bg.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        bg.lineWidth = 1.5
        bg.glowWidth = 1
        bg.name = "suspendVestige"
        container.addChild(bg)

        let barWidth: CGFloat = 4
        let barHeight: CGFloat = 16
        let barSpacing: CGFloat = 5

        let leftBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        leftBar.fillColor = ChromaticPalette.primaryAccent
        leftBar.strokeColor = .clear
        leftBar.position = CGPoint(x: -barSpacing, y: 0)
        leftBar.name = "suspendVestige"
        container.addChild(leftBar)

        let rightBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        rightBar.fillColor = ChromaticPalette.primaryAccent
        rightBar.strokeColor = .clear
        rightBar.position = CGPoint(x: barSpacing, y: 0)
        rightBar.name = "suspendVestige"
        container.addChild(rightBar)

        interfaceStratum.addChild(container)
        suspendButton = container
    }

    private func erectNavigationHelm() {
        navigationHelm = NavigationHelm()
        let helmX = -viewportDimensions.width / 2 + CosmicConstants.helmOuterRadius + 40
        let helmY = -viewportDimensions.height / 2 + CosmicConstants.helmOuterRadius + 60
        navigationHelm.position = CGPoint(x: helmX, y: helmY)
        cameraLens.addChild(navigationHelm)
    }

    // MARK: - Chrono Sprint Setup

    private func calibrateSprintClock() {
        sprintAllotment = computeSprintAllotment(forEchelon: 1)
        sprintRemainder = sprintAllotment
    }

    private func computeSprintAllotment(forEchelon echelon: Int) -> TimeInterval {
        return CosmicConstants.sprintGenesisAllotment + Double(max(echelon - 1, 0)) * CosmicConstants.sprintEchelonBonus
    }

    private func erectSprintChronometer() {
        let topY = viewportDimensions.height / 2 - 100
        let arcRadius: CGFloat = 26

        countdownContainer.position = CGPoint(x: 0, y: topY - 10)
        countdownContainer.zPosition = CosmicConstants.Stratum.interfaceLayer.rawValue

        let bgPath = UIBezierPath(arcCenter: .zero, radius: arcRadius, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)
        countdownArcBackground.path = bgPath.cgPath
        countdownArcBackground.fillColor = .clear
        countdownArcBackground.strokeColor = UIColor.white.withAlphaComponent(0.12)
        countdownArcBackground.lineWidth = 5
        countdownContainer.addChild(countdownArcBackground)

        countdownArcForeground.fillColor = .clear
        countdownArcForeground.strokeColor = ChromaticPalette.affirmativeHue
        countdownArcForeground.lineWidth = 5
        countdownArcForeground.glowWidth = 3
        refreshArcVisualization(fraction: 1.0)
        countdownContainer.addChild(countdownArcForeground)

        countdownLabel.fontName = "AvenirNext-Bold"
        countdownLabel.fontSize = adaptiveFontScale(base: 16)
        countdownLabel.fontColor = .white
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.text = "\(Int(ceil(sprintRemainder)))"
        countdownContainer.addChild(countdownLabel)

        interfaceStratum.addChild(countdownContainer)
    }

    private func refreshArcVisualization(fraction: CGFloat) {
        let arcRadius: CGFloat = 26
        let clampedFraction = max(0, min(fraction, 1))
        let endAngle = -.pi / 2 + .pi * 2 * clampedFraction
        let path = UIBezierPath(arcCenter: .zero, radius: arcRadius, startAngle: -.pi / 2, endAngle: endAngle, clockwise: true)
        countdownArcForeground.path = path.cgPath
    }

    private func tickSprintChronometer(deltaTime: TimeInterval) {
        sprintRemainder -= deltaTime
        let fraction = CGFloat(sprintRemainder / sprintAllotment)

        refreshArcVisualization(fraction: fraction)
        countdownLabel.text = "\(max(Int(ceil(sprintRemainder)), 0))"

        if fraction > 0.4 {
            countdownArcForeground.strokeColor = ChromaticPalette.affirmativeHue
            countdownLabel.fontColor = .white
        } else if fraction > 0.2 {
            countdownArcForeground.strokeColor = ChromaticPalette.secondaryAccent
            countdownLabel.fontColor = ChromaticPalette.secondaryAccent
        } else {
            countdownArcForeground.strokeColor = ChromaticPalette.cautionaryHue
            countdownLabel.fontColor = ChromaticPalette.cautionaryHue
            if Int(sprintRemainder * 4) % 2 == 0 {
                countdownContainer.setScale(1.08)
            } else {
                countdownContainer.setScale(1.0)
            }
        }

        if sprintRemainder <= 0 {
            sprintRemainder = 0
            executeChronoExpiration()
        }
    }

    private func replenishSprintClock() {
        let newEchelon = protagonist.currentEchelon
        sprintAllotment = computeSprintAllotment(forEchelon: newEchelon)
        sprintRemainder = sprintAllotment

        countdownContainer.setScale(1.0)
        countdownArcForeground.strokeColor = ChromaticPalette.affirmativeHue
        countdownLabel.fontColor = .white

        let celebrateAction = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.12),
            SKAction.scale(to: 1.0, duration: 0.12)
        ])
        countdownContainer.run(celebrateAction)
    }

    private func executeChronoExpiration() {
        executeAnnihilation()
    }

    // MARK: - Frame Update

    override func update(_ currentTime: TimeInterval) {
        guard isArenaActive else { return }

        if previousFrameTimestamp == 0 {
            previousFrameTimestamp = currentTime
        }
        let deltaTime = currentTime - previousFrameTimestamp
        previousFrameTimestamp = currentTime
        elapsedDuration += deltaTime

        propelProtagonist()
        updateCameraLensPosition()
        refreshInterfaceData()
        conductDifficultyEscalation(deltaTime: deltaTime)
        replenishMorselDeficit()
        orchestratePursuerMovement()

        if arenaVariant == .chronoSprint {
            tickSprintChronometer(deltaTime: deltaTime)
        }
    }

    // MARK: - Protagonist Movement

    private func propelProtagonist() {
        let vector = navigationHelm.locomotionVector
        protagonist.propelToward(vector: vector)
    }

    // MARK: - Camera

    private func updateCameraLensPosition() {
        let targetPosition = protagonist.position
        let lerpFactor: CGFloat = 0.1
        let dx = targetPosition.x - cameraLens.position.x
        let dy = targetPosition.y - cameraLens.position.y
        cameraLens.position.x += dx * lerpFactor
        cameraLens.position.y += dy * lerpFactor
    }

    // MARK: - HUD Refresh

    private func refreshInterfaceData() {
        echelonValueLabel.text = "\(protagonist.currentEchelon)"
        acumenValueLabel.text = "\(protagonist.computeAcumenScore())"
    }

    // MARK: - Difficulty Escalation

    private func conductDifficultyEscalation(deltaTime: TimeInterval) {
        escalationTimer += deltaTime
        if escalationTimer >= CosmicConstants.escalationCadence {
            escalationTimer = 0
            seniorProbabilityBonus += CosmicConstants.seniorProbabilityAscent
            currentMorselCeiling = min(currentMorselCeiling + CosmicConstants.populationSurge, 200)
        }
    }

    // MARK: - Morsel Spawning

    private func spawnSolitaryMorsel(forcedEchelon: Int? = nil) {
        let echelon = forcedEchelon ?? determineStochasticEchelon()
        let morsel = MorselSphere(echelonRank: echelon)

        let margin: CGFloat = 60
        var spawnPosition: CGPoint
        var attempts = 0

        repeat {
            spawnPosition = CGPoint(
                x: CGFloat.random(in: margin...(CosmicConstants.terrariumSpan - margin)),
                y: CGFloat.random(in: margin...(CosmicConstants.terrariumBreadth - margin))
            )
            attempts += 1
        } while distanceBetween(spawnPosition, protagonist.position) < 200 && attempts < 20

        morsel.position = spawnPosition

        morsel.alpha = 0
        morsel.setScale(0.3)
        worldCanvas.addChild(morsel)

        morsel.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
    }

    private func determineStochasticEchelon() -> Int {
        let random = CGFloat.random(in: 0...1)
        var cumulativeProbability: CGFloat = 0

        for entry in CosmicConstants.genesisDistribution {
            let adjustedLikelihood: CGFloat
            if entry.echelon >= 6 {
                adjustedLikelihood = entry.likelihood + seniorProbabilityBonus
            } else {
                adjustedLikelihood = entry.likelihood
            }
            cumulativeProbability += adjustedLikelihood
            if random <= cumulativeProbability {
                return entry.echelon
            }
        }

        return 0
    }

    private func replenishMorselDeficit() {
        let activeMorsels = worldCanvas.children.compactMap { $0 as? MorselSphere }
        let deficit = currentMorselCeiling - activeMorsels.count

        if deficit > 0 {
            let spawnBatch = min(deficit, 3)
            for _ in 0..<spawnBatch {
                spawnSolitaryMorsel()
            }
        }
    }

    // MARK: - Pursuer Orchestration

    private func orchestratePursuerMovement() {
        let pursuers = worldCanvas.children.compactMap { $0 as? MorselSphere }.filter { $0.isPursuer }
        for pursuer in pursuers {
            pursuer.stalkerLocomotion(toward: protagonist.position)
        }
    }

    // MARK: - Collision Detection

    func didBegin(_ contact: SKPhysicsContact) {
        guard isArenaActive else { return }

        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        var protagonistBody: SKPhysicsBody?
        var morselBody: SKPhysicsBody?

        if bodyA.categoryBitMask == CosmicConstants.protagonistSigil &&
            bodyB.categoryBitMask == CosmicConstants.morselSigil {
            protagonistBody = bodyA
            morselBody = bodyB
        } else if bodyB.categoryBitMask == CosmicConstants.protagonistSigil &&
                    bodyA.categoryBitMask == CosmicConstants.morselSigil {
            protagonistBody = bodyB
            morselBody = bodyA
        }

        guard let _ = protagonistBody,
              let morselNode = morselBody?.node as? MorselSphere else { return }

        adjudicateEncounter(with: morselNode)
    }

    private func adjudicateEncounter(with morsel: MorselSphere) {
        let protagonistEchelon = protagonist.currentEchelon
        let morselEchelon = morsel.echelonRank

        if morselEchelon < protagonistEchelon {
            executeEngulfment(of: morsel)
        } else if morselEchelon == protagonistEchelon {
            executeFusionAscent(of: morsel)
        } else {
            executeAnnihilation()
        }
    }

    private func executeEngulfment(of morsel: MorselSphere) {
        morsel.dissolveWithFlourishToward(target: protagonist.position)
        protagonist.incrementTally()
        ResonanceEngine.sovereign.emitEngulfmentPulse()
    }

    private func executeFusionAscent(of morsel: MorselSphere) {
        morsel.dissolveWithFlourishToward(target: protagonist.position)
        protagonist.ascendEchelon()
        ResonanceEngine.sovereign.emitAscensionReverberation()

        if arenaVariant == .chronoSprint {
            replenishSprintClock()
        }
    }

    private func executeAnnihilation() {
        guard isArenaActive else { return }
        isArenaActive = false

        ResonanceEngine.sovereign.emitDetonationTremor()
        executeScreenConvulsion()

        protagonist.detonateOrb { [weak self] in
            self?.presentEpilogueVista()
        }
    }

    private func executeScreenConvulsion() {
        let shakeIntensity: CGFloat = 12
        let shakeDuration: TimeInterval = 0.4
        let shakeCount = 6

        var shakeActions: [SKAction] = []
        for _ in 0..<shakeCount {
            let dx = CGFloat.random(in: -shakeIntensity...shakeIntensity)
            let dy = CGFloat.random(in: -shakeIntensity...shakeIntensity)
            shakeActions.append(SKAction.moveBy(x: dx, y: dy, duration: shakeDuration / Double(shakeCount * 2)))
            shakeActions.append(SKAction.moveBy(x: -dx, y: -dy, duration: shakeDuration / Double(shakeCount * 2)))
        }

        cameraLens.run(SKAction.sequence(shakeActions))
    }

    // MARK: - Game Over

    private func presentEpilogueVista() {
        let finalScore = protagonist.computeAcumenScore()
        let isNewApex = TallyLedger.sovereign.adjudicateApex(candidateScore: finalScore, variant: arenaVariant)

        let epilogue = EpilogueVista(
            canvasExtent: viewportDimensions,
            finalScore: finalScore,
            apexScore: TallyLedger.sovereign.retrieveApexScore(variant: arenaVariant),
            isNewApex: isNewApex
        )
        epilogue.onRecommence = { [weak self] in
            self?.recommenceArena()
        }
        epilogue.onReturnToGateway = { [weak self] in
            self?.returnToGateway()
        }

        cameraLens.addChild(epilogue)
    }

    private func recommenceArena() {
        guard let skView = self.view else { return }
        let freshArena = ArenaRealm(size: viewportDimensions, variant: arenaVariant)
        freshArena.scaleMode = .resizeFill
        skView.presentScene(freshArena, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func returnToGateway() {
        guard let skView = self.view else { return }
        let gateway = GatewayPortal(size: viewportDimensions)
        gateway.scaleMode = .resizeFill
        skView.presentScene(gateway, transition: SKTransition.fade(withDuration: 0.5))
    }

    // MARK: - Pause

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let locationInCamera = touch.location(in: cameraLens)
        let tappedNodes = cameraLens.nodes(at: locationInCamera)

        for node in tappedNodes {
            if node.name == "suspendVestige" {
                suspendArena()
                return
            }
        }
    }

    private func suspendArena() {
        guard isArenaActive else { return }
        isArenaActive = false
        worldCanvas.isPaused = true

        let dialogue = LuminescentDialogue(canvasExtent: viewportDimensions)
        dialogue.presentPauseManifest(
            onResume: { [weak self] in
                self?.resumeArena()
            },
            onRestart: { [weak self] in
                self?.recommenceArena()
            },
            onGateway: { [weak self] in
                self?.returnToGateway()
            }
        )

        cameraLens.addChild(dialogue)
    }

    private func resumeArena() {
        isArenaActive = true
        worldCanvas.isPaused = false
        previousFrameTimestamp = 0
    }

    // MARK: - Utility

    private func distanceBetween(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }

    private func adaptiveFontScale(base: CGFloat) -> CGFloat {
        let referenceWidth: CGFloat = 375
        let scaleFactor = viewportDimensions.width / referenceWidth
        return base * min(scaleFactor, 1.3)
    }
}
