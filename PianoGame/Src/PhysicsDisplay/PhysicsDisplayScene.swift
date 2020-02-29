
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
    
    
    var disruptiveNode: SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.configureColorPalette()
        self.initStaticUI()
        
        self.createElements()
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initStaticUI() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Attempted to use color palette but it was not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        
        if disruptiveNode == nil {
        
            let size = CGSize(width: 50, height: 50)
            
            disruptiveNode = SKSpriteNode(color: .yellow,
                                          size: size)
            disruptiveNode.physicsBody = SKPhysicsBody(rectangleOf: size)
            disruptiveNode.physicsBody?.isDynamic = false
            
            self.addChild(disruptiveNode)
        }
        
        disruptiveNode.position = event.location(in: self)
    }
    
    
    func createElements() {
        
        let size = CGSize(width: 50, height: 50)
         
        let anchorNode = SKSpriteNode(color: .red,
                                  size: size)
        let jointNode = SKSpriteNode(color: .blue,
                                       size: size)
         
        anchorNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        anchorNode.physicsBody?.isDynamic = false
        anchorNode.position = CGPoint(x: 250, y: 300)
         
        jointNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        jointNode.physicsBody?.allowsRotation = false
        jointNode.position = CGPoint(x: 250, y: 200)
         
        self.addChild(anchorNode)
        self.addChild(jointNode)
         
        let spring = SKPhysicsJointSpring.joint(withBodyA: anchorNode.physicsBody!,
                                                bodyB: jointNode.physicsBody!,
                                                anchorA: anchorNode.position,
                                                anchorB: jointNode.position)
         
        spring.frequency = 0.5
        spring.damping = 0.2
         
        self.physicsWorld.add(spring)
        self.physicsWorld.gravity = .zero
    }
}
