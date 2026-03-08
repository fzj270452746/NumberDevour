import SpriteKit

final class CalibrationSanctum: SKNode {

    private let canvasExtent: CGSize
    private let contentVessel = SKNode()
    private var confirmationVessel: SKNode?
    var onDismiss: (() -> Void)?

    init(canvasExtent: CGSize) {
        self.canvasExtent = canvasExtent
        super.init()
        self.zPosition = CosmicConstants.Stratum.overlayLayer.rawValue
        self.isUserInteractionEnabled = true
        assembleVeil()
        composeSanctumContent()
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

    private func composeSanctumContent() {
        let panelWidth = canvasExtent.width * 0.78
        let panelHeight: CGFloat = 380

        let panel = fabricatePanel(width: panelWidth, height: panelHeight)
        contentVessel.addChild(panel)

        // Title
        let headline = fabricateInscription(
            text: "CALIBRATION",
            fontSize: 28,
            fontWeight: .bold,
            tint: ChromaticPalette.primaryAccent
        )
        headline.position = CGPoint(x: 0, y: panelHeight / 2 - 45)
        contentVessel.addChild(headline)

        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth * 0.7, height: 1.5))
        divider.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: panelHeight / 2 - 70)
        contentVessel.addChild(divider)

        // Resonance Toggle
        let resonanceRow = fabricateToggleRow(
            label: "RESONANCE",
            identifier: "resonanceToggleVestige",
            isOn: PredicationVault.sovereign.isResonanceEnabled,
            at: CGPoint(x: 0, y: 60)
        )
        contentVessel.addChild(resonanceRow)

        // Sonorus Toggle
        let sonorusRow = fabricateToggleRow(
            label: "SONORUS",
            identifier: "sonorusToggleVestige",
            isOn: PredicationVault.sovereign.isSonorusEnabled,
            at: CGPoint(x: 0, y: 0)
        )
        contentVessel.addChild(sonorusRow)

        // Expunge Records Button
        let expungeButton = fabricateOutlineButton(
            inscription: "EXPUNGE RECORDS",
            breadth: panelWidth * 0.6,
            altitude: 42,
            identifier: "expungeRecordsVestige",
            tint: ChromaticPalette.cautionaryHue
        )
        expungeButton.position = CGPoint(x: 0, y: -70)
        contentVessel.addChild(expungeButton)

        // Close Button
        let closeButton = fabricateOutlineButton(
            inscription: "CLOSE",
            breadth: panelWidth * 0.5,
            altitude: 40,
            identifier: "dismissSanctumVestige",
            tint: ChromaticPalette.primaryAccent
        )
        closeButton.position = CGPoint(x: 0, y: -130)
        contentVessel.addChild(closeButton)

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
    }

    // MARK: - Toggle Row

    private func fabricateToggleRow(label text: String, identifier: String, isOn: Bool, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position

        let panelWidth = canvasExtent.width * 0.78
        let rowWidth = panelWidth * 0.7

        let label = fabricateInscription(text: text, fontSize: 17, fontWeight: .medium, tint: ChromaticPalette.inscriptionHue)
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: -rowWidth / 2, y: 0)
        container.addChild(label)

        let toggleNode = fabricateToggleSwitch(identifier: identifier, isOn: isOn)
        toggleNode.position = CGPoint(x: rowWidth / 2 - 20, y: 0)
        container.addChild(toggleNode)

        return container
    }

    private func fabricateToggleSwitch(identifier: String, isOn: Bool) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let trackWidth: CGFloat = 44
        let trackHeight: CGFloat = 24
        let knobDiameter: CGFloat = 20

        let trackPath = UIBezierPath(roundedRect: CGRect(x: -trackWidth / 2, y: -trackHeight / 2, width: trackWidth, height: trackHeight), cornerRadius: trackHeight / 2)
        let track = SKShapeNode(path: trackPath.cgPath)
        track.fillColor = isOn ? ChromaticPalette.affirmativeHue : UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        track.strokeColor = .clear
        track.name = identifier
        container.addChild(track)

        let knob = SKShapeNode(circleOfRadius: knobDiameter / 2)
        knob.fillColor = .white
        knob.strokeColor = .clear
        knob.name = identifier
        knob.position = CGPoint(x: isOn ? (trackWidth / 2 - knobDiameter / 2 - 2) : (-trackWidth / 2 + knobDiameter / 2 + 2), y: 0)
        container.addChild(knob)

        container.userData = NSMutableDictionary()
        container.userData?["isOn"] = isOn

        return container
    }

    private func animateToggle(toggleNode: SKNode) {
        guard let isOn = toggleNode.userData?["isOn"] as? Bool else { return }
        let newState = !isOn
        toggleNode.userData?["isOn"] = newState

        let trackWidth: CGFloat = 44
        let knobDiameter: CGFloat = 20

        let track = toggleNode.children.compactMap { $0 as? SKShapeNode }.first { $0.path != nil && $0.frame.width > 30 }
        let knob = toggleNode.children.compactMap { $0 as? SKShapeNode }.first { $0.frame.width < 25 }

        let targetX = newState ? (trackWidth / 2 - knobDiameter / 2 - 2) : (-trackWidth / 2 + knobDiameter / 2 + 2)
        let targetColor = newState ? ChromaticPalette.affirmativeHue : UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)

        knob?.run(SKAction.moveTo(x: targetX, duration: 0.15))
        track?.fillColor = targetColor

        if toggleNode.name == "resonanceToggleVestige" {
            PredicationVault.sovereign.isResonanceEnabled = newState
        } else if toggleNode.name == "sonorusToggleVestige" {
            PredicationVault.sovereign.isSonorusEnabled = newState
        }
    }

    // MARK: - Confirmation

    private func presentExpungeConfirmation() {
        confirmationVessel?.removeFromParent()

        let vessel = SKNode()
        vessel.zPosition = 10

        let overlayBg = SKShapeNode(rectOf: CGSize(width: canvasExtent.width * 2, height: canvasExtent.height * 2))
        overlayBg.fillColor = UIColor.black.withAlphaComponent(0.5)
        overlayBg.strokeColor = .clear
        overlayBg.name = "confirmOverlayBg"
        vessel.addChild(overlayBg)

        let confirmWidth: CGFloat = canvasExtent.width * 0.65
        let confirmHeight: CGFloat = 180
        let confirmPanel = fabricatePanel(width: confirmWidth, height: confirmHeight)
        vessel.addChild(confirmPanel)

        let warningLabel = fabricateInscription(
            text: "ERASE ALL RECORDS?",
            fontSize: 18,
            fontWeight: .bold,
            tint: ChromaticPalette.cautionaryHue
        )
        warningLabel.position = CGPoint(x: 0, y: 40)
        vessel.addChild(warningLabel)

        let confirmButton = fabricateGradientButton(
            inscription: "CONFIRM",
            breadth: confirmWidth * 0.5,
            altitude: 38,
            palette: [ChromaticPalette.cautionaryHue],
            identifier: "confirmExpungeVestige"
        )
        confirmButton.position = CGPoint(x: 0, y: -10)
        vessel.addChild(confirmButton)

        let annulButton = fabricateOutlineButton(
            inscription: "ANNUL",
            breadth: confirmWidth * 0.5,
            altitude: 36,
            identifier: "annulExpungeVestige",
            tint: ChromaticPalette.primaryAccent
        )
        annulButton.position = CGPoint(x: 0, y: -55)
        vessel.addChild(annulButton)

        contentVessel.addChild(vessel)
        confirmationVessel = vessel

        vessel.setScale(0.8)
        vessel.alpha = 0
        vessel.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.fadeIn(withDuration: 0.2)
        ]))
    }

    private func dismissConfirmation() {
        confirmationVessel?.run(SKAction.group([
            SKAction.scale(to: 0.8, duration: 0.15),
            SKAction.fadeOut(withDuration: 0.15)
        ])) { [weak self] in
            self?.confirmationVessel?.removeFromParent()
            self?.confirmationVessel = nil
        }
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

    private func fabricateGradientButton(inscription text: String, breadth: CGFloat, altitude: CGFloat, palette: [UIColor], identifier: String) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let cornerArc = altitude / 2
        let buttonPath = UIBezierPath(roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude), cornerRadius: cornerArc)

        let background = SKShapeNode(path: buttonPath.cgPath)
        background.fillColor = palette.first ?? ChromaticPalette.primaryAccent
        background.strokeColor = .clear
        background.glowWidth = 3
        background.name = identifier
        container.addChild(background)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = identifier
        container.addChild(label)

        return container
    }

    private func fabricateOutlineButton(inscription text: String, breadth: CGFloat, altitude: CGFloat, identifier: String, tint: UIColor = ChromaticPalette.primaryAccent) -> SKNode {
        let container = SKNode()
        container.name = identifier

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
        label.fontSize = 15
        label.fontColor = tint
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = identifier
        container.addChild(label)

        return container
    }

    // MARK: - Interaction

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if node.name == "resonanceToggleVestige" {
                if let toggleNode = findToggleAncestor(node: node) {
                    animateToggle(toggleNode: toggleNode)
                }
                return
            }
            if node.name == "sonorusToggleVestige" {
                if let toggleNode = findToggleAncestor(node: node) {
                    animateToggle(toggleNode: toggleNode)
                }
                return
            }
            if node.name == "expungeRecordsVestige" {
                presentExpungeConfirmation()
                return
            }
            if node.name == "confirmExpungeVestige" {
                PredicationVault.sovereign.expungeAllApexRecords()
                dismissConfirmation()
                return
            }
            if node.name == "annulExpungeVestige" {
                dismissConfirmation()
                return
            }
            if node.name == "dismissSanctumVestige" {
                animateDismissal()
                return
            }
        }
    }

    private func findToggleAncestor(node: SKNode) -> SKNode? {
        var current: SKNode? = node
        while let candidate = current {
            if candidate.userData?["isOn"] != nil {
                return candidate
            }
            current = candidate.parent
        }
        return nil
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
