
import SpriteKit
import MIKMIDI



class SightReadingScene: SKScene {
    
    
    var staffReferenceYPosition: CGFloat { self.frame.height / 2 + 200}
    let staffNumberOfLines = 5
    let staffLineHeight: CGFloat = 5
    let staffLineSpacing: CGFloat = 50
    let staffNoteEllipseness: CGFloat = 1.2
    let staffLedgerLineWidth: CGFloat = 100
    
    
    var staffYPositionOfFirstLine: CGFloat! = nil
    
    
    var annotationNodes: [SKNode] = []
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.backgroundColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
        
        self.drawStaff()
        self.drawClef(.bass)
        self.drawNotes([StaffNote(.c, octave: 4), StaffNote(.e, octave: 4), StaffNote(.g, octave: 4)], clef: .treble, x: 500)
        self.drawNotes([StaffNote(.c, octave: 4)], clef: .bass, x: 800)
        self.drawAnnotation(["CEG", "C"], x: 500)
        
        self.hideAnnotations()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.showAnnotations()
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.hideAnnotations()
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
    
    
    func drawNotes(_ staffNotes: [StaffNote], clef: Clef, x: CGFloat) {
        
        let referenceNote: Note = .c
        let referenceOctave = 4
        let offsetForOneOctave = 7
        
        let naturalNotes = Note.allCases.filter { !$0.isSharp }
        
        for staffNote in staffNotes {
            
            let noteStaffOffsetFromC4 = naturalNotes.firstIndex(of: staffNote.note)! - naturalNotes.firstIndex(of: referenceNote)! + (staffNote.octave - referenceOctave) * offsetForOneOctave
            let C4StaffOffsetFromFirstLine = clef == .treble ? -2 : 10
            let noteStaffOffsetFromFirstLine = noteStaffOffsetFromC4 + C4StaffOffsetFromFirstLine
            
            let noteNode = SKShapeNode(ellipseOf: CGSize(width: self.staffLineSpacing * self.staffNoteEllipseness, height: self.staffLineSpacing))
            noteNode.strokeColor = .clear
            noteNode.fillColor = .black
            noteNode.position = CGPoint(x: x, y: self.staffYPositionOfFirstLine + CGFloat(noteStaffOffsetFromFirstLine) * self.staffLineSpacing/2)
            self.addChild(noteNode)
            
            if noteStaffOffsetFromFirstLine < 0 || noteStaffOffsetFromFirstLine > 9 {
                self.drawLedgerLine(x: x, staffOffsetFromFirstLine: noteStaffOffsetFromFirstLine)
            }
        }
    }
    
    
    func drawLedgerLine(x: CGFloat, staffOffsetFromFirstLine: Int) {
        
        let line = SKSpriteNode(color: .black, size: CGSize(width: self.staffLedgerLineWidth, height: self.staffLineHeight))
        line.position = CGPoint(x: x, y: self.staffYPositionOfFirstLine + CGFloat(staffOffsetFromFirstLine) * self.staffLineSpacing/2)
        self.addChild(line)
    }
    
    
    func drawAnnotation(_ texts: [String], x: CGFloat) {
        
        var y = self.staffYPositionOfFirstLine - 200
        
        for text in texts {
            
            let labelNode = SKLabelNode(text: text)
            labelNode.fontColor = .black
            labelNode.numberOfLines = 0
            labelNode.fontSize = 64
            labelNode.fontName = "HelveticaNeue"
            labelNode.verticalAlignmentMode = .top
            labelNode.horizontalAlignmentMode = .center
            labelNode.position = CGPoint(x: x, y: y)
            self.addChild(labelNode)
            y -= labelNode.calculateAccumulatedFrame().height
            
            self.annotationNodes.append(labelNode)
        }
    }
    
    
    func showAnnotations() {
        
        self.annotationNodes.forEach { $0.isHidden = false }
    }
    
    
    func hideAnnotations() {
        
        self.annotationNodes.forEach { $0.isHidden = true }
    }
}


enum Clef {
    
    case treble
    case bass
}


struct StaffNote {
    
    let note: Note
    let octave: Int
    
    init(_ note: Note, octave: Int) {
        self.note = note
        self.octave = octave
    }
}
