
import SpriteKit


class GroundNode: SKNode {
    
    
    static let nodeName = "ground"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(ofSize size: CGSize) {
        super.init()
        
        let shapeNode = SKShapeNode(rectOf: size)
        
        self.addChild(shapeNode)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
    }
}
