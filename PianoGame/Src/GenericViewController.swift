
import Cocoa
import SpriteKit


class GenericViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SimpleCountingDisplayScene(size: CGSize(width: 1600, height: 900))
        scene.scaleMode = .aspectFit
        
        (view as! SKView).presentScene(scene)
    }
    
    
    override func viewWillLayout() {
        
        ((view as! SKView).scene as? IntervalGameScene)?.updateColorScheme(darkModeEnabled: view.effectiveAppearance.name == NSAppearance.Name.darkAqua)
    }
}
