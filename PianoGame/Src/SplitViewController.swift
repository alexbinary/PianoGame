
import UIKit
import SpriteKit



class SplitViewController: UISplitViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            self.primaryBackgroundStyle = .sidebar
        }
        
        if let item = SplitViewController.items.first {
            self.showDetailViewController(item.viewControllerBuilder(), sender: nil)
        }
    }
    
    
    static var items: [(title: String, viewControllerBuilder: () -> UIViewController)] = {
        
        var items: [(title: String, viewControllerBuilder: () -> UIViewController)] = []
        
        #if targetEnvironment(macCatalyst)
        
        items.append((title: "Chords Play", viewControllerBuilder: {
            
            let vc = GenericSpriteKitViewController()
            
            let scene = ChordsPlayScene(size: CGSize(width: 1024, height: 768))
            scene.scaleMode = .aspectFit
            
            (vc.view as! SKView).presentScene(scene)
            
            return vc
        }))
        
        #endif
        
        items.append((title: "Sing", viewControllerBuilder: {
            
            let vc = SingViewController()
            
            return vc
        }))
        
        items.append((title: "Chords", viewControllerBuilder: {
            
            let vc = GenericSpriteKitViewController()
            
            let scene = ChordsScene(size: CGSize(width: 1024, height: 768))
            scene.scaleMode = .aspectFit
            
            (vc.view as! SKView).presentScene(scene)
            
            return vc
        }))
        
        items.append((title: "SightReading", viewControllerBuilder: {
            
            let vc = GenericSpriteKitViewController()
            
            let scene = SightReadingScene(size: CGSize(width: 1024, height: 768))
            scene.scaleMode = .aspectFit
            
            (vc.view as! SKView).presentScene(scene)
            
            return vc
        }))
        
        return items
    }()
}
