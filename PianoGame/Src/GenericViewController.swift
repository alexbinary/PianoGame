
import Cocoa
import SpriteKit


class GenericViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = Display2Scene()
        scene.scaleMode = .resizeFill
        
        (view as! SKView).presentScene(scene)
    }
    
    
    override func viewWillLayout() {
        
//        ((view as! SKView).scene as!IntervalGameScene).updateColorScheme(darkModeEnabled: view.effectiveAppearance.name == NSAppearance.Name.darkAqua)
    }
}
