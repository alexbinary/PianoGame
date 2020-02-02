
import SpriteKit


class SpikesNode: SKShapeNode {
    
    
    static let nodeName = "spikes"
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(ofWidth width: CGFloat) {
        
        super.init()
        
        let rectSize = CGSize(width: width, height: 50)
        let rect = CGRect(x: 0, y: 0, width: rectSize.width, height: rectSize.height)
        self.path = CGPath(rect: rect, transform: nil)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rectSize.width / 2.0, y: rectSize.height / 2.0))
        self.physicsBody?.friction = 100
        self.physicsBody?.allowsRotation = false
        self.name = SpikesNode.nodeName
    }
}
