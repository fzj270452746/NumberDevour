import SpriteKit

final class EpilogueVista: SKNode {

    var onRecommence: (() -> Void)?
    var onReturnToGateway: (() -> Void)?

    private let canvasExtent: CGSize
    private let finalScore: Int
    private let apexScore: Int
    private let isNewApex: Bool
    private let contentVessel = SKNode()

    init(canvasExtent: CGSize, finalScore: Int, apexScore: Int, isNewApex: Bool) {
        self.canvasExtent = canvasExtent
        self.finalScore = finalScore
        self.apexScore = apexScore
        self.isNewApex = isNewApex
        super.init()
        self.zPosition = CosmicConstants.Stratum.overlayLayer.rawValue
        self.isUserInteractionEnabled = true
        composeVista()
        animateEntrance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Composition

    private func composeVista() {
        let veil = SKShapeNode(rectOf: CGSize(width: canvasExtent.width * 3, height: canvasExtent.height * 3))
        veil.fillColor = ChromaticPalette.overlayVeil
        veil.strokeColor = .clear
        veil.zPosition = -1
        addChild(veil)

        let panelWidth: CGFloat = canvasExtent.width * 0.78
        let panelHeight: CGFloat = 420

        let panel = fabricatePanel(width: panelWidth, height: panelHeight)
        contentVessel.addChild(panel)

        // Game Over Title
        let gameOverLabel = fabricateInscription(
            text: "GAME OVER",
            fontSize: 36,
            fontWeight: .bold,
            tint: ChromaticPalette.cautionaryHue
        )
        gameOverLabel.position = CGPoint(x: 0, y: 140)
        contentVessel.addChild(gameOverLabel)

        let divider1 = fabricateDivider(width: panelWidth * 0.5)
        divider1.position = CGPoint(x: 0, y: 110)
        contentVessel.addChild(divider1)

        // Score Section
        let scoreHeadline = fabricateInscription(
            text: "SCORE",
            fontSize: 14,
            fontWeight: .medium,
            tint: ChromaticPalette.primaryAccent.withAlphaComponent(0.7)
        )
        scoreHeadline.position = CGPoint(x: 0, y: 85)
        contentVessel.addChild(scoreHeadline)

        let scoreValue = fabricateInscription(
            text: "\(finalScore)",
            fontSize: 48,
            fontWeight: .bold,
            tint: ChromaticPalette.inscriptionHue
        )
        scoreValue.position = CGPoint(x: 0, y: 48)
        contentVessel.addChild(scoreValue)

        // New Record Badge
        if isNewApex {
            let recordBadge = fabricateRecordBadge()
            recordBadge.position = CGPoint(x: 0, y: 10)
            contentVessel.addChild(recordBadge)
        }

        // Best Score
        let bestLabel = fabricateInscription(
            text: "BEST",
            fontSize: 13,
            fontWeight: .medium,
            tint: ChromaticPalette.secondaryAccent.withAlphaComponent(0.6)
        )
        bestLabel.position = CGPoint(x: 0, y: -15)
        contentVessel.addChild(bestLabel)

        let bestValue = fabricateInscription(
            text: "\(apexScore)",
            fontSize: 26,
            fontWeight: .bold,
            tint: ChromaticPalette.secondaryAccent
        )
        bestValue.position = CGPoint(x: 0, y: -42)
        contentVessel.addChild(bestValue)

        let divider2 = fabricateDivider(width: panelWidth * 0.5)
        divider2.position = CGPoint(x: 0, y: -65)
        contentVessel.addChild(divider2)

        // Buttons
        let recommenceButton = fabricateGradientButton(
            inscription: "PLAY AGAIN",
            breadth: panelWidth * 0.65,
            altitude: 50,
            palette: ChromaticPalette.recommenceGradient,
            identifier: "recommenceVestige"
        )
        recommenceButton.position = CGPoint(x: 0, y: -105)
        contentVessel.addChild(recommenceButton)

        let gatewayButton = fabricateOutlineButton(
            inscription: "MAIN MENU",
            breadth: panelWidth * 0.65,
            altitude: 44,
            identifier: "gatewayVestige"
        )
        gatewayButton.position = CGPoint(x: 0, y: -165)
        contentVessel.addChild(gatewayButton)

        addChild(contentVessel)
    }

    // MARK: - Fabrication Helpers

    private func fabricatePanel(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = UIBezierPath(
            roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height),
            cornerRadius: 24
        )
        let panel = SKShapeNode(path: path.cgPath)
        panel.fillColor = ChromaticPalette.interfaceCanvas
        panel.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.2)
        panel.lineWidth = 1.5
        panel.glowWidth = 3
        return panel
    }

    private func fabricateInscription(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight, tint: UIColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        switch fontWeight {
        case .bold:
            label.fontName = "AvenirNext-Bold"
        case .medium:
            label.fontName = "AvenirNext-Medium"
        case .heavy:
            label.fontName = "AvenirNext-Heavy"
        default:
            label.fontName = "AvenirNext-Regular"
        }
        label.fontSize = fontSize
        label.fontColor = tint
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }

    private func fabricateDivider(width: CGFloat) -> SKShapeNode {
        let divider = SKShapeNode(rectOf: CGSize(width: width, height: 1))
        divider.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.2)
        divider.strokeColor = .clear
        return divider
    }

    private func fabricateRecordBadge() -> SKNode {
        let container = SKNode()

        let badgePath = UIBezierPath(roundedRect: CGRect(x: -55, y: -12, width: 110, height: 24), cornerRadius: 12)
        let badge = SKShapeNode(path: badgePath.cgPath)
        badge.fillColor = ChromaticPalette.affirmativeHue.withAlphaComponent(0.2)
        badge.strokeColor = ChromaticPalette.affirmativeHue.withAlphaComponent(0.5)
        badge.lineWidth = 1
        badge.glowWidth = 2
        container.addChild(badge)

        let label = SKLabelNode(text: "NEW RECORD!")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 12
        label.fontColor = ChromaticPalette.affirmativeHue
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    private func fabricateGradientButton(inscription text: String, breadth: CGFloat, altitude: CGFloat, palette: [UIColor], identifier: String) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let cornerArc: CGFloat = altitude / 2
        let path = UIBezierPath(
            roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude),
            cornerRadius: cornerArc
        )

        let bg = SKShapeNode(path: path.cgPath)
        bg.fillColor = palette.first ?? ChromaticPalette.primaryAccent
        bg.strokeColor = .clear
        bg.glowWidth = 4
        bg.name = identifier
        container.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = identifier
        container.addChild(label)

        return container
    }

    private func fabricateOutlineButton(inscription text: String, breadth: CGFloat, altitude: CGFloat, identifier: String) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let cornerArc: CGFloat = altitude / 2
        let path = UIBezierPath(
            roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude),
            cornerRadius: cornerArc
        )

        let bg = SKShapeNode(path: path.cgPath)
        bg.fillColor = .clear
        bg.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.4)
        bg.lineWidth = 1.5
        bg.glowWidth = 1
        bg.name = identifier
        container.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Medium"
        label.fontSize = 16
        label.fontColor = ChromaticPalette.primaryAccent
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = identifier
        container.addChild(label)

        return container
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        contentVessel.setScale(0.5)
        contentVessel.alpha = 0

        let expandAction = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.35),
            SKAction.fadeIn(withDuration: 0.35)
        ])
        expandAction.timingMode = .easeOut
        contentVessel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            expandAction
        ]))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if node.name == "recommenceVestige" {
                animateButtonPress(node) { [weak self] in
                    self?.onRecommence?()
                }
                return
            }
            if node.name == "gatewayVestige" {
                animateButtonPress(node) { [weak self] in
                    self?.onReturnToGateway?()
                }
                return
            }
        }
    }

    private func animateButtonPress(_ node: SKNode, completion: @escaping () -> Void) {
        let targetNode = node.parent ?? node
        targetNode.run(SKAction.sequence([
            SKAction.scale(to: 0.92, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.06),
            SKAction.run { completion() }
        ]))
    }
}
