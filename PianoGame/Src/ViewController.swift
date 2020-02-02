
import Cocoa
import SpriteKit


class ViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = GameScene()
        
        skView.presentScene(scene)
        
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = CGSize(width: 1600, height: 900)
        
        scene.scaleMode = .aspectFit
    }
}
