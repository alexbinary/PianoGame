
import UIKit
import SpriteKit



class MasterViewController: UITableViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SplitViewController.items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = SplitViewController.items[indexPath.row]
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = SplitViewController.items[indexPath.row]
        
        self.splitViewController?.showDetailViewController(item.viewControllerBuilder(), sender: nil)
    }
}
