
import Foundation
import SpriteKit
import MIKMIDI



class IntervalQuizPhysicsDisplayScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    var currentQuestionNote: Note! = nil
    var currentQuestionInterval: Interval! = nil
    
    var currentQuestionSolutionNote: Note! = nil
    var currentQuestionSolutionNoteGiven = false
    
    
    var questionNoteLabel: SKLabelNode! = nil
    var solutionNotePlaceholderNode: SKNode! = nil
    var questionIntervalNameLabel: SKLabelNode! = nil
    var questionIntervalLengthLabel: SKLabelNode! = nil
    
    
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
    
    
    struct NoteDisplayData {
        
        let labelNode: SKNode
        let springAnchorNode: SKNode
        let springJoint: SKPhysicsJointSpring
        let disappearAction: SKAction
    }
    
    var noteDisplayDataByNote: [NoteCode: NoteDisplayData] = [:]
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        self.initStaticUI()
        
        self.loadNextQuestion()
        self.updateQuestionUI()
        
        view.showsPhysics = false
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initScene() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
        
        self.physicsWorld.gravity = .zero
        
        let edgeLoopNode = SKNode()
        edgeLoopNode.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        edgeLoopNode.physicsBody?.categoryBitMask = 2
        edgeLoopNode.physicsBody?.collisionBitMask = 2
        self.addChild(edgeLoopNode)
    }
    
    
    func initStaticUI() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        let questionRootPosition = CGPoint(x: 0, y: 0)
        let sceneHalfWidth = self.size.width/2.0
        let horizontalSpread = sceneHalfWidth*2.0/3.0
            
        let textScale: CGFloat = 5
        
        self.questionNoteLabel = SKLabelNode()
        self.questionNoteLabel.fontSize *= textScale
        self.questionNoteLabel.fontColor = colorPalette.foregroundColor
        self.questionNoteLabel.verticalAlignmentMode = .center
        self.questionNoteLabel.horizontalAlignmentMode = .center
        self.questionNoteLabel.position = questionRootPosition + CGPoint(x: -horizontalSpread, y: 0)
        self.addChild(self.questionNoteLabel)
        
        self.solutionNotePlaceholderNode = SKNode()
        self.solutionNotePlaceholderNode.position = questionRootPosition + CGPoint(x: +horizontalSpread, y: 0)
        self.addChild(self.solutionNotePlaceholderNode)
        
        self.questionIntervalNameLabel = SKLabelNode()
        self.questionIntervalNameLabel.fontSize *= textScale
        self.questionIntervalNameLabel.fontColor = colorPalette.foregroundColor
        self.questionIntervalNameLabel.verticalAlignmentMode = .center
        self.questionIntervalNameLabel.horizontalAlignmentMode = .center
        self.questionIntervalNameLabel.position = questionRootPosition + CGPoint(x: 0, y: +20 * textScale)
        self.addChild(self.questionIntervalNameLabel)
        
        self.questionIntervalLengthLabel = SKLabelNode()
        self.questionIntervalLengthLabel.fontSize *= textScale
        self.questionIntervalLengthLabel.fontColor = colorPalette.foregroundColor
        self.questionIntervalLengthLabel.fontSize *= 0.8
        self.questionIntervalLengthLabel.verticalAlignmentMode = .center
        self.questionIntervalLengthLabel.horizontalAlignmentMode = .center
        self.questionIntervalLengthLabel.position = questionRootPosition + CGPoint(x: 0, y: -20 * textScale)
        self.addChild(self.questionIntervalLengthLabel)
    }
    
    
    func updateQuestionUI() {
        
        guard
             let currentQuestionNote = self.currentQuestionNote
            ,let currentQuestionInterval = self.currentQuestionInterval
        else { fatalError("Attempting to update question UI while some data have no value.") }
        
        self.questionNoteLabel.text = currentQuestionNote.description.uppercased()
        self.questionIntervalNameLabel.text = String(describing: currentQuestionInterval)
        self.questionIntervalLengthLabel.text = "\(Double(currentQuestionInterval.lengthInHalfSteps)/2.0)T"
    }
    
    
    func loadNextQuestion() {
        
        self.currentQuestionNote = Note.allCases.randomElement()
        self.currentQuestionInterval = Interval.allCases.randomElement()
        
        self.currentQuestionSolutionNote = self.currentQuestionNote.adding(self.currentQuestionInterval)
        self.currentQuestionSolutionNoteGiven = false
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
        
        let note = Note(fromNoteCode: noteCode)
        
        let noteSpawnPosition: CGPoint = self.solutionNotePlaceholderNode.position
        var noteFontName: String
        var noteFontColor: NSColor
        
        if note == self.currentQuestionSolutionNote {
            
            self.currentQuestionSolutionNoteGiven = true
            
            noteFontName = "HelveticaNeue"
            noteFontColor = colorPalette.correctColor
            
        } else {
        
            noteFontName = "HelveticaNeue-UltraLight"
            noteFontColor = colorPalette.incorrectColor
        }
        
        // create label
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let scaleUpAmplitude: CGFloat = 15
        let labelUpscalingFactor: CGFloat = scaleUpAmplitude * CGFloat(velocityFactor)
        
        let labelNode = SKLabelNode(text: note.description.uppercased())
        labelNode.fontSize *= labelUpscalingFactor
        labelNode.fontName = noteFontName
        labelNode.fontColor = noteFontColor
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        
        let minimumNoteCode: UInt = 21
        let maximumNoteCode: UInt = 107
        let noteCodeSpan: UInt = maximumNoteCode - minimumNoteCode
        let noteCodeFromZero: UInt = noteCode - minimumNoteCode
        
        let horizontalSpan = CGFloat(noteCodeSpan)  // so that each note has at least its own pixel
        let horizontalStep: CGFloat = horizontalSpan / CGFloat(noteCodeSpan + 2)
        let xPosition = -horizontalSpan/2.0 + CGFloat(noteCodeFromZero + 1) * horizontalStep
        
        labelNode.position = noteSpawnPosition + CGPoint(x: xPosition, y: 0)
         
        // configure spring system
        
        labelNode.physicsBody = SKPhysicsBody(circleOfRadius: labelNode.calculateAccumulatedFrame().size.width/2.0)
        labelNode.physicsBody?.allowsRotation = false
        labelNode.physicsBody?.categoryBitMask = 2
        labelNode.physicsBody?.collisionBitMask = 2
        
        var constraints: [SKConstraint] = []
        constraints.append(SKConstraint.positionY(SKRange(constantValue: labelNode.position.y)))
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
        
        let appearScaleAction = SKAction.scale(to: 1, duration: appearDuration)
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
        
        self.addChild(labelNode)
        self.addChild(springAnchorNode)
        
        self.physicsWorld.add(springJoint)
        
        labelNode.run(appearAndFadeOutAction)
        
        // register data for teardown
        
        noteDisplayDataByNote[noteCode] = NoteDisplayData(labelNode: labelNode,
                                                          springAnchorNode: springAnchorNode,
                                                          springJoint: springJoint,
                                                          disappearAction: disappearAction)
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
        
        if let noteDisplayData = noteDisplayDataByNote[noteCode] {
            
            noteDisplayDataByNote.removeValue(forKey: noteCode)
            
            noteDisplayData.labelNode.run(noteDisplayData.disappearAction, completion: {
                
                self.removeChildren(in: [noteDisplayData.labelNode, noteDisplayData.springAnchorNode])
                self.physicsWorld.remove(noteDisplayData.springJoint)
            })
        }
        
        if Note(fromNoteCode: noteCode) == currentQuestionSolutionNote, self.currentQuestionSolutionNoteGiven {
            
            self.loadNextQuestion()
            self.updateQuestionUI()
        }
    }
}
