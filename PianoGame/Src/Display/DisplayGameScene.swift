
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var labelNode: SKLabelNode!
    
    var activeNotes: Set<UInt> = []
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        activeNotes.insert(noteCode)
        
        updateLabel()
    }
    
    
    func noteOff(_ noteCode: UInt) {
        
        activeNotes.remove(noteCode)
        
        updateLabel()
    }
    
    
    func updateLabel() {

        labelNode.text =  [UInt](activeNotes).sorted().map { String(describing: Note.fromNoteCode($0)).uppercased() } .joined(separator: " ")
    }
}


extension Note {
    
    
    static func fromNoteCode(_ code: UInt) -> Note {
        
        return Note.allCases[(Int(code) - 60 + 8*12) % Note.allCases.count]
    }
}
