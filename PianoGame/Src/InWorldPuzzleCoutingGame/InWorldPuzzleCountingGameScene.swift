
import Foundation
import SpriteKit
import MIKMIDI



class InWorldPuzzleCountingGameScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
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
    
    
    var simpleCountingDisplayNodes: [SimpleCountingDisplayNode] = []
    
    
    var puzzles = (0...30).map { _ in Puzzle.random(startingWith: Note.allCases.filter { !$0.isSharp } .randomElement()!) }
        
//        [
//
//        Puzzle(startingNote: .a,
//               visibleNotes: [ .a ],
//               expectedNote: .a),
//
//        Puzzle(startingNote: .b,
//               visibleNotes: [ .b ],
//               expectedNote: .b),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: [ .c ],
//               expectedNote: .c),
//
//        Puzzle(startingNote: .d,
//               visibleNotes: [ .d ],
//               expectedNote: .d),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: [ .e ],
//               expectedNote: .e),
//
//        Puzzle(startingNote: .f,
//               visibleNotes: [ .f ],
//               expectedNote: .f),
//
//        Puzzle(startingNote: .g,
//               visibleNotes: [ .g ],
//               expectedNote: .g),
//
//        Puzzle(startingNote: .a,
//               visibleNotes: [ .a, .b ],
//               expectedNote: .a,
//               distanceToPreviousPuzzle: 200),
//
//        Puzzle(startingNote: .a,
//               visibleNotes: [ .a, .b ],
//               expectedNote: .b),
//
//        Puzzle(startingNote: .a,
//               visibleNotes: [ .a, .b, .c ],
//               expectedNote: .a,
//               distanceToPreviousPuzzle: 200),
//
//        Puzzle(startingNote: .a,
//               visibleNotes: [ .a, .b, .c ],
//               expectedNote: .b),
//
//        Puzzle(startingNote: .a,
//               visibleNotes: [ .a, .b, .c ],
//               expectedNote: .c),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.c],
//               expectedNote: .c,
//               distanceToPreviousPuzzle: 200),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.d],
//               expectedNote: .d),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.e],
//               expectedNote: .e),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.f],
//               expectedNote: .f),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.g],
//               expectedNote: .g),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.a],
//               expectedNote: .a),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.b],
//               expectedNote: .b),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.c, .d],
//               expectedNote: .c,
//               distanceToPreviousPuzzle: 200),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.d, .e],
//               expectedNote: .d),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.e, .f],
//               expectedNote: .e),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.f, .g],
//               expectedNote: .f),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.g, .a],
//               expectedNote: .g),
//
//        Puzzle(startingNote: .c,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.a, .b],
//               expectedNote: .a),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.c, .d],
//               expectedNote: .c,
//               distanceToPreviousPuzzle: 200),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.d, .e],
//               expectedNote: .d),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.e, .f],
//               expectedNote: .e),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.f, .g],
//               expectedNote: .f),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.g, .a],
//               expectedNote: .g),
//
//        Puzzle(startingNote: .e,
//               visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
//               hiddenNoteNames: [.a, .b],
//               expectedNote: .a),
//    ]
    
    var currentPuzzleIndex: Int = 0
    
    var currentPuzzleSolved = false
    
    var currentQuestionSolutionNote: Note { self.puzzles[self.currentPuzzleIndex].expectedNote }
    
    
    var playerCharacterNode: SKNode!
    
    lazy var markers: [CGFloat] = {
        
        var markers: [CGFloat] = []
        
        for puzzle in self.puzzles {
            
            markers.append((markers.last ?? 0) + puzzle.distanceToPreviousPuzzle)
        }
        
        return markers
    }()
    
    
    struct NoteDisplayData {
        
        let labelNode: SKNode
        let springAnchorNode: SKNode
        let springJoint: SKPhysicsJointSpring
        let disappearAction: SKAction
    }
    
    var noteDisplayDataByNote: [NoteCode: NoteDisplayData] = [:]
    
    
    override func didMove(to view: SKView) {
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        
        view.showsFPS = true
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
        
        for i in 0..<markers.count {
            
            let x = markers[i]
            
            let markerNode = SKSpriteNode(color: .blue, size: CGSize(width: 10, height: 10))
            markerNode.position = CGPoint(x: x, y: 0)
            self.addChild(markerNode)
            
            let simpleCountingDisplayNode = SimpleCountingDisplayNode(colorPalette: colorPalette, puzzle: self.puzzles[i])
            simpleCountingDisplayNode.delegate = self
            simpleCountingDisplayNode.position = CGPoint(x: x, y: -50)
            self.addChild(simpleCountingDisplayNode)
            
            self.simpleCountingDisplayNodes.append(simpleCountingDisplayNode)
        }
    }
    
    
    override func didFinishUpdate() {
        
        self.camera?.position.x = self.playerCharacterNode.position.x
        
        self.simpleCountingDisplayNodes[self.currentPuzzleIndex].layoutNotes()
    }
    
    
    func loadNextPuzzle() {
        
        self.currentPuzzleIndex += 1
        
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
        
        self.simpleCountingDisplayNodes[self.currentPuzzleIndex].onNoteOn(noteCode: noteCode, velocity: velocity)
        self.onNoteOn__PhysicsDisplay(noteCode: noteCode, velocity: velocity)
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
        
        self.simpleCountingDisplayNodes[self.currentPuzzleIndex].onNoteOff(noteCode: noteCode)
        self.onNoteOff_PhysicsDisplay(noteCode: noteCode)
    }
    
    
    func onNoteOn__PhysicsDisplay(noteCode: NoteCode, velocity: Velocity) {
        
        let minimumNoteCode: UInt = 21
        let maximumNoteCode: UInt = 107
        let noteCodeSpan: UInt = maximumNoteCode - minimumNoteCode
        let noteCodeFromZero: UInt = noteCode - minimumNoteCode
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let note = Note(fromNoteCode: noteCode)
        
        let elevateNote = note == self.currentQuestionSolutionNote
        
        // create label
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Attempted to use color palette but it was not defined.")
        }
        
        let labelNode = SKLabelNode(text: note.description.uppercased())
        labelNode.fontName = elevateNote ? "HelveticaNeue" : "HelveticaNeue-UltraLight"
        labelNode.fontColor = elevateNote ? colorPalette.correctColor : colorPalette.incorrectColor
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        
        let horizontalStep: CGFloat = self.frame.width / CGFloat(noteCodeSpan + 2)
        let xPosition = -self.frame.width/2.0 + CGFloat(noteCodeFromZero + 1) * horizontalStep
        
        labelNode.position = CGPoint(x: xPosition, y: -self.size.height/4)
         
        // configure spring system
        
        labelNode.physicsBody = SKPhysicsBody(circleOfRadius: labelNode.calculateAccumulatedFrame().size.width/2.0)
        labelNode.physicsBody?.allowsRotation = false
        labelNode.physicsBody?.categoryBitMask = 2
        labelNode.physicsBody?.collisionBitMask = 2
        
        var constraints: [SKConstraint] = []
        if !elevateNote {
            constraints.append(SKConstraint.positionY(SKRange(constantValue: labelNode.position.y)))
        }
        if elevateNote {
            constraints.append(SKConstraint.positionX(SKRange(constantValue: labelNode.position.x)))
        }
        labelNode.constraints = constraints
        
        let springAnchorNode = SKShapeNode(circleOfRadius: 0)
        springAnchorNode.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        springAnchorNode.physicsBody?.isDynamic = false
        springAnchorNode.physicsBody?.categoryBitMask = 1
        springAnchorNode.physicsBody?.collisionBitMask = 1
        springAnchorNode.position = labelNode.position
        
        let springJoint = SKPhysicsJointSpring.joint(withBodyA: springAnchorNode.physicsBody!,
                                                     bodyB: labelNode.physicsBody!,
                                                     anchorA: springAnchorNode.position,
                                                     anchorB: labelNode.position)
         
        springJoint.frequency = 1
        springJoint.damping = 5
        
        // general animation settings
        
        let appearDuration: Double = 0.1
        let fadeOutDuration: Double = 10 * velocityFactor
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        let scaleUpAmplitude: CGFloat = 10 * CGFloat(velocityFactor)
        
        let appearScaleAction = SKAction.scale(to: scaleUpAmplitude, duration: appearDuration)
        let fadeOutScaleAction = SKAction.scale(to: 0, duration: fadeOutDuration)
        let disappearScaleAction = SKAction.scale(to: 0, duration: disappearDuration)
        
        // animate fadeout
        
        let fadeOutFadeAction = SKAction.fadeOut(withDuration: fadeOutDuration)
        
        // animate jiggle
        
        let jiggleDuration: Double = 0.02 * 4
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor) * 0.5
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0 * jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        // compose final animation
        
        let appearAndFadeOutAction = SKAction.group([
            SKAction.sequence([
                appearScaleAction,
                SKAction.group([fadeOutScaleAction, fadeOutFadeAction])
            ]),
            jiggleAction
        ])
        let disappearAction = disappearScaleAction
        
        // setup an animate
        
        labelNode.setScale(0)
        
        self.camera?.addChild(labelNode)
        self.camera?.addChild(springAnchorNode)
        
        self.physicsWorld.add(springJoint)
        
        if elevateNote {
            springAnchorNode.position += CGPoint(x: 0, y: +300)
        }
        
        labelNode.run(appearAndFadeOutAction)
        
        // register data for teardown
        
        self.noteDisplayDataByNote[noteCode] = NoteDisplayData(labelNode: labelNode,
                                                               springAnchorNode: springAnchorNode,
                                                               springJoint: springJoint,
                                                               disappearAction: disappearAction)
    }
    
    
    func onNoteOff_PhysicsDisplay(noteCode: NoteCode) {
        
        if let noteDisplayData = self.noteDisplayDataByNote[noteCode] {
           
           self.noteDisplayDataByNote.removeValue(forKey: noteCode)
           
           noteDisplayData.labelNode.run(noteDisplayData.disappearAction, completion: {
               
               self.camera?.removeChildren(in: [noteDisplayData.labelNode, noteDisplayData.springAnchorNode])
               self.physicsWorld.remove(noteDisplayData.springJoint)
           })
       }
    }
}


extension InWorldPuzzleCountingGameScene: SimpleCountingDisplayNodeDelegate {
    
    
    func didReleaseExpectedNote() {
        
         self.loadNextPuzzle()
    }
}
