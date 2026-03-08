import SpriteKit

final class PedagogueParchment: SKNode {

    private let canvasExtent: CGSize
    private let contentVessel = SKNode()
    private var folioPages: [SKNode] = []
    private var currentFolioIndex: Int = 0
    private var waypointDots: [SKShapeNode] = []
    private var priorArrow: SKNode?
    private var subsequentArrow: SKNode?
    var onDismiss: (() -> Void)?

    private let folioCount = 4

    init(canvasExtent: CGSize) {
        self.canvasExtent = canvasExtent
        super.init()
        self.zPosition = CosmicConstants.Stratum.overlayLayer.rawValue
        self.isUserInteractionEnabled = true
        assembleVeil()
        composeParchmentContent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Fabrication

    private func assembleVeil() {
        let veilNode = SKShapeNode(rectOf: CGSize(width: canvasExtent.width * 2, height: canvasExtent.height * 2))
        veilNode.fillColor = ChromaticPalette.overlayVeil
        veilNode.strokeColor = .clear
        veilNode.zPosition = -1
        addChild(veilNode)
    }

    private func composeParchmentContent() {
        let panelWidth = canvasExtent.width * 0.85
        let panelHeight = canvasExtent.height * 0.60

        let panel = fabricatePanel(width: panelWidth, height: panelHeight)
        contentVessel.addChild(panel)

        // Close button
        let closeButton = fabricateCloseButton(identifier: "dismissParchmentVestige")
        closeButton.position = CGPoint(x: panelWidth / 2 - 30, y: panelHeight / 2 - 30)
        contentVessel.addChild(closeButton)

        // Build folios
        folioPages = [
            composeDoctrineFollio(panelWidth: panelWidth, panelHeight: panelHeight),
            composeNavigationFollio(panelWidth: panelWidth, panelHeight: panelHeight),
            composeAcumenFollio(panelWidth: panelWidth, panelHeight: panelHeight),
            composeSprintFollio(panelWidth: panelWidth, panelHeight: panelHeight)
        ]

        for (index, folio) in folioPages.enumerated() {
            folio.alpha = index == 0 ? 1.0 : 0.0
            contentVessel.addChild(folio)
        }

        // Waypoint dots
        composeWaypointIndicators(panelHeight: panelHeight)

        // Navigation arrows
        composeNavigationArrows(panelWidth: panelWidth, panelHeight: panelHeight)

        addChild(contentVessel)

        // Entrance Animation
        contentVessel.setScale(0.5)
        contentVessel.alpha = 0
        let expandAction = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)
        ])
        expandAction.timingMode = .easeOut
        contentVessel.run(expandAction)

        refreshNavigationState()
    }

    // MARK: - Folio 1: Devour Doctrine

    private func composeDoctrineFollio(panelWidth: CGFloat, panelHeight: CGFloat) -> SKNode {
        let folio = SKNode()
        let contentTop = panelHeight / 2 - 55

        let title = fabricateInscription(text: "DEVOUR DOCTRINE", fontSize: 22, fontWeight: .bold, tint: ChromaticPalette.primaryAccent)
        title.position = CGPoint(x: 0, y: contentTop)
        folio.addChild(title)

        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth * 0.5, height: 1.5))
        divider.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: contentTop - 22)
        folio.addChild(divider)

        // Rule 1: Smaller = Engulf + Score
        let rule1Y = contentTop - 70
        composeRuleRow(
            in: folio,
            playerEchelon: 3,
            targetEchelon: 1,
            resultIcon: "checkmark",
            resultColor: ChromaticPalette.affirmativeHue,
            description: "Engulf smaller orbs\nfor points",
            at: CGPoint(x: 0, y: rule1Y),
            panelWidth: panelWidth
        )

        // Rule 2: Equal = Merge + Level Up
        let rule2Y = rule1Y - 80
        composeRuleRow(
            in: folio,
            playerEchelon: 3,
            targetEchelon: 3,
            resultIcon: "levelup",
            resultColor: ChromaticPalette.primaryAccent,
            description: "Merge equals to\nascend one level",
            at: CGPoint(x: 0, y: rule2Y),
            panelWidth: panelWidth
        )

        // Rule 3: Larger = Death
        let rule3Y = rule2Y - 80
        composeRuleRow(
            in: folio,
            playerEchelon: 3,
            targetEchelon: 5,
            resultIcon: "explosion",
            resultColor: ChromaticPalette.cautionaryHue,
            description: "Collide with larger\n= annihilation",
            at: CGPoint(x: 0, y: rule3Y),
            panelWidth: panelWidth
        )

        return folio
    }

    private func composeRuleRow(in parent: SKNode, playerEchelon: Int, targetEchelon: Int, resultIcon: String, resultColor: UIColor, description: String, at position: CGPoint, panelWidth: CGFloat) {
        let rowWidth = panelWidth * 0.8

        // Player orb
        let playerRadius: CGFloat = 18
        let playerOrb = SKShapeNode(circleOfRadius: playerRadius)
        playerOrb.fillColor = ChromaticPalette.hueForEchelon(playerEchelon)
        playerOrb.strokeColor = ChromaticPalette.hueForEchelon(playerEchelon).withAlphaComponent(0.4)
        playerOrb.lineWidth = 1
        playerOrb.position = CGPoint(x: -rowWidth / 2 + 30, y: position.y)
        parent.addChild(playerOrb)

        let playerValue = EchelonBlueprint.retrieveBlueprint(forEchelon: playerEchelon).numericVisage
        let playerLabel = fabricateInscription(text: "\(playerValue)", fontSize: 11, fontWeight: .bold, tint: .white)
        playerLabel.position = playerOrb.position
        parent.addChild(playerLabel)

        // Arrow
        let arrowLabel = fabricateInscription(text: "→", fontSize: 20, fontWeight: .bold, tint: resultColor)
        arrowLabel.position = CGPoint(x: -rowWidth / 2 + 70, y: position.y)
        parent.addChild(arrowLabel)

        // Target orb
        let targetRadius: CGFloat = targetEchelon > playerEchelon ? 24 : (targetEchelon == playerEchelon ? 18 : 13)
        let targetOrb = SKShapeNode(circleOfRadius: targetRadius)
        targetOrb.fillColor = ChromaticPalette.hueForEchelon(targetEchelon)
        targetOrb.strokeColor = ChromaticPalette.hueForEchelon(targetEchelon).withAlphaComponent(0.4)
        targetOrb.lineWidth = 1
        targetOrb.position = CGPoint(x: -rowWidth / 2 + 110, y: position.y)
        parent.addChild(targetOrb)

        let targetValue = EchelonBlueprint.retrieveBlueprint(forEchelon: targetEchelon).numericVisage
        let targetLabel = fabricateInscription(text: "\(targetValue)", fontSize: targetEchelon > playerEchelon ? 11 : 9, fontWeight: .bold, tint: .white)
        targetLabel.position = targetOrb.position
        parent.addChild(targetLabel)

        // Result icon
        let iconLabel: SKLabelNode
        if resultIcon == "checkmark" {
            iconLabel = fabricateInscription(text: "✓", fontSize: 22, fontWeight: .bold, tint: resultColor)
        } else if resultIcon == "levelup" {
            iconLabel = fabricateInscription(text: "↑", fontSize: 22, fontWeight: .bold, tint: resultColor)
        } else {
            iconLabel = fabricateInscription(text: "✕", fontSize: 22, fontWeight: .bold, tint: resultColor)
        }
        iconLabel.position = CGPoint(x: -rowWidth / 2 + 150, y: position.y)
        parent.addChild(iconLabel)

        // Description
        let lines = description.components(separatedBy: "\n")
        for (i, line) in lines.enumerated() {
            let desc = fabricateInscription(text: line, fontSize: 13, fontWeight: .regular, tint: ChromaticPalette.inscriptionHue.withAlphaComponent(0.85))
            desc.horizontalAlignmentMode = .left
            desc.position = CGPoint(x: -rowWidth / 2 + 175, y: position.y + CGFloat(8 - i * 18))
            parent.addChild(desc)
        }
    }

    // MARK: - Folio 2: Navigation Helm

    private func composeNavigationFollio(panelWidth: CGFloat, panelHeight: CGFloat) -> SKNode {
        let folio = SKNode()
        let contentTop = panelHeight / 2 - 55

        let title = fabricateInscription(text: "NAVIGATION HELM", fontSize: 22, fontWeight: .bold, tint: ChromaticPalette.primaryAccent)
        title.position = CGPoint(x: 0, y: contentTop)
        folio.addChild(title)

        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth * 0.5, height: 1.5))
        divider.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: contentTop - 22)
        folio.addChild(divider)

        // Joystick illustration
        let joystickY: CGFloat = contentTop - 120

        let outerRing = SKShapeNode(circleOfRadius: 50)
        outerRing.fillColor = UIColor.white.withAlphaComponent(0.05)
        outerRing.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.4)
        outerRing.lineWidth = 2
        outerRing.position = CGPoint(x: 0, y: joystickY)
        folio.addChild(outerRing)

        let innerKnob = SKShapeNode(circleOfRadius: 20)
        innerKnob.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.5)
        innerKnob.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.6)
        innerKnob.lineWidth = 1.5
        innerKnob.position = CGPoint(x: 15, y: joystickY + 10)
        folio.addChild(innerKnob)

        // Direction arrows
        let arrowDirections: [(String, CGPoint)] = [
            ("↑", CGPoint(x: 0, y: joystickY + 70)),
            ("↓", CGPoint(x: 0, y: joystickY - 70)),
            ("←", CGPoint(x: -70, y: joystickY)),
            ("→", CGPoint(x: 70, y: joystickY))
        ]
        for (arrow, pos) in arrowDirections {
            let arrowNode = fabricateInscription(text: arrow, fontSize: 18, fontWeight: .medium, tint: ChromaticPalette.primaryAccent.withAlphaComponent(0.5))
            arrowNode.position = pos
            folio.addChild(arrowNode)
        }

        let desc1 = fabricateInscription(text: "Drag the helm to steer", fontSize: 15, fontWeight: .medium, tint: ChromaticPalette.inscriptionHue)
        desc1.position = CGPoint(x: 0, y: joystickY - 100)
        folio.addChild(desc1)

        let desc2 = fabricateInscription(text: "your celestial orb", fontSize: 15, fontWeight: .medium, tint: ChromaticPalette.inscriptionHue.withAlphaComponent(0.7))
        desc2.position = CGPoint(x: 0, y: joystickY - 122)
        folio.addChild(desc2)

        let desc3 = fabricateInscription(text: "Higher levels move slower", fontSize: 13, fontWeight: .regular, tint: ChromaticPalette.secondaryAccent.withAlphaComponent(0.8))
        desc3.position = CGPoint(x: 0, y: joystickY - 155)
        folio.addChild(desc3)

        return folio
    }

    // MARK: - Folio 3: Acumen Calculus

    private func composeAcumenFollio(panelWidth: CGFloat, panelHeight: CGFloat) -> SKNode {
        let folio = SKNode()
        let contentTop = panelHeight / 2 - 55

        let title = fabricateInscription(text: "ACUMEN CALCULUS", fontSize: 22, fontWeight: .bold, tint: ChromaticPalette.secondaryAccent)
        title.position = CGPoint(x: 0, y: contentTop)
        folio.addChild(title)

        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth * 0.5, height: 1.5))
        divider.fillColor = ChromaticPalette.secondaryAccent.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: contentTop - 22)
        folio.addChild(divider)

        // Formula
        let formulaY = contentTop - 75

        let formulaLabel = fabricateInscription(text: "SCORE  =  KILLS  ×  LEVEL", fontSize: 20, fontWeight: .bold, tint: ChromaticPalette.inscriptionHue)
        formulaLabel.position = CGPoint(x: 0, y: formulaY)
        folio.addChild(formulaLabel)

        // Decorative box around formula
        let boxWidth: CGFloat = panelWidth * 0.75
        let boxHeight: CGFloat = 44
        let boxPath = UIBezierPath(roundedRect: CGRect(x: -boxWidth / 2, y: -boxHeight / 2, width: boxWidth, height: boxHeight), cornerRadius: 10)
        let formulaBox = SKShapeNode(path: boxPath.cgPath)
        formulaBox.fillColor = .clear
        formulaBox.strokeColor = ChromaticPalette.secondaryAccent.withAlphaComponent(0.3)
        formulaBox.lineWidth = 1.5
        formulaBox.position = CGPoint(x: 0, y: formulaY)
        folio.addChild(formulaBox)

        // Example
        let exampleY = formulaY - 70

        let exampleTitle = fabricateInscription(text: "EXAMPLE", fontSize: 14, fontWeight: .medium, tint: ChromaticPalette.primaryAccent.withAlphaComponent(0.7))
        exampleTitle.position = CGPoint(x: 0, y: exampleY + 20)
        folio.addChild(exampleTitle)

        let example1 = fabricateInscription(text: "Engulf 10 orbs at Level 5", fontSize: 15, fontWeight: .regular, tint: ChromaticPalette.inscriptionHue.withAlphaComponent(0.85))
        example1.position = CGPoint(x: 0, y: exampleY - 8)
        folio.addChild(example1)

        let example2 = fabricateInscription(text: "10 × 5 = 50 points", fontSize: 18, fontWeight: .bold, tint: ChromaticPalette.secondaryAccent)
        example2.position = CGPoint(x: 0, y: exampleY - 38)
        folio.addChild(example2)

        // Tip
        let tipY = exampleY - 90
        let tip = fabricateInscription(text: "Ascend quickly to multiply score!", fontSize: 14, fontWeight: .medium, tint: ChromaticPalette.affirmativeHue.withAlphaComponent(0.8))
        tip.position = CGPoint(x: 0, y: tipY)
        folio.addChild(tip)

        return folio
    }

    // MARK: - Folio 4: Chrono Sprint

    private func composeSprintFollio(panelWidth: CGFloat, panelHeight: CGFloat) -> SKNode {
        let folio = SKNode()
        let contentTop = panelHeight / 2 - 55

        let title = fabricateInscription(text: "CHRONO SPRINT", fontSize: 22, fontWeight: .bold, tint: ChromaticPalette.tertiaryAccent)
        title.position = CGPoint(x: 0, y: contentTop)
        folio.addChild(title)

        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth * 0.5, height: 1.5))
        divider.fillColor = ChromaticPalette.tertiaryAccent.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: contentTop - 22)
        folio.addChild(divider)

        // Timer illustration
        let timerY = contentTop - 85
        let arcRadius: CGFloat = 35

        let trackArc = UIBezierPath(arcCenter: .zero, radius: arcRadius, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)
        let trackNode = SKShapeNode(path: trackArc.cgPath)
        trackNode.strokeColor = UIColor.white.withAlphaComponent(0.1)
        trackNode.lineWidth = 5
        trackNode.fillColor = .clear
        trackNode.lineCap = .round
        trackNode.position = CGPoint(x: 0, y: timerY)
        folio.addChild(trackNode)

        let progressArc = UIBezierPath(arcCenter: .zero, radius: arcRadius, startAngle: -.pi / 2, endAngle: .pi * 0.7, clockwise: true)
        let progressNode = SKShapeNode(path: progressArc.cgPath)
        progressNode.strokeColor = ChromaticPalette.affirmativeHue
        progressNode.lineWidth = 5
        progressNode.fillColor = .clear
        progressNode.lineCap = .round
        progressNode.glowWidth = 2
        progressNode.position = CGPoint(x: 0, y: timerY)
        folio.addChild(progressNode)

        let timerLabel = fabricateInscription(text: "5.0", fontSize: 18, fontWeight: .bold, tint: ChromaticPalette.inscriptionHue)
        timerLabel.position = CGPoint(x: 0, y: timerY)
        folio.addChild(timerLabel)

        // Rules
        let rulesY = timerY - 65

        let ruleLines: [(String, UIColor)] = [
            ("Start with 5.0 seconds", ChromaticPalette.inscriptionHue),
            ("Ascend to reset timer", ChromaticPalette.affirmativeHue),
            ("+1.5s bonus per level", ChromaticPalette.primaryAccent),
            ("Time out = annihilation", ChromaticPalette.cautionaryHue)
        ]

        for (i, (text, color)) in ruleLines.enumerated() {
            let bullet = fabricateInscription(text: "●", fontSize: 8, fontWeight: .bold, tint: color)
            bullet.horizontalAlignmentMode = .left
            bullet.position = CGPoint(x: -panelWidth * 0.3, y: rulesY - CGFloat(i * 28))
            folio.addChild(bullet)

            let ruleText = fabricateInscription(text: text, fontSize: 14, fontWeight: .medium, tint: color.withAlphaComponent(0.9))
            ruleText.horizontalAlignmentMode = .left
            ruleText.position = CGPoint(x: -panelWidth * 0.3 + 18, y: rulesY - CGFloat(i * 28))
            folio.addChild(ruleText)
        }

        return folio
    }

    // MARK: - Navigation

    private func composeWaypointIndicators(panelHeight: CGFloat) {
        let dotSpacing: CGFloat = 18
        let dotsY = -panelHeight / 2 + 35

        for i in 0..<folioCount {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.fillColor = i == 0 ? ChromaticPalette.primaryAccent : UIColor.white.withAlphaComponent(0.2)
            dot.strokeColor = .clear
            let xOffset = CGFloat(i - folioCount / 2) * dotSpacing + (folioCount % 2 == 0 ? dotSpacing / 2 : 0)
            dot.position = CGPoint(x: xOffset, y: dotsY)
            contentVessel.addChild(dot)
            waypointDots.append(dot)
        }
    }

    private func composeNavigationArrows(panelWidth: CGFloat, panelHeight: CGFloat) {
        let arrowY = -panelHeight / 2 + 35

        let prior = fabricateArrowButton(direction: "‹", identifier: "priorFolioVestige")
        prior.position = CGPoint(x: -panelWidth / 2 + 35, y: arrowY)
        contentVessel.addChild(prior)
        priorArrow = prior

        let subsequent = fabricateArrowButton(direction: "›", identifier: "subsequentFolioVestige")
        subsequent.position = CGPoint(x: panelWidth / 2 - 35, y: arrowY)
        contentVessel.addChild(subsequent)
        subsequentArrow = subsequent
    }

    private func fabricateArrowButton(direction: String, identifier: String) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let bg = SKShapeNode(circleOfRadius: 16)
        bg.fillColor = UIColor.white.withAlphaComponent(0.05)
        bg.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        bg.lineWidth = 1
        bg.name = identifier
        container.addChild(bg)

        let label = fabricateInscription(text: direction, fontSize: 22, fontWeight: .bold, tint: ChromaticPalette.primaryAccent)
        label.name = identifier
        container.addChild(label)

        return container
    }

    private func fabricateCloseButton(identifier: String) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let bg = SKShapeNode(circleOfRadius: 14)
        bg.fillColor = UIColor.white.withAlphaComponent(0.05)
        bg.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        bg.lineWidth = 1
        bg.name = identifier
        container.addChild(bg)

        let label = fabricateInscription(text: "✕", fontSize: 14, fontWeight: .bold, tint: ChromaticPalette.primaryAccent)
        label.name = identifier
        container.addChild(label)

        return container
    }

    private func navigateToFolio(index: Int) {
        guard index >= 0, index < folioCount, index != currentFolioIndex else { return }

        let oldFolio = folioPages[currentFolioIndex]
        let newFolio = folioPages[index]

        oldFolio.run(SKAction.fadeOut(withDuration: 0.2))
        newFolio.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.fadeIn(withDuration: 0.2)
        ]))

        currentFolioIndex = index
        refreshNavigationState()
    }

    private func refreshNavigationState() {
        for (i, dot) in waypointDots.enumerated() {
            dot.fillColor = i == currentFolioIndex ? ChromaticPalette.primaryAccent : UIColor.white.withAlphaComponent(0.2)
        }
        priorArrow?.alpha = currentFolioIndex > 0 ? 1.0 : 0.3
        subsequentArrow?.alpha = currentFolioIndex < folioCount - 1 ? 1.0 : 0.3
    }

    // MARK: - Fabrication Helpers

    private func fabricatePanel(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let cornerArc: CGFloat = 24
        let panelPath = UIBezierPath(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: cornerArc)
        let panel = SKShapeNode(path: panelPath.cgPath)
        panel.fillColor = ChromaticPalette.interfaceCanvas
        panel.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        panel.lineWidth = 1.5
        panel.glowWidth = 2
        return panel
    }

    private func fabricateInscription(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular, tint: UIColor = ChromaticPalette.inscriptionHue) -> SKLabelNode {
        let inscription = SKLabelNode(text: text)
        inscription.fontName = fontWeight == .bold ? "AvenirNext-Bold" : (fontWeight == .medium ? "AvenirNext-Medium" : "AvenirNext-Regular")
        inscription.fontSize = fontSize
        inscription.fontColor = tint
        inscription.verticalAlignmentMode = .center
        inscription.horizontalAlignmentMode = .center
        return inscription
    }

    // MARK: - Interaction

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if node.name == "dismissParchmentVestige" {
                animateDismissal()
                return
            }
            if node.name == "priorFolioVestige" && currentFolioIndex > 0 {
                navigateToFolio(index: currentFolioIndex - 1)
                return
            }
            if node.name == "subsequentFolioVestige" && currentFolioIndex < folioCount - 1 {
                navigateToFolio(index: currentFolioIndex + 1)
                return
            }
        }
    }

    private func animateDismissal() {
        let shrinkAction = SKAction.group([
            SKAction.scale(to: 0.5, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2)
        ])
        shrinkAction.timingMode = .easeIn
        contentVessel.run(shrinkAction) { [weak self] in
            self?.onDismiss?()
            self?.removeFromParent()
        }
    }
}
