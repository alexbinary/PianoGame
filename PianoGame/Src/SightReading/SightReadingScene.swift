
import SpriteKit



class SightReadingScene: SKScene {
    
    
    enum Clef {
        
        case treble
        case bass
    }
    
    
    enum Quality {
        
        case minor
        case major
        case diminished
    }


    struct ExerciseItem {
        
        let staffNotes: [StaffNote]
        let annotations: [String]
    }
    
    
    struct Exercise {
        
        let clef: Clef
        let items: [ExerciseItem]
    }
    
    
    enum ExerciseType: CaseIterable {
        
        case random
        case progression
        case chords
    }
    
    
    var staffReferenceYPosition: CGFloat { self.frame.height / 2 + 100}
    let staffNumberOfLines = 5
    let staffLineHeight: CGFloat = 5
    let staffLineSpacing: CGFloat = 50
    let staffNoteEllipseness: CGFloat = 1.2
    let staffLedgerLineWidth: CGFloat = 100
    let annotationDistanceFromStaffFirstLine: CGFloat = 100
    
    
    var staffYPositionOfFirstLine: CGFloat! = nil
    
    
    var annotationNodes: [SKNode] = []
    
    
    var currentExercise: Exercise!
    
    
    var exerciseNodes: [SKNode] = []
    
    
    var exerciseCounter = 0
    var counterNode: SKLabelNode! = nil
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.backgroundColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
        
        self.drawStaff()
        
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
        
        let type = ExerciseType.allCases.randomElement()!
        
        switch type {
            
        case .random:
            
            let numberOfNotes = 7
            let maxExcursion = 1
            
            var clef: Clef
            var centerNote: StaffNote
            
            if Bool.random() {
                
                clef = .treble
                centerNote = Bool.random() ? StaffNote(.g, octave: 4) : StaffNote(.c, octave: Bool.random() ? 4 : 5)
                
            } else {
                
                clef = .bass
                centerNote = Bool.random() ? StaffNote(.f, octave: 3) : StaffNote(.c, octave: Bool.random() ? 4 : 3)
            }
            
            var notes = [centerNote]
            
            for _ in 1..<numberOfNotes {
                notes.append(centerNote.addingStaffOffset((-maxExcursion...maxExcursion).randomElement()!))
            }
            
            self.currentExercise = Exercise(clef: clef, items:
                notes.map {
                    ExerciseItem(staffNotes: [$0], annotations: [$0.note.description])
                }
            )
            
        case .progression:
            
            let numberOfNotes = 8
            
            var clef: Clef
            var centerNote: StaffNote
            
            if Bool.random() {
                
                clef = .treble
                centerNote = Bool.random() ? StaffNote(.g, octave: 4) : StaffNote(.c, octave: Bool.random() ? 4 : 5)
                
            } else {
                
                clef = .bass
                centerNote = Bool.random() ? StaffNote(.f, octave: 3) : StaffNote(.c, octave: Bool.random() ? 4 : 3)
            }
            
            var notes = [centerNote]
            
            for i in 1..<numberOfNotes {
                notes.append(centerNote.addingStaffOffset(i))
            }
            
            self.currentExercise = Exercise(clef: clef, items:
                notes.map {
                    ExerciseItem(staffNotes: [$0], annotations: [$0.note.description])
                }
            )
            
        case .chords:
            
            let clef: Clef = Bool.random() ? .treble : .bass
            let centerNote: StaffNote = StaffNote(Legacy_Note.allCases.filter { !$0.isSharp } .randomElement()!, octave: clef == .treble ? 4 : 3)
            
            var chordNotes = [centerNote, centerNote.addingStaffOffset(2), centerNote.addingStaffOffset(4)]
            
            if Bool.random() {
                chordNotes[0] = chordNotes[0].upOnOctave()
                if Bool.random() {
                    chordNotes[1] = chordNotes[1].upOnOctave()
                }
            }
            
            let qualityMap: [Legacy_Note: Quality] = [
                .c: .major,
                .d: .minor,
                .e: .minor,
                .f: .major,
                .g: .major,
                .a: .minor,
                .b: .diminished,
            ]
            let quality = qualityMap[centerNote.note]
            
            self.currentExercise = Exercise(clef: clef,
                                            items: [
                                                ExerciseItem(staffNotes: chordNotes,
                                                             annotations: [chordNotes.map { $0.note.description } .joined(), centerNote.note.description + "\(quality == .minor ? "m" : quality == .diminished ? "d" : "")"])
            ])
        }
        
        self.clearExercise()
        self.drawExercise(self.currentExercise)
        
