import SpriteKit

final class LuminescentDialogue: SKNode {

    private let canvasExtent: CGSize
    private var dismissalClosure: (() -> Void)?

    private let backdropPane = SKShapeNode()
    private let contentVessel = SKNode()

    init(canvasExtent: CGSize) {
        self.canvasExtent = canvasExtent
        super.init()
        self.zPosition = CosmicConstants.Stratum.overlayLayer.rawValue
        self.isUserInteractionEnabled = true
        assembleVeil()
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

    func presentPauseManifest(onResume resumeAction: @escaping () -> Void, onRestart restartAction: @escaping () -> Void, onGateway gatewayAction: @escaping () -> Void) {
        contentVessel.removeAllChildren()

        let panelWidth: CGFloat = canvasExtent.width * 0.7
        let panelHeight: CGFloat = 340

        let panel = fabricatePanel(width: panelWidth, height: panelHeight)
        contentVessel.addChild(panel)

        let headline = fabricateInscription(
            text: "PAUSED",
            fontSize: 32,
            fontWeight: .bold,
            tint: ChromaticPalette.primaryAccent
        )
        headline.position = CGPoint(x: 0, y: 100)
        contentVessel.addChild(headline)

        let divider = SKShapeNode(rectOf: CGSize(width: panelWidth * 0.6, height: 1.5))
        divider.fillColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: 72)
        contentVessel.addChild(divider)

        let resumeButton = fabricateGradientButton(
            inscription: "RESUME",
            breadth: panelWidth * 0.6,
            altitude: 46,
            palette: ChromaticPalette.commenceGradient,
            identifier: "resumeVestige"
        )
        resumeButton.position = CGPoint(x: 0, y: 28)
        contentVessel.addChild(resumeButton)

        let restartButton = fabricateGradientButton(
            inscription: "RESTART",
            breadth: panelWidth * 0.6,
            altitude: 46,
            palette: ChromaticPalette.recommenceGradient,
            identifier: "restartVestige"
        )
        restartButton.position = CGPoint(x: 0, y: -30)
        contentVessel.addChild(restartButton)

        let gatewayButton = fabricateOutlineButton(
            inscription: "MAIN MENU",
            breadth: panelWidth * 0.6,
            altitude: 42,
            identifier: "gatewayVestige"
        )
        gatewayButton.position = CGPoint(x: 0, y: -86)
        contentVessel.addChild(gatewayButton)

        addChild(contentVessel)

        self.dismissalClosure = resumeAction
        self.userData = NSMutableDictionary()
        self.userData?["restartClosure"] = restartAction
        self.userData?["gatewayClosure"] = gatewayAction

        contentVessel.setScale(0.5)
        contentVessel.alpha = 0
        let expandAction = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)
        ])
        expandAction.timingMode = .easeOut
        contentVessel.run(expandAction)
    }

    // MARK: - Fabrication Helpers

    private func fabricatePanel(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let cornerArc: CGFloat = 20
        let panelPath = UIBezierPath(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: cornerArc)
        let panel = SKShapeNode(path: panelPath.cgPath)
        panel.fillColor = ChromaticPalette.interfaceCanvas
        panel.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.3)
        panel.lineWidth = 1.5
        panel.glowWidth = 2
        return panel
    }

    func fabricateInscription(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular, tint: UIColor = ChromaticPalette.inscriptionHue) -> SKLabelNode {
        let inscription = SKLabelNode(text: text)
        inscription.fontName = fontWeight == .bold ? "AvenirNext-Bold" : (fontWeight == .medium ? "AvenirNext-Medium" : "AvenirNext-Regular")
        inscription.fontSize = fontSize
        inscription.fontColor = tint
        inscription.verticalAlignmentMode = .center
        inscription.horizontalAlignmentMode = .center
        return inscription
    }

    func fabricateGradientButton(inscription text: String, breadth: CGFloat, altitude: CGFloat, palette: [UIColor], identifier: String) -> SKNode {
        let container = SKNode()
        container.name = identifier

        let cornerArc: CGFloat = altitude / 2
        let buttonPath = UIBezierPath(roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude), cornerRadius: cornerArc)

        let background = SKShapeNode(path: buttonPath.cgPath)
        background.fillColor = palette.first ?? ChromaticPalette.primaryAccent
        background.strokeColor = .clear
        background.glowWidth = 3
        background.name = identifier
        container.addChild(background)

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
        let buttonPath = UIBezierPath(roundedRect: CGRect(x: -breadth / 2, y: -altitude / 2, width: breadth, height: altitude), cornerRadius: cornerArc)

        let background = SKShapeNode(path: buttonPath.cgPath)
        background.fillColor = .clear
        background.strokeColor = ChromaticPalette.primaryAccent.withAlphaComponent(0.4)
        background.lineWidth = 1.5
        background.glowWidth = 1
        background.name = identifier
        container.addChild(background)

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

    // MARK: - Interaction

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if node.name == "resumeVestige" {
                animateDismissal { [weak self] in
                    self?.dismissalClosure?()
                }
                return
            }
            if node.name == "restartVestige" {
                animateDismissal { [weak self] in
                    if let restartClosure = self?.userData?["restartClosure"] as? () -> Void {
                        restartClosure()
                    }
                }
                return
            }
            if node.name == "gatewayVestige" {
                animateDismissal { [weak self] in
                    if let gatewayClosure = self?.userData?["gatewayClosure"] as? () -> Void {
                        gatewayClosure()
                    }
                }
                return
            }
        }
    }

    private func animateDismissal(completion: @escaping () -> Void) {
        let shrinkAction = SKAction.group([
            SKAction.scale(to: 0.5, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2)
        ])
        shrinkAction.timingMode = .easeIn
        contentVessel.run(shrinkAction) { [weak self] in
            self?.removeFromParent()
            completion()
        }
    }
}
