
import Foundation
import SpriteKit


class QuizGameScene: SKScene {
    
    
    var playerDelegate: PlayerDelegate?
    
    var labelNode: SKLabelNode!
    
    var currentNote: Legacy_Note!
    var currentOffset = 0
    
    var currentExpectedNote: Legacy_Note {
        return Legacy_Note.allCases[(Legacy_Note.allCases.firstIndex(of: currentNote)! + currentOffset) % Legacy_Note.allCases.count]
    }
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
        
        generateNewNote()
        updateLabel()
        playerDelegate?.playNote(UInt(Legacy_Note.allCases.firstIndex(of: currentNote)! + 60))
    }
    
    
    func generateNewNote() {
        
        currentNote = Legacy_Note.allCases.randomElement()
        currentOffset = Int.random(in: 1...12)
    }
    
    
    func updateLabel() {
        
        labelNode.text = "\(String(describing: currentNote!).uppercased()) + \(Double(currentOffset) / 2.0) tone(s)"
    }
    
    
    func onNotePlayed(_ note: Legacy_Note) {
        
        if note == currentExpectedNote {
            
            generateNewNote()
            updateLabel()
            playerDelegate?.playNote(UInt(Legacy_Note.allCases.firstIndex(of: currentNote)! + 60))
        }
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        let note = Legacy_Note.allCases[(Int(noteCode) - 60 + 8*12) % Legacy_Note.allCases.count]
        
        onNotePlayed(note)
    }
}


protocol PlayerDelegate {
    
    
    func playNote(_ note: UInt)
}
