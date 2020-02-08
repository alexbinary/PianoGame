
import Foundation
import SpriteKit


class SimpleQuizGameScene: SKScene {
    
    
    var playerDelegate: PlayerDelegate?
    
    var labelNode: SKLabelNode!
    
    var currentNote: Note!
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
        
        generateNewNote()
        updateLabel()
        playerDelegate?.playNote(UInt(Note.allCases.firstIndex(of: currentNote)! + 60 - 12))
    }
    
    
    func generateNewNote() {
        
        currentNote = Note.allCases.randomElement()
    }
    
    
    func updateLabel() {
        
        labelNode.text = "\(String(describing: currentNote!).uppercased())"
    }
    
    
    func onNotePlayed(_ note: Note) {
        
        if note == currentNote {
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                
                self.generateNewNote()
                self.updateLabel()
                self.playerDelegate?.playNote(UInt(Note.allCases.firstIndex(of: self.currentNote)! + 60 - 12))
                
            }
        }
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        let note = Note.allCases[(Int(noteCode) - 60 + 8*12) % Note.allCases.count]
        
        onNotePlayed(note)
    }
}
