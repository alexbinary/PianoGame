
import UIKit
import SpriteKit



class GenericSpriteKitViewController: UIViewController {

    
    override func loadView() {
    
        self.view = SKView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isMultipleTouchEnabled = true
    }
}
