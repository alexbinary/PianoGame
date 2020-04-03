
import  UIKit



class SplitViewController: UISplitViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            self.primaryBackgroundStyle = .sidebar
        }
        self.preferredDisplayMode = .primaryOverlay
    }
}
