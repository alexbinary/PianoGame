
import SpriteKit
import MIKMIDI



class SightReadingScene: SKScene {
    
    
    var staffReferenceYPosition: CGFloat { self.frame.height / 2 + 200}
    let staffNumberOfLines = 5
    let staffLineHeight: CGFloat = 5
    let staffLineSpacing: CGFloat = 50
    let staffNoteEllipseness: CGFloat = 1.2
    
    
    var staffYPositionOfFirstLine: CGFloat! = nil
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.backgroundColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
        
        self.drawStaff()
        self.drawClef(.bass)
        self.drawNote(note: .c, octave: 4, clef: .bass, x: 500)
    }
    
    
    func drawStaff() {
        
        let totalStaffHeight = CGFloat(self.staffNumberOfLines) * self.staffLineSpacing
        let startYPosition = self.staffReferenceYPosition - totalStaffHeight / 2
        
        self.staffYPositionOfFirstLine = startYPosition
        
        for i in 1...self.staffNumberOfLines {
        
            let line = SKSpriteNode(color: .black, size: CGSize(width: self.frame.width, height: self.staffLineHeight))
            line.position = CGPoint(x: self.frame.width / 2, y: startYPosition + CGFloat(i-1) * self.staffLineSpacing)
            self.addChild(line)
        }
    }
    
    
    func drawClef(_ clef: Clef) {
        
        switch clef {
        case .treble:
            let spriteNode = SKSpriteNode(imageNamed: "treble_clef")
            spriteNode.setScale(0.2)
            spriteNode.position = CGPoint(x: 100, y: self.staffReferenceYPosition - 28)
            self.addChild(spriteNode)
        case .bass:
            let spriteNode = SKSpriteNode(imageNamed: "bass_clef")
            spriteNode.setScale(0.15)
            spriteNode.position = CGPoint(x: 100, y: self.staffReferenceYPosition - 10)
            self.addChild(spriteNode)
        }
    }
    
    
    func drawNote(note: Note, octave: Int, clef: Clef, x: CGFloat) {
        
        let referenceNote: Note = .c
        let referenceOctave = 4
        let offsetForOneOctave = 7
        
        let naturalNotes = Note.allCases.filter { !$0.isSharp }
        let staffOffsetFromC4 = naturalNotes.firstIndex(of: note)! - naturalNotes.firstIndex(of: referenceNote)! + (octave - referenceOctave) * offsetForOneOctave
        
        let staffOffsetOfC4FromFirstLine = clef == .treble ? -2 : 10
        
        let noteNode = SKShapeNode(ellipseOf: CGSize(width: self.staffLineSpacing * self.staffNoteEllipseness, height: self.staffLineSpacing))
        noteNode.strokeColor = .clear
        noteNode.fillColor = .black
        noteNode.position = CGPoint(x: x, y: self.staffYPositionOfFirstLine + CGFloat(staffOffsetOfC4FromFirstLine + staffOffsetFromC4) * self.staffLineSpacing/2)
        self.addChild(noteNode)
        
        let labelNode = SKLabelNode(text: note.description)
        labelNode.fontColor = .black
        labelNode.fontSize = 64
        labelNode.fontName = "HelveticaNeue"
        labelNode.position = CGPoint(x: noteNode.position.x, y: self.staffYPositionOfFirstLine - 200)
        self.addChild(labelNode)
    }
}


enum Clef {
    
    case treble
    case bass
}
