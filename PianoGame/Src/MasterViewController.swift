
import UIKit
import SpriteKit



class MasterViewController: UITableViewController {
    
    
    var items: [(title: String, viewControllerBuilder: () -> UIViewController)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            
            (title: "Chords Play", viewControllerBuilder: {
        
                let vc = GenericSpriteKitViewController()
                
                let scene = ChordsPlayScene(size: CGSize(width: 1024, height: 768))
                scene.scaleMode = .aspectFit
                
                (vc.view as! SKView).presentScene(scene)
                
                return vc
            }),
            
            (title: "Chords", viewControllerBuilder: {
        
                let vc = GenericSpriteKitViewController()
                
                let scene = ChordsScene(size: CGSize(width: 1024, height: 768))
                scene.scaleMode = .aspectFit
                
                (vc.view as! SKView).presentScene(scene)
                
                return vc
            }),
            
            (title: "SightReading", viewControllerBuilder: {
         
                let vc = GenericSpriteKitViewController()
                
                let scene = SightReadingScene(size: CGSize(width: 1024, height: 768))
                scene.scaleMode = .aspectFit
                
                (vc.view as! SKView).presentScene(scene)
                
                return vc
            }),
        ]
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let item = items[indexPath.row]
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        self.splitViewController?.showDetailViewController(item.viewControllerBuilder(), sender: nil)
    }
}
