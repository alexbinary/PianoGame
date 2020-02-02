
import SpriteKit


class SpikesNode: GenericRectanglePhysicsNode {
    
    
    static let nodeName = "spikes"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(ofWidth width: CGFloat) {
        
        super.init(ofSize: CGSize(width: width, height: 50))
        
        self.physicsBody?.isDynamic = false
        self.name = SpikesNode.nodeName
    }
}
