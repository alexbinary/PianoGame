
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var activeNotes: Set<UInt> = []
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.physicsWorld.gravity.dy = -1
    }
    
    
    func noteChanged(on: Set<UInt>, off: Set<UInt>) {
        
        activeNotes = on
        
        updateLabel()
    }
    
    
    func updateLabel() {

        let labelNode = SKLabelNode()
        
        let notes = Set<UInt>(activeNotes)
        
        labelNode.text =  [UInt](notes).sorted().map { String(describing: Note.fromNoteCode($0)).uppercased() } .joined(separator: " ")
        
        labelNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        
        addChild(labelNode)
    }
}


extension Note {
    
    
    static func fromNoteCode(_ code: UInt) -> Note {
        
        return Note.allCases[(Int(code) - 60 + 8*12) % Note.allCases.count]
    }
}
