
import  UIKit



class SplitViewController: UISplitViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .primaryOverlay
        
        self.showDetailViewController(GenericSpriteKitViewController(), sender: nil)
    }
}
