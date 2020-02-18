
import Cocoa
import SpriteKit


class GenericViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = IntervalDisplayScene()
        scene.scaleMode = .resizeFill
        
        (view as! SKView).presentScene(scene)
    }
}
