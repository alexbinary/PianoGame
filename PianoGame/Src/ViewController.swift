
import Cocoa
import SpriteKit


class ViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = SKScene()
        
        skView.presentScene(scene)
        
        let label = SKLabelNode(text: "Hello")
        
        scene.addChild(label)
        
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = CGSize(width: 1600, height: 900)
        
        scene.scaleMode = .aspectFit
    }
}
