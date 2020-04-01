
import SpriteKit



class ChordsScene: SKScene {
    
    
    let noteNaming: NoteNaming = .latinNaming
    
    
    var notesLabelNode: SKLabelNode! = nil
    var chordLabelNode: SKLabelNode! = nil
    
    var exerciseCounter = 0
    var counterNode: SKLabelNode! = nil
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.backgroundColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
        
        self.notesLabelNode = SKLabelNode()
        self.notesLabelNode.fontColor = .black
        self.notesLabelNode.fontSize = 64
        self.notesLabelNode.fontName = "HelveticaNeue"
        self.notesLabelNode.verticalAlignmentMode = .bottom
        self.notesLabelNode.horizontalAlignmentMode = .center
        self.notesLabelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 100)
        self.addChild(self.notesLabelNode)
        
        self.chordLabelNode = SKLabelNode()
        self.chordLabelNode.fontColor = .black
        self.chordLabelNode.fontSize = 64
        self.chordLabelNode.fontName = "HelveticaNeue"
        self.chordLabelNode.verticalAlignmentMode = .top
        self.chordLabelNode.horizontalAlignmentMode = .center
        self.chordLabelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 100)
        self.addChild(self.chordLabelNode)
        
        self.counterNode = SKLabelNode()
        self.counterNode.fontColor = .black
        self.counterNode.fontSize = 32
        self.counterNode.fontName = "HelveticaNeue"
        self.counterNode.verticalAlignmentMode = .bottom
        self.counterNode.horizontalAlignmentMode = .left
        self.counterNode.position = CGPoint(x: 100, y: 100)
        self.addChild(self.counterNode)
        
        self.nextExercise()
    }
    
    
    func updateCounter() {
        
        self.counterNode.text = "\(self.exerciseCounter)"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        switch touches.count {
        case 1:
            self.showAnnotations()
        case 2:
            self.nextExercise()
        default:
            print("unsupported number of touches")
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.hideAnnotations()
    }
    
    
    func nextExercise() {
        
        let centerNote: StaffNote = StaffNote(Note.allCases.filter { !$0.isSharp } .randomElement()!, octave: 4)
        
        var chordNotes = [centerNote, centerNote.addingStaffOffset(2), centerNote.addingStaffOffset(4)]
        
        var inversions = 0
        
        if Bool.random() {
            chordNotes = [chordNotes[1], chordNotes[2], chordNotes[0]]
            inversions += 1
        }
        if Bool.random() {
            chordNotes = [chordNotes[1], chordNotes[2], chordNotes[0]]
            inversions += 1
        }
        
        self.notesLabelNode.text = chordNotes.map { $0.note.name(using: self.noteNaming) } .joined(separator: " ")
        self.chordLabelNode.text = centerNote.note.name(using: self.noteNaming) + " (\(inversions))"
        
        self.hideAnnotations()
        
        self.exerciseCounter += 1
        self.updateCounter()
    }
    
    
    func showAnnotations() {
        
        self.chordLabelNode.isHidden = false
    }
    
    
    func hideAnnotations() {
        
        self.chordLabelNode.isHidden = true
    }
}
