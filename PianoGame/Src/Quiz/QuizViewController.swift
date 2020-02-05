
import Cocoa
import SpriteKit
import MIKMIDI


class QuizViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = QuizGameScene()
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
    }
}
