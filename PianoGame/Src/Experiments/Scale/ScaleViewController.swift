
import UIKit



class ScaleViewController: UIViewController {

    
    @IBOutlet var label: UILabel!
    
    
    var scale = Scale()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reset()
    }
    
    
    @IBAction func noteButton(_ sender: UIButton) {
        
        switch sender.title(for: .normal) {
        case "#":
            if let note = self.scale.popLast() {
                self.scale.append(note.sharp)
            }
        case "b":
            if let note = self.scale.popLast() {
                self.scale.append(note.flat)
            }
        case "Do":
            self.scale.append(.c)
        case "Re":
            self.scale.append(.d)
        case "Mi":
            self.scale.append(.e)
        case "Fa":
            self.scale.append(.f)
        case "Sol":
            self.scale.append(.g)
        case "La":
            self.scale.append(.a)
        case "Si":
            self.scale.append(.b)
        default:
            fatalError("unexpected button title")
        }
        
        self.updateLabel()
        
        self.label.textColor = .black
    }
    
    
    @IBAction func check() {

        if self.scale.isMajorSale {
            
            self.label.textColor = .systemGreen
            
        } else {
            
            self.label.textColor = .systemRed
        }
    }
    
    
    @IBAction func reset() {
        
        self.scale.removeAll()
        self.updateLabel()
        
        self.label.textColor = .black
    }
    
    
    func updateLabel() {
        
        self.label.text = self.scale.map { $0.description } .joined(separator: " ")
    }
}
