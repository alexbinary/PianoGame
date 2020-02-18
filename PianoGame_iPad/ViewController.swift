
import UIKit
import SpriteKit
import MIKMIDI


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let skView = view as! SKView
        
        let scene = SimpleQuizGameScene()
        
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
    }
}

