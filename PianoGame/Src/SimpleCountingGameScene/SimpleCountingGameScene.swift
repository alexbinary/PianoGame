
import Foundation
import SpriteKit
import MIKMIDI



class SimpleCountingGameScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    struct ColorPalette {
        
        let backgroundColor: NSColor
        let foregroundColor: NSColor
        let correctColor: NSColor
        let incorrectColor: NSColor
    }
    
    let colorPaletteDefault = ColorPalette(
        
        backgroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1),
        correctColor: .systemGreen,
        incorrectColor: .systemRed
    )
    
    let colorPaletteDarkMode = ColorPalette(
        
        backgroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1),
        correctColor: .systemGreen,
        incorrectColor: .systemRed
    )
    
    var colorPalette: ColorPalette!
    
    
    let noteSize: CGFloat = 50
    
    var noteDisplayNodeByNote: [Note: SKShapeNode] = [:]
    
    
    struct Puzzle {
    
        let startingNote: Note
        
        let visibleNotes: Set<Note>
        let hiddenNoteNames: Set<Note>
        
        let expectedNote: Note
        let distanceToPreviousPuzzle: CGFloat
        
        init(startingNote: Note, visibleNotes: Set<Note> = Set<Note>(Note.allCases), hiddenNoteNames: Set<Note> = [], expectedNote: Note, distanceToPreviousPuzzle: CGFloat = 100) {
            
            self.startingNote = startingNote
            self.visibleNotes = visibleNotes
            self.hiddenNoteNames = hiddenNoteNames
            self.expectedNote = expectedNote
            self.distanceToPreviousPuzzle = distanceToPreviousPuzzle
        }
    }
    
    
    var puzzles = [
     
        Puzzle(startingNote: .a,
               visibleNotes: [ .a ],
               expectedNote: .a),
        
        Puzzle(startingNote: .b,
               visibleNotes: [ .b ],
               expectedNote: .b),
        
        Puzzle(startingNote: .c,
               visibleNotes: [ .c ],
               expectedNote: .c),
        
        Puzzle(startingNote: .d,
               visibleNotes: [ .d ],
               expectedNote: .d),
        
        Puzzle(startingNote: .e,
               visibleNotes: [ .e ],
               expectedNote: .e),
        
        Puzzle(startingNote: .f,
               visibleNotes: [ .f ],
               expectedNote: .f),
        
        Puzzle(startingNote: .g,
               visibleNotes: [ .g ],
               expectedNote: .g),
        
        Puzzle(startingNote: .a,
               visibleNotes: [ .a, .b ],
               expectedNote: .a,
               distanceToPreviousPuzzle: 200),
        
        Puzzle(startingNote: .a,
               visibleNotes: [ .a, .b ],
               expectedNote: .b),
        
        Puzzle(startingNote: .a,
               visibleNotes: [ .a, .b, .c ],
               expectedNote: .a,
               distanceToPreviousPuzzle: 200),
        
        Puzzle(startingNote: .a,
               visibleNotes: [ .a, .b, .c ],
               expectedNote: .b),
        
        Puzzle(startingNote: .a,
               visibleNotes: [ .a, .b, .c ],
               expectedNote: .c),
    ]
    
    var currentPuzzleIndex: Int = 0
    
    var currentPuzzleSolved = false
    
    
    var playerCharacterNode: SKNode!
    
    
    lazy var markers: [CGFloat] = {
        
        var markers: [CGFloat] = []
        
        for puzzle in self.puzzles {
            
            markers.append((markers.last ?? 0) + puzzle.distanceToPreviousPuzzle)
        }
        
        return markers
    }()
    
    
    override func didMove(to view: SKView) {
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        
        self.recreateNoteDisplayNodes()
        self.layoutNotes()
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let camera = SKCameraNode()
        self.addChild(camera)
        self.camera = camera
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
        
        self.playerCharacterNode = SKSpriteNode(color: .red, size: CGSize(width: 10, height: 50))
        self.addChild(self.playerCharacterNode)
        
        for x in markers {
            
            let markerNode = SKSpriteNode(color: .blue, size: CGSize(width: 10, height: 10))
            markerNode.position = CGPoint(x: x, y: 0)
            self.addChild(markerNode)
        }
    }
    
    
    func recreateNoteDisplayNodes() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        let puzzle = self.puzzles[self.currentPuzzleIndex]
        
        self.noteDisplayNodeByNote.forEach { $0.value.removeFromParent() }
    
        for note in Note.allCases {
            
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.fontColor = colorPalette.foregroundColor
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
            labelNode.alpha = puzzle.hiddenNoteNames.contains(note) ? 0 : 1
            
            let circleNode = SKShapeNode(circleOfRadius: self.noteSize / 2.0)
            circleNode.strokeColor = colorPalette.foregroundColor
            circleNode.lineWidth = note == self.puzzles[self.currentPuzzleIndex].expectedNote ? 4 : 1
            circleNode.setScale(puzzle.visibleNotes.contains(note) ? 1 : 0)
            
            circleNode.addChild(labelNode)
            self.camera?.addChild(circleNode)
            
            self.noteDisplayNodeByNote[note] = circleNode
        }
        
        self.layoutNotes()
    }
    
    
    func layoutNotes() {
        
        let totalNoteWidth = self.noteDisplayNodeByNote.reduce(0) { $0 + $1.value.xScale * self.noteSize }
        
        let anchorPosition = CGPoint(x: -totalNoteWidth/2.0, y: -self.size.height/4)
        
        var previousNoteNode: SKNode? = nil
        
        let puzzle = self.puzzles[self.currentPuzzleIndex]
        
        for i in 0...11 {
        
            let note = Note.allCases[(Note.allCases.firstIndex(of: puzzle.startingNote)! + i) % 12]
        
            let noteNode = noteDisplayNodeByNote[note]!
            
            let refPosition = previousNoteNode?.position ?? anchorPosition
            
            let offset = (previousNoteNode?.xScale ?? 0) * self.noteSize / 2.0

            noteNode.position = refPosition + CGPoint(x: offset + noteNode.xScale * self.noteSize / 2.0, y: 0)
            
            previousNoteNode = noteNode
        }
    }
    
    
    override func didFinishUpdate() {
        
        self.camera?.position.x = self.playerCharacterNode.position.x
        
        self.layoutNotes()
    }
    
    
    func loadNextPuzzle() {
        
        self.currentPuzzleIndex += 1
        
        self.recreateNoteDisplayNodes()
        self.layoutNotes()
        
        self.playerCharacterNode.run(SKAction.move(to: CGPoint(x: markers[self.currentPuzzleIndex], y: 0), duration: 0.4))
    }
    
    
    func connectToMIDIDevice() {
        
        guard let device = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == self.MIDIDeviceName }) else {
            fatalError("MIDI device \"\(self.MIDIDeviceName)\" not found. Is it turned on?")
        }
        
        try! MIKMIDIDeviceManager.shared.connect(device) { (_, commands) in
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    if noteOnCommand.velocity > 0 {
                        self.onNoteOn(noteCode: noteOnCommand.note, velocity: noteOnCommand.velocity)
                    } else {
                        self.onNoteOff(noteCode: noteOnCommand.note)
                    }
                } else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    self.onNoteOff(noteCode: noteOffCommand.note)
                }
            }
        }
    }
    
    
    func onNoteOn(noteCode: NoteCode, velocity: Velocity) {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        let playedNote = Note(fromNoteCode: noteCode)
        
        let noteDisplayNode = noteDisplayNodeByNote[playedNote]!
        
        // general animation settings
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let scaleUpAmplitude: CGFloat = 1.1 + CGFloat(velocityFactor) * 2
        let appearDuration: Double = 1
        
        // animate scale
        
        let scaleUpAction = SKAction.scale(to: scaleUpAmplitude,
                                           duration: appearDuration,
                                           delay: 0, usingSpringWithDamping: 0.4,
                                           initialSpringVelocity: 10)
     
        // animate jiggle
        
        let jiggleDuration: Double = 0.02 * 4
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor) * 0.5
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0 * jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        // setup an animate
        
        noteDisplayNode.run(jiggleAction , withKey: "jiggle")
        noteDisplayNode.run(scaleUpAction, withKey: "scaleUp")
        
        // update node
        
        noteDisplayNode.fillColor = playedNote == self.puzzles[self.currentPuzzleIndex].expectedNote ? colorPalette.correctColor : colorPalette.incorrectColor
        noteDisplayNode.children.forEach { $0.alpha = 1 }
        
        // update game logic
        
        if playedNote == self.puzzles[self.currentPuzzleIndex].expectedNote {
            
            self.currentPuzzleSolved = true
        }
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        let playedNote = Note(fromNoteCode: noteCode)
        
        let noteDisplayNode = noteDisplayNodeByNote[playedNote]!
        
        // stop jiggle and scale up
        
        noteDisplayNode.removeAction(forKey: "jiggle")
        noteDisplayNode.zRotation = 0
        
        noteDisplayNode.removeAction(forKey: "scaleUp")
        
        // general animation settings
        
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        let scaleDownAction = SKAction.scale(to: self.puzzles[self.currentPuzzleIndex].visibleNotes.contains(playedNote) ? 1 : 0, duration: disappearDuration)
        noteDisplayNode.run(scaleDownAction, completion: {
            
            // update game logic
            
            if playedNote == self.puzzles[self.currentPuzzleIndex].expectedNote, self.currentPuzzleSolved {
                
                self.loadNextPuzzle()
            }
        })
        
        // update node
        
        noteDisplayNode.fillColor = .clear
        noteDisplayNode.children.forEach { $0.alpha = self.puzzles[self.currentPuzzleIndex].hiddenNoteNames.contains(playedNote) ? 0 : 1 }
    }
}
