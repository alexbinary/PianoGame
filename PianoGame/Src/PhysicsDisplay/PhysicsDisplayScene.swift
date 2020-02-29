
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
    
    
    struct SpringSystem {
        
        let anchorNode: SKNode!
        let jointNode: SKNode!
        let springJoint: SKPhysicsJointSpring
    }
    
    var springSystemsByNote: [NoteCode: SpringSystem] = [:]
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        
        self.createElements()
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
        
        let horizontalStep: CGFloat = self.frame.width / CGFloat(noteCodeSpan + 2)
        let xPosition = -self.frame.width/2.0 + CGFloat(noteCodeFromZero + 1) * horizontalStep
            
        springSystemsByNote[noteCode] = self.createSpringSystem(at: CGPoint(x: xPosition, y: 300))
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
        
        if let system = springSystemsByNote[noteCode] {
            
            springSystemsByNote.removeValue(forKey: noteCode)
            
            system.jointNode.run(SKAction.scale(to: 0, duration: 1), completion: {
                
                self.removeChildren(in: [system.anchorNode, system.jointNode])
                self.physicsWorld.remove(system.springJoint)
            })
        }
    }
    
    
    func createElements() {
         
        let radius: CGFloat = 25
        
        let edgeLoopSize = CGSize(width: 100000, height: radius * 2)
        let edgeLoopNode = SKNode()
        edgeLoopNode.physicsBody = SKPhysicsBody(edgeLoopFrom: CGPath(rect: CGRect(origin: .zero, size: edgeLoopSize), transform: nil))
        edgeLoopNode.physicsBody?.isDynamic = false
        edgeLoopNode.physicsBody?.friction = 0
        edgeLoopNode.position = CGPoint(x: -edgeLoopSize.width/2, y: 275)
        
        self.addChild(edgeLoopNode)
    }
    
    
    func createSpringSystem(at position: CGPoint) -> SpringSystem {
        
        let radius: CGFloat = 25
         
        let anchorNode = SKShapeNode(circleOfRadius: 1)
        anchorNode.fillColor = .red
        anchorNode.strokeColor = .red
        
        let jointNode = SKShapeNode(circleOfRadius: radius)
        jointNode.fillColor = .blue
         
        anchorNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        anchorNode.physicsBody?.isDynamic = false
        anchorNode.physicsBody?.friction = 0
        anchorNode.physicsBody?.categoryBitMask = 1
        anchorNode.physicsBody?.collisionBitMask = 1
        anchorNode.position = position + CGPoint(x: 0, y: -25)
        anchorNode.zPosition = -1
         
        jointNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        jointNode.physicsBody?.allowsRotation = false
        jointNode.physicsBody?.friction = 0
        jointNode.physicsBody?.categoryBitMask = 2
        jointNode.physicsBody?.collisionBitMask = 2
        jointNode.position = anchorNode.position
        
        self.addChild(anchorNode)
        self.addChild(jointNode)
        
        let spring = SKPhysicsJointSpring.joint(withBodyA: anchorNode.physicsBody!,
                                                bodyB: jointNode.physicsBody!,
                                                anchorA: anchorNode.position,
                                                anchorB: jointNode.position)
         
        spring.frequency = 0.5
        spring.damping = 0.2
         
        self.physicsWorld.add(spring)
        
        jointNode.setScale(0)
        
        jointNode.run(SKAction.scale(to: 1, duration: 1))
        
        return SpringSystem(anchorNode: anchorNode, jointNode: jointNode, springJoint: spring)
    }
}
