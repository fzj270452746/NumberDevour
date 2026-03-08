import SpriteKit

final class GatewayPortal: SKScene {

    private var viewportDimensions: CGSize = .zero
    private let titleInscription = SKLabelNode()
    private let subtitleInscription = SKLabelNode()
    private var apexScoreInscription = SKLabelNode()
    private var classicButton: SKNode?
    private var sprintButton: SKNode?
    private var pedagogueButton: SKNode?
    private var calibrationButton: SKNode?
    private var floatingOrbs: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        viewportDimensions = view.bounds.size
        backgroundColor = ChromaticPalette.cosmicBackdrop
        removeAllChildren()

        composeAmbientParticles()
        composeTitleSequence()
        composeApexDisplay()
        composeModeButtons()
        composeAuxiliaryButtons()
        animateEntrance()
    }

    // MARK: - Ambient Particles

    private func composeAmbientParticles() {
        let particleCount = 30
        for _ in 0..<particleCount {
            let radius = CGFloat.random(in: 2...6)
            let particle = SKShapeNode(circleOfRadius: radius)
            let echelon = Int.random(in: 1...7)
            particle.fillColor = ChromaticPalette.hueForEchelon(echelon).withAlphaComponent(CGFloat.random(in: 0.1...0.35))
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...viewportDimensions.width),
                y: CGFloat.random(in: 0...viewportDimensions.height)
            )
            particle.zPosition = -5
            addChild(particle)
            floatingOrbs.append(particle)

            let driftDuration = TimeInterval.random(in: 4...8)
            let driftX = CGFloat.random(in: -30...30)
            let driftY = CGFloat.random(in: -30...30)
            let drift = SKAction.moveBy(x: driftX, y: driftY, duration: driftDuration)
            let driftBack = drift.reversed()
            particle.run(SKAction.repeatForever(SKAction.sequence([drift, driftBack])))

            let pulseDuration = TimeInterval.random(in: 2...4)
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.05...0.15), duration: pulseDuration),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.2...0.4), duration: pulseDuration)
            ])
            particle.run(SKAction.repeatForever(pulse))
        }
    }

    // MARK: - Title Composition

    private var layoutMetrics: LayoutMetrics {
        let vp = viewportDimensions
        let bottomMargin: CGFloat = max(vp.height * 0.05, 30)
        let topMargin: CGFloat = vp.height * 0.05
        let usable = vp.height - topMargin - bottomMargin

        let buttonHeight: CGFloat = min(70, usable * 0.10)
        let smallHeight: CGFloat = min(44, usable * 0.065)
        let spacing: CGFloat = min(20, usable * 0.028)

        let titleY     = bottomMargin + usable * 0.78
        let orbY       = bottomMargin + usable * 0.60
        let scoreY     = bottomMargin + usable * 0.48
        let classicY   = bottomMargin + usable * 0.33
        let sprintY    = classicY - buttonHeight - spacing
        let auxiliaryY = sprintY - buttonHeight - spacing - 6

        return LayoutMetrics(
            titleY: titleY, orbY: orbY, scoreY: scoreY,
            classicY: classicY, sprintY: sprintY, auxiliaryY: auxiliaryY,
            buttonHeight: buttonHeight, smallHeight: smallHeight, spacing: spacing
        )
    }

    private struct LayoutMetrics {
        let titleY, orbY, scoreY, classicY, sprintY, auxiliaryY: CGFloat
        let buttonHeight, smallHeight, spacing: CGFloat
    }

    private func composeTitleSequence() {
        let centerX = viewportDimensions.width / 2
        let topY = layoutMetrics.titleY

        let decorativeLine1 = SKShapeNode(rectOf: CGSize(width: viewportDimensions.width * 0.4, height: 1.5))
        decorativeLine1.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.4)
        decorativeLine1.strokeColor = .clear
        decorativeLine1.position = CGPoint(x: centerX, y: topY + 35)
        addChild(decorativeLine1)

        titleInscription.text = "NUMBER"
        titleInscription.fontName = "AvenirNext-Bold"
        titleInscription.fontSize = adaptiveFontScale(base: 48)
        titleInscription.fontColor = ChromaticPalette.primaryAccent
        titleInscription.position = CGPoint(x: centerX, y: topY)
        titleInscription.horizontalAlignmentMode = .center
        titleInscription.verticalAlignmentMode = .center
        addChild(titleInscription)

        subtitleInscription.text = "DEVOUR"
        subtitleInscription.fontName = "AvenirNext-Heavy"
        subtitleInscription.fontSize = adaptiveFontScale(base: 52)
        subtitleInscription.fontColor = ChromaticPalette.secondaryAccent
        subtitleInscription.position = CGPoint(x: centerX, y: topY - 50)
        subtitleInscription.horizontalAlignmentMode = .center
        subtitleInscription.verticalAlignmentMode = .center
        addChild(subtitleInscription)

        let decorativeLine2 = SKShapeNode(rectOf: CGSize(width: viewportDimensions.width * 0.4, height: 1.5))
        decorativeLine2.fillColor = ChromaticPalette.secondaryAccent.withAlphaComponent(0.4)
        decorativeLine2.strokeColor = .clear
        decorativeLine2.position = CGPoint(x: centerX, y: topY - 85)
        addChild(decorativeLine2)

        composeInsigniaEmblem()
        composeOrnamentalOrbs()
    }

    private func composeInsigniaEmblem() {
        let emblem = SKSpriteNode(imageNamed: "dot-logo")
        let emblemSize: CGFloat = 90
        emblem.size = CGSize(width: emblemSize, height: emblemSize)
        let topY = layoutMetrics.titleY
        emblem.position = CGPoint(x: viewportDimensions.width - 50, y: topY - 10)
        emblem.zPosition = -1
        emblem.alpha = 0.6
        addChild(emblem)
    }

    private func composeOrnamentalOrbs() {
        let centerX = viewportDimensions.width / 2
        let orbY = layoutMetrics.orbY
        let sampleEchelons = [2, 4, 8, 16, 32]
        let spacing: CGFloat = 48

        for (index, numericVisage) in sampleEchelons.enumerated() {
            let echelon = index + 1
            let xOffset = CGFloat(index - 2) * spacing
            let radius: CGFloat = CGFloat(14 + index * 3)

            let orb = SKShapeNode(circleOfRadius: radius)
            orb.fillColor = ChromaticPalette.hueForEchelon(echelon)
            orb.strokeColor = ChromaticPalette.hueForEchelon(echelon).withAlphaComponent(0.4)
            orb.lineWidth = 1.5
            orb.glowWidth = 2
            orb.position = CGPoint(x: centerX + xOffset, y: orbY)
            addChild(orb)

            let label = SKLabelNode(text: "\(numericVisage)")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = radius * 0.7
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: centerX + xOffset, y: orbY)
            addChild(label)

            let bobDuration = TimeInterval.random(in: 1.5...2.5)
            let bobAction = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 6, duration: bobDuration),
                SKAction.moveBy(x: 0, y: -6, duration: bobDuration)
            ])
            orb.run(SKAction.repeatForever(bobAction))
            label.run(SKAction.repeatForever(bobAction))
        }
    }

    // MARK: - Apex Score Display

    private func composeApexDisplay() {
        let centerX = viewportDimensions.width / 2
        let scoreY = layoutMetrics.scoreY

        let apexValue = TallyLedger.sovereign.retrieveApexScore()

        let apexLabel = SKLabelNode(text: "BEST SCORE")
        apexLabel.fontName = "AvenirNext-Medium"
        apexLabel.fontSize = adaptiveFontScale(base: 14)
        apexLabel.fontColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.6)
        apexLabel.position = CGPoint(x: centerX, y: scoreY + 15)
        apexLabel.horizontalAlignmentMode = .center
        addChild(apexLabel)

        apexScoreInscription.text = "\(apexValue)"
        apexScoreInscription.fontName = "AvenirNext-Bold"
        apexScoreInscription.fontSize = adaptiveFontScale(base: 28)
        apexScoreInscription.fontColor = ChromaticPalette.inscriptionHue
        apexScoreInscription.position = CGPoint(x: centerX, y: scoreY - 15)
        apexScoreInscription.horizontalAlignmentMode = .center
        addChild(apexScoreInscription)
    }

    // MARK: - Mode Buttons

    private func composeModeButtons() {
        let centerX = viewportDimensions.width / 2
        let metrics = layoutMetrics
        let buttonWidth: CGFloat = viewportDimensions.width * 0.65
        let buttonHeight = metrics.buttonHeight

        let classicY = metrics.classicY
        let sprintY = metrics.sprintY

        // Classic Mode Button
        classicButton = fabricateModeCard(
            title: "CLASSIC",
            subtitle: "Free play, grow without limits",
            breadth: buttonWidth,
            altitude: buttonHeight,
            palette: ChromaticPalette.commenceGradient,
            identifier: "classicVestige",
            at: CGPoint(x: centerX, y: classicY)
        )
        addChild(classicButton!)

        // Sprint Mode Button
        sprintButton = fabricateModeCard(
            title: "SPRINT",
            subtitle: "Level up before time runs out!",
            breadth: buttonWidth,
            altitude: buttonHeight,
            palette: ChromaticPalette.recommenceGradient,
            identifier: "sprintVestige",
            at: CGPoint(x: centerX, y: sprintY)
        )
        addChild(sprintButton!)
    }

    private func fabricateModeCard(title: String, subtitle: String, breadth: CGFloat, altitude: CGFloat, palette: [UIColor], identifier: String, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = identifier
        container.position = position

        let cornerArc: CGFloat = 18
        let cardPath = UIBezierPath(
            roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude),
            cornerRadius: cornerArc
        )

        let background = SKShapeNode(path: cardPath.cgPath)
        background.fillColor = palette.first ?? ChromaticPalette.primaryAccent
        background.strokeColor = .clear
        background.glowWidth = 4
        background.name = identifier
        container.addChild(background)

        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = adaptiveFontScale(base: 20)
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 10)
        titleLabel.name = identifier
        container.addChild(titleLabel)

        let subtitleLabel = SKLabelNode(text: subtitle)
        subtitleLabel.fontName = "AvenirNext-Regular"
        subtitleLabel.fontSize = adaptiveFontScale(base: 11)
        subtitleLabel.fontColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: 0, y: -14)
        subtitleLabel.name = identifier
        container.addChild(subtitleLabel)

        let glowPulse = SKAction.sequence([
            SKAction.run { background.glowWidth = 7 },
            SKAction.wait(forDuration: 1.2),
            SKAction.run { background.glowWidth = 3 },
            SKAction.wait(forDuration: 1.2)
        ])
        background.run(SKAction.repeatForever(glowPulse))

        return container
    }

    // MARK: - Auxiliary Buttons

    private func composeAuxiliaryButtons() {
        let centerX = viewportDimensions.width / 2
        let metrics = layoutMetrics
        let buttonWidth: CGFloat = viewportDimensions.width * 0.65
        let auxiliaryY = metrics.auxiliaryY

        let smallWidth = (buttonWidth - 15) / 2
        let smallHeight = metrics.smallHeight

        pedagogueButton = fabricateAuxiliaryButton(
            inscription: "HOW TO PLAY",
            breadth: smallWidth,
            altitude: smallHeight,
            identifier: "pedagogueVestige",
            tint: ChromaticPalette.primaryAccent,
            at: CGPoint(x: centerX - smallWidth / 2 - 7.5, y: auxiliaryY)
        )
        addChild(pedagogueButton!)

        calibrationButton = fabricateAuxiliaryButton(
            inscription: "SETTINGS",
            breadth: smallWidth,
            altitude: smallHeight,
            identifier: "calibrationVestige",
            tint: ChromaticPalette.secondaryAccent,
            at: CGPoint(x: centerX + smallWidth / 2 + 7.5, y: auxiliaryY)
        )
        addChild(calibrationButton!)
    }

    private func fabricateAuxiliaryButton(inscription text: String, breadth: CGFloat, altitude: CGFloat, identifier: String, tint: UIColor, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = identifier
        container.position = position

        let cornerArc = altitude / 2
        let buttonPath = UIBezierPath(roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude), cornerRadius: cornerArc)

        let background = SKShapeNode(path: buttonPath.cgPath)
        background.fillColor = .clear
        background.strokeColor = tint.withAlphaComponent(0.4)
        background.lineWidth = 1.5
        background.glowWidth = 1
        background.name = identifier
        container.addChild(background)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Medium"
        label.fontSize = adaptiveFontScale(base: 13)
        label.fontColor = tint
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = identifier
        container.addChild(label)

        return container
    }

    // MARK: - Overlay Presentation

    private func unveilPedagogueParchment() {
        let parchment = PedagogueParchment(canvasExtent: viewportDimensions)
        parchment.position = CGPoint(x: viewportDimensions.width / 2, y: viewportDimensions.height / 2)
        parchment.zPosition = 1000
        addChild(parchment)
    }

    private func unveilCalibrationSanctum() {
        let sanctum = CalibrationSanctum(canvasExtent: viewportDimensions)
        sanctum.position = CGPoint(x: viewportDimensions.width / 2, y: viewportDimensions.height / 2)
        sanctum.zPosition = 1000
        sanctum.onDismiss = { [weak self] in
            self?.refreshApexDisplay()
        }
        addChild(sanctum)
    }

    private func refreshApexDisplay() {
        let apexValue = TallyLedger.sovereign.retrieveApexScore()
        apexScoreInscription.text = "\(apexValue)"
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        titleInscription.alpha = 0
        titleInscription.position.y += 30
        subtitleInscription.alpha = 0
        subtitleInscription.position.y += 30
        classicButton?.alpha = 0
        classicButton?.setScale(0.8)
        sprintButton?.alpha = 0
        sprintButton?.setScale(0.8)
        pedagogueButton?.alpha = 0
        pedagogueButton?.setScale(0.8)
        calibrationButton?.alpha = 0
        calibrationButton?.setScale(0.8)

        titleInscription.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.moveBy(x: 0, y: -30, duration: 0.5)
            ])
        ]))

        subtitleInscription.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.moveBy(x: 0, y: -30, duration: 0.5)
            ])
        ]))

        classicButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
        ]))

        sprintButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.85),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
        ]))

        pedagogueButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
        ]))

        calibrationButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
        ]))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if node.name == "classicVestige" {
                animateButtonPress(classicButton) {
                    self.transitionToArena(variant: .classicEndurance)
                }
                return
            }
            if node.name == "sprintVestige" {
                animateButtonPress(sprintButton) {
                    self.transitionToArena(variant: .chronoSprint)
                }
                return
            }
            if node.name == "pedagogueVestige" {
                animateButtonPress(pedagogueButton) {
                    self.unveilPedagogueParchment()
                }
                return
            }
            if node.name == "calibrationVestige" {
                animateButtonPress(calibrationButton) {
                    self.unveilCalibrationSanctum()
                }
                return
            }
        }
    }

    private func animateButtonPress(_ button: SKNode?, completion: @escaping () -> Void) {
        button?.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.08),
            SKAction.scale(to: 1.05, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.06),
            SKAction.run { completion() }
        ]))
    }

    private func transitionToArena(variant: ArenaVariant) {
        guard let skView = self.view else { return }
        let arenaScene = ArenaRealm(size: viewportDimensions, variant: variant)
        arenaScene.scaleMode = .resizeFill
        let transition = SKTransition.fade(withDuration: 0.6)
        skView.presentScene(arenaScene, transition: transition)
    }

    // MARK: - Adaptive Sizing

    private func adaptiveFontScale(base: CGFloat) -> CGFloat {
        let referenceWidth: CGFloat = 375
        let scaleFactor = viewportDimensions.width / referenceWidth
        return base * min(scaleFactor, 1.3)
    }
}
