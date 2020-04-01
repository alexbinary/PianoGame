
import UIKit
import SpriteKit



class MasterViewController: UITableViewController {
    
    
    var items: [UIViewController] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let vc = GenericSpriteKitViewController()
        
        let scene = SightReadingScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFit
        
        (vc.view as! SKView).presentScene(scene)
        
        self.items.append(vc)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let item = items[indexPath.row]
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = type(of: item).description()
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        self.splitViewController?.showDetailViewController(item, sender: nil)
    }
}
