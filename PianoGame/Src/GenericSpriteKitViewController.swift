
import UIKit
import SpriteKit



class GenericSpriteKitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SightReadingScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFit
        
        (view as! SKView).presentScene(scene)
    }
}
