
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var labelNode: SKLabelNode!
    
    var noteOnCounter = 0
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        let note = Note.allCases[(Int(noteCode) - 60 + 8*12) % Note.allCases.count]
        
        labelNode.text = "\(String(describing: note).uppercased())"
        
        noteOnCounter += 1
    }
    
    
    func noteOff(_ noteCode: UInt) {
        
        noteOnCounter -= 1
        
        if noteOnCounter == 0 {

            labelNode.text = ""
        }
    }
}
