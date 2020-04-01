
import UIKit
import SpriteKit



class MasterViewController: UITableViewController {
    
    
    var items: [UIViewController] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        
        let vc2 = GenericSpriteKitViewController()
        
        let scene2 = ChordsScene(size: CGSize(width: 1024, height: 768))
        scene2.scaleMode = .aspectFit
        
        (vc2.view as! SKView).presentScene(scene2)
        
        self.items.append(vc2)
        
        //
        
        let vc1 = GenericSpriteKitViewController()
        
        let scene1 = SightReadingScene(size: CGSize(width: 1024, height: 768))
        scene1.scaleMode = .aspectFit
        
        (vc1.view as! SKView).presentScene(scene1)
        
        self.items.append(vc1)
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
