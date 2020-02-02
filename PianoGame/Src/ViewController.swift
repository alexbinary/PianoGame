
import Cocoa
import SpriteKit


class ViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = SKScene()
        
        skView.presentScene(scene)
    }
}
