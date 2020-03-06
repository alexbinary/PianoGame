
import Foundation
import SpriteKit
import MIKMIDI



class SimpleCountingDisplayScene: SKScene {
    
    
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
    
    
    var puzzle = Puzzle(startingNote: .c,
                        visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
                        hiddenNoteNames: [.c, .d, .e],
                        expectedNote: .d)
        
    
    override func didMove(to view: SKView) {
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        
        self.createNoteDisplayNodes()
        self.layoutNotes()
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
    }
    
    
    func createNoteDisplayNodes() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        for note in Note.allCases {
            
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.fontColor = colorPalette.foregroundColor
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
            labelNode.alpha = self.puzzle.hiddenNoteNames.contains(note) ? 0 : 1
            
            let circleNode = SKShapeNode(circleOfRadius: self.noteSize / 2.0)
            circleNode.strokeColor = colorPalette.foregroundColor
            circleNode.lineWidth = note == self.puzzle.expectedNote ? 4 : 1
            circleNode.setScale(puzzle.visibleNotes.contains(note) ? 1 : 0)
            
            circleNode.addChild(labelNode)
            self.addChild(circleNode)
            
            self.noteDisplayNodeByNote[note] = circleNode
        }
        
        self.layoutNotes()
    }
    
    
    func layoutNotes() {
        
        let totalNoteWidth = self.noteDisplayNodeByNote.reduce(0) { $0 + $1.value.xScale * self.noteSize }
        
        let anchorPosition = CGPoint(x: -totalNoteWidth/2.0, y: 0)
        
        var previousNoteNode: SKNode? = nil
        
        for i in 0...11 {
        
            let note = Note.allCases[(Note.allCases.firstIndex(of: self.puzzle.startingNote)! + i) % 12]
        
            let noteNode = noteDisplayNodeByNote[note]!
            
            let refPosition = previousNoteNode?.position ?? anchorPosition
            
            let offset = (previousNoteNode?.xScale ?? 0) * self.noteSize / 2.0

            noteNode.position = refPosition + CGPoint(x: offset + noteNode.xScale * self.noteSize / 2.0, y: 0)
            
            previousNoteNode = noteNode
        }
    }
    
    
    override func didFinishUpdate() {
        
        self.layoutNotes()
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
        
        noteDisplayNode.fillColor = playedNote == self.puzzle.expectedNote ? colorPalette.correctColor : colorPalette.incorrectColor
        noteDisplayNode.children.forEach { $0.alpha = 1 }
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
        
        let scaleDownAction = SKAction.scale(to: self.puzzle.visibleNotes.contains(playedNote) ? 1 : 0, duration: disappearDuration)
        noteDisplayNode.run(scaleDownAction)
        
        // update node
        
        noteDisplayNode.fillColor = .clear
        noteDisplayNode.children.forEach { $0.alpha = self.puzzle.hiddenNoteNames.contains(playedNote) ? 0 : 1 }
    }
}
