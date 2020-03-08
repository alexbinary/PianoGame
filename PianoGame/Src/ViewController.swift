
import UIKit
import SpriteKit
import MIKMIDI


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = AudioKitTestScene(size: CGSize(width: 1600, height: 900))
        scene.scaleMode = .aspectFit
        
        (view as! SKView).presentScene(scene)
    }
}

