
import Foundation
import SpriteKit
import MIKMIDI



class PhysicsDisplayScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    struct ColorPalette {
        
        let backgroundColor: NSColor
        let foregroundColor: NSColor
    }
    
    let colorPaletteDefault = ColorPalette(
        
        backgroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1)
    )
    
    let colorPaletteDarkMode = ColorPalette(
        
        backgroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
    )
    
    var colorPalette: ColorPalette?
    
    
    let baseline: CGFloat = 0
    
    
    struct NoteAvatar {
        
        let springAnchorNode: SKNode!
        let labelNode: SKNode!
        let springJoint: SKPhysicsJointSpring
        let disappearAction: SKAction
    }
    
    var noteAvatarsByNote: [NoteCode: NoteAvatar] = [:]
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initScene() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Attempted to use color palette but it was not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
        
        self.physicsWorld.gravity = .zero
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
        
        let minimumNoteCode: UInt = 21
        let maximumNoteCode: UInt = 107
        let noteCodeSpan: UInt = maximumNoteCode - minimumNoteCode
        let noteCodeFromZero: UInt = noteCode - minimumNoteCode
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let note = Note(fromNoteCode: noteCode)
        
        // create label
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Attempted to use color palette but it was not defined.")
        }
        
        let labelNode = SKLabelNode(text: note.description.uppercased())
        labelNode.fontColor = colorPalette.foregroundColor
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        
        let horizontalStep: CGFloat = self.frame.width / CGFloat(noteCodeSpan + 2)
        let xPosition = -self.frame.width/2.0 + CGFloat(noteCodeFromZero + 1) * horizontalStep
        
        labelNode.position = CGPoint(x: xPosition, y: baseline + 5)
         
        // configure spring system
        
        labelNode.physicsBody = SKPhysicsBody(circleOfRadius: labelNode.calculateAccumulatedFrame().size.width/2.0)
        labelNode.physicsBody?.allowsRotation = false
        labelNode.physicsBody?.categoryBitMask = 2
        labelNode.physicsBody?.collisionBitMask = 2
        
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
        
        let jiggleDuration: Double = 0.02
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor)
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
        
        noteAvatarsByNote[noteCode] = NoteAvatar(springAnchorNode: springAnchorNode,
                                                labelNode: labelNode,
                                                springJoint: springJoint,
                                                disappearAction: disappearAction)
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
        
        if let avatar = noteAvatarsByNote[noteCode] {
            
            noteAvatarsByNote.removeValue(forKey: noteCode)
            
            avatar.labelNode.run(avatar.disappearAction, completion: {
                
                self.removeChildren(in: [avatar.springAnchorNode, avatar.labelNode])
                self.physicsWorld.remove(avatar.springJoint)
            })
        }
    }
}
