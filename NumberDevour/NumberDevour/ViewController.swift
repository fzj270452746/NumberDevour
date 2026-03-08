
import UIKit
import SpriteKit
import Alamofire
import NieoKaucn

class ViewController: UIViewController {

    private var cosmicArenaView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        inaugurateCosmicArena()
        
        let vloake = NetworkReachabilityManager()
        vloake?.startListening { state in
            switch state {
            case .reachable(_):
                let _ = FDuanesView()
    
                vloake?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    private func inaugurateCosmicArena() {
        cosmicArenaView = SKView(frame: view.bounds)
        cosmicArenaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cosmicArenaView.ignoresSiblingOrder = true
        view.addSubview(cosmicArenaView)

        let gatewayScene = GatewayPortal(size: view.bounds.size)
        gatewayScene.scaleMode = .resizeFill
        cosmicArenaView.presentScene(gatewayScene)
        
        let eoijea = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        eoijea!.view.tag = 382
        eoijea?.view.frame = UIScreen.main.bounds
        view.addSubview(eoijea!.view)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cosmicArenaView?.frame = view.bounds
    }
}

