
import Cocoa
import SpriteKit


class ViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = GameScene()
        
        skView.presentScene(scene)
        
        scene.scaleMode = .resizeFill
        
        let camera = SKCameraNode()
        
        scene.addChild(camera)
        scene.camera = camera
    }
}