        self.exerciseCounter += 1
        self.updateCounter()
    }
    
    
    func clearExercise() {
        
        self.removeChildren(in: self.exerciseNodes)
        self.exerciseNodes.removeAll()
        self.annotationNodes.removeAll()
    }
    
    
    func drawExercise(_ exercise: Exercise) {
        
        self.exerciseNodes.append(self.drawClef(exercise.clef))
        
        let minX: CGFloat = 200
        let maxX: CGFloat = self.frame.width - 50
        let xSpan: CGFloat = maxX - minX
        let xStep: CGFloat = xSpan / CGFloat(exercise.items.count + 1)
        
        var x = minX + xStep
        
        for item in exercise.items {
    
            self.exerciseNodes.append(contentsOf: self.drawNotes(item.staffNotes, clef: exercise.clef, x: x))
            self.exerciseNodes.append(contentsOf: self.drawAnnotation(item.annotations, x: x))
            
            x += xStep
        }
        
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
    
    
    func drawClef(_ clef: Clef) -> SKNode {
        
        switch clef {
        case .treble:
            let spriteNode = SKSpriteNode(imageNamed: "treble_clef")
            spriteNode.setScale(0.2)
            spriteNode.position = CGPoint(x: 100, y: self.staffReferenceYPosition - 28)
            self.addChild(spriteNode)
            return spriteNode
        case .bass:
            let spriteNode = SKSpriteNode(imageNamed: "bass_clef")
            spriteNode.setScale(0.15)
            spriteNode.position = CGPoint(x: 100, y: self.staffReferenceYPosition - 10)
            self.addChild(spriteNode)
            return spriteNode
        }
    }
    
    
    func drawNotes(_ staffNotes: [StaffNote], clef: Clef, x: CGFloat) -> [SKNode] {
        
        let referenceNote: Legacy_Note = .c
        let referenceOctave = 4
        let offsetForOneOctave = 7
        
        let naturalNotes = Legacy_Note.allCases.filter { !$0.isSharp }
        
        var nodes: [SKNode] = []
        
        for staffNote in staffNotes {
            
            let noteStaffOffsetFromC4 = naturalNotes.firstIndex(of: staffNote.note)! - naturalNotes.firstIndex(of: referenceNote)! + (staffNote.octave - referenceOctave) * offsetForOneOctave
            let C4StaffOffsetFromFirstLine = clef == .treble ? -2 : 10
            let noteStaffOffsetFromFirstLine = noteStaffOffsetFromC4 + C4StaffOffsetFromFirstLine
            
            let noteNode = SKShapeNode(ellipseOf: CGSize(width: self.staffLineSpacing * self.staffNoteEllipseness, height: self.staffLineSpacing))
            noteNode.strokeColor = .clear
            noteNode.fillColor = .black
            noteNode.position = CGPoint(x: x, y: self.staffYPositionOfFirstLine + CGFloat(noteStaffOffsetFromFirstLine) * self.staffLineSpacing/2)
            self.addChild(noteNode)
            
            nodes.append(noteNode)
            
            if noteStaffOffsetFromFirstLine <= -2 {
                var offset = -2
                while true {
                    nodes.append(self.drawLedgerLine(x: x, staffOffsetFromFirstLine: offset))
                    offset -= 2
                    if offset < noteStaffOffsetFromFirstLine {
                        break
                    }
                }
            }
            
            if noteStaffOffsetFromFirstLine > 9 {
                var offset = 10
                while true {
                    nodes.append(self.drawLedgerLine(x: x, staffOffsetFromFirstLine: offset))
                    offset += 2
                    if offset > noteStaffOffsetFromFirstLine {
                        break
                    }
                }
            }
        }
        
        return nodes
    }
    
    
    func drawLedgerLine(x: CGFloat, staffOffsetFromFirstLine: Int) -> SKNode {
        
        let line = SKSpriteNode(color: .black, size: CGSize(width: self.staffLedgerLineWidth, height: self.staffLineHeight))
        line.position = CGPoint(x: x, y: self.staffYPositionOfFirstLine + CGFloat(staffOffsetFromFirstLine) * self.staffLineSpacing/2)
        self.addChild(line)
        return line
    }
    
    
    func drawAnnotation(_ texts: [String], x: CGFloat) -> [SKNode] {
        
        var y = self.staffYPositionOfFirstLine - annotationDistanceFromStaffFirstLine
        
        var nodes: [SKNode] = []
        
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
            
            nodes.append(labelNode)
            
            y -= labelNode.calculateAccumulatedFrame().height
            
            self.annotationNodes.append(labelNode)
        }
        
        return nodes
    }
    
    
    func showAnnotations() {
        
        self.annotationNodes.forEach { $0.isHidden = false }
    }
    
    
    func hideAnnotations() {
        
        self.annotationNodes.forEach { $0.isHidden = true }
    }
}
