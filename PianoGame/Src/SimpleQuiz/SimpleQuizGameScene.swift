
import Foundation
import SpriteKit


class SimpleQuizGameScene: SKScene {
    
    
    var playerDelegate: PlayerDelegate?
    
    var labelNode: SKLabelNode!
    
    var currentNote: Legacy_Note!
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
        
        generateNewNote()
        updateLabel()
        playerDelegate?.playNote(UInt(Legacy_Note.allCases.firstIndex(of: currentNote)! + 60 - 12))
    }
    
    
    func generateNewNote() {
        
        currentNote = Legacy_Note.allCases.randomElement()
    }
    
    
    func updateLabel() {
        
        labelNode.text = "\(String(describing: currentNote!).uppercased())"
    }
    
    
    func onNotePlayed(_ note: Legacy_Note) {
        
        if note == currentNote {
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                
                self.generateNewNote()
                self.updateLabel()
                self.playerDelegate?.playNote(UInt(Legacy_Note.allCases.firstIndex(of: self.currentNote)! + 60 - 12))
                
            }
        }
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        let note = Legacy_Note.allCases[(Int(noteCode) - 60 + 8*12) % Legacy_Note.allCases.count]
        
        onNotePlayed(note)
    }
}
