
import Foundation
import SpriteKit


enum Note : CaseIterable {
    
    case c
    case c_sharp
    case d
    case d_sharp
    case e
    case f
    case f_sharp
    case g
    case g_sharp
    case a
    case a_sharp
    case b
}


class QuizGameScene: SKScene {
    
    
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
        }
    }
    
    
    func noteOn(_ noteCode: UInt) {
        
        let note = Note.allCases[(Int(noteCode) - 60 + 8*12) % Note.allCases.count]
        
        onNotePlayed(note)
    }
}
