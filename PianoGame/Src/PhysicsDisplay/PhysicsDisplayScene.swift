
import Foundation
import SpriteKit
import MIKMIDI



class PhysicsDisplayScene: SKScene {
    
    
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
    
    
    var disruptiveNode: SKShapeNode!
    
    
    struct SpringSystem {
        
        let anchorNode: SKNode!
        let jointNode: SKNode!
        let springJoint: SKPhysicsJointSpring
    }
    
    var springSystems: [SpringSystem] = []
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
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
    
    
    override func mouseDragged(with event: NSEvent) {
        
        if disruptiveNode == nil {
        
            let radius: CGFloat = 25
            
            disruptiveNode = SKShapeNode(circleOfRadius: radius)
            disruptiveNode.fillColor = .yellow
            disruptiveNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            disruptiveNode.physicsBody?.isDynamic = false
            disruptiveNode.physicsBody?.friction = 0
            
            self.addChild(disruptiveNode)
        }
        
        disruptiveNode.position = event.location(in: self)
    }
    
    
    override func mouseDown(with event: NSEvent) {
        
        self.createSpringSystem(at: CGPoint(x: (-Int(self.size.width/2.0)...Int(self.size.width/2.0)).randomElement()!, y: 300))
    }
    
    
    override func rightMouseDown(with event: NSEvent) {
        
        if let index = springSystems.indices.randomElement() {

            let system = springSystems[index]
            springSystems.remove(at: index)
            
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
    
    
    func createSpringSystem(at position: CGPoint) {
        
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
        
        springSystems.append(SpringSystem(anchorNode: anchorNode, jointNode: jointNode, springJoint: spring))
    }
}
