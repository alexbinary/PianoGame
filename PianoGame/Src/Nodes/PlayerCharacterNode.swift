
import SpriteKit


class PlayerCharacterNode: SKNode {
    
    
    static let nodeName = "player"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        let rectSize = CGSize(width: 50, height: 100)
        let shape = SKShapeNode(rectOf: rectSize)
        
        addChild(shape)

        self.physicsBody = SKPhysicsBody(rectangleOf: rectSize)
        self.physicsBody?.friction = 100
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.contactTestBitMask = 1
        self.name = PlayerCharacterNode.nodeName
    }
}
