
import SpriteKit


class PlayerCharacterNode: SKShapeNode {
    
    
    static let nodeName = "player"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        
        super.init()
        
        let rectSize = CGSize(width: 50, height: 100)
        let rect = CGRect(x: 0, y: 0, width: rectSize.width, height: rectSize.height)
        self.path = CGPath(rect: rect, transform: nil)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rectSize.width / 2.0, y: rectSize.height / 2.0))
        self.physicsBody?.friction = 100
        self.physicsBody?.allowsRotation = false
        self.name = PlayerCharacterNode.nodeName
    }
}
