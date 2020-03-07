
import SpriteKit


class PlayerCharacterNode: GenericRectanglePhysicsNode {
    
    
    static let nodeName = "player"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(ofSize: CGSize(width: 50, height: 100))
        
        self.physicsBody?.friction = 100
        self.physicsBody?.allowsRotation = false
        self.name = PlayerCharacterNode.nodeName
    }
}
