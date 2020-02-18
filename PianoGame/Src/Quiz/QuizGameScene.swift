
import Foundation
import SpriteKit


class QuizGameScene: SKScene {
    
    
    var playerDelegate: PlayerDelegate?
    
    var labelNode: SKLabelNode!
    
    var currentNote: Note!
    var currentOffset = 0
    
    var currentExpectedNote: Note {
        return Note.allCases[(Note.allCases.firstIndex(of: currentNote)! + currentOffset) % Note.allCases.count]
    }
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
        
        generateNewNote()
        updateLabel()
        playerDelegate?.playNote(UInt(Note.allCases.firstIndex(of: currentNote)! + 60))
    }
    
    
    func generateNewNote() {
        
        currentNote = Note.allCases.randomElement()
        currentOffset = Int.random(in: 1...12)
    }
    
    
    func updateLabel() {
        
        labelNode.text = "\(String(describing: currentNote!).uppercased()) + \(Double(currentOffset) / 2.0) tone(s)"
    }
    
    
    func onNotePlayed(_ note: Note) {
        
        if note == currentExpectedNote {
            
            generateNewNote()
            updateLabel()
            playerDelegate?.playNote(UInt(Note.allCases.firstIndex(of: currentNote)! + 60))
        }
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        let note = Note.allCases[(Int(noteCode) - 60 + 8*12) % Note.allCases.count]
        
        onNotePlayed(note)
    }
}


protocol PlayerDelegate {
    
    
    func playNote(_ note: UInt)
}
