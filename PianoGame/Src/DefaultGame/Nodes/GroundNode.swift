
import SpriteKit


class GroundNode: GenericRectanglePhysicsNode {
    
    
    static let nodeName = "ground"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(ofSize size: CGSize) {
        
        super.init(ofSize: size)
        
        self.physicsBody?.isDynamic = false
        self.name = GroundNode.nodeName
    }
}
