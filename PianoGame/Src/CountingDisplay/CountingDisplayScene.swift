
import Foundation
import SpriteKit
import MIKMIDI



class CountingDisplayScene: SKScene {
    
    
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
    
    
    var noteDisplayNoteByNote: [Note: SKNode] = [:]
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        self.initStaticUI()
        
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
    }
    
    
    func initStaticUI() {
    
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
    
        let noteSize: CGFloat = 50
        
        for (index, note) in Note.allCases.enumerated() {
        
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.fontColor = colorPalette.foregroundColor
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
        
            let circleNode = SKShapeNode(circleOfRadius: noteSize / 2.0)
            circleNode.strokeColor = colorPalette.foregroundColor
            
            let horizontalSpan = noteSize * (12 + 1)
            let horizontalStep: CGFloat = horizontalSpan / (12.0 + 1)
            let xPosition = -horizontalSpan/2.0 + CGFloat(index + 1) * horizontalStep
            
            circleNode.position = CGPoint(x: xPosition, y: 0)
            
            circleNode.physicsBody = SKPhysicsBody(circleOfRadius: noteSize / 2.0)
            circleNode.physicsBody?.allowsRotation = false
            circleNode.physicsBody?.friction = 0
            circleNode.physicsBody?.restitution = 0
            circleNode.physicsBody?.categoryBitMask = 2
            circleNode.physicsBody?.collisionBitMask = 2
            
            circleNode.constraints = [SKConstraint.positionY(SKRange(constantValue: circleNode.position.y))]
            
            let springAnchorNode = SKShapeNode(circleOfRadius: 0)
            springAnchorNode.physicsBody = SKPhysicsBody(circleOfRadius: 1)
            springAnchorNode.physicsBody?.isDynamic = false
            springAnchorNode.physicsBody?.categoryBitMask = 1
            springAnchorNode.physicsBody?.collisionBitMask = 1
            springAnchorNode.position = circleNode.position
            
            let springJoint = SKPhysicsJointSpring.joint(withBodyA: springAnchorNode.physicsBody!,
                                                         bodyB: circleNode.physicsBody!,
                                                         anchorA: springAnchorNode.position,
                                                         anchorB: circleNode.position)
             
            springJoint.frequency = 10
            springJoint.damping = 5
            
            circleNode.addChild(labelNode)
            self.addChild(circleNode)
            self.addChild(springAnchorNode)
            self.physicsWorld.add(springJoint)
            
            noteDisplayNoteByNote[note] = circleNode
        }
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
        
        let nodeDisplayNode = noteDisplayNoteByNote[Note(fromNoteCode: noteCode)]!
        
        // general animation settings
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let scaleUpAmplitude: CGFloat = 2
        let appearDuration: Double = 0.1
        
        // animate scale
        
        let appearScaleAction = SKAction.scale(to: scaleUpAmplitude, duration: appearDuration)
        
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
        
        let appearAction = SKAction.group([
            appearScaleAction,
            jiggleAction
        ])
        
        // setup an animate
        
        nodeDisplayNode.run(appearAction)
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        let nodeDisplayNode = noteDisplayNoteByNote[Note(fromNoteCode: noteCode)]!
        
        // general animation settings
        
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        let disappearScaleAction = SKAction.scale(to: 1, duration: disappearDuration)
        
        // compose final animation
        
        let disappearAction = disappearScaleAction
        
        // setup an animate
        
        nodeDisplayNode.run(disappearAction)
    }
}
