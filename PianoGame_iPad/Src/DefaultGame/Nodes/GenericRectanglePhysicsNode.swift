
import SpriteKit


class GenericRectanglePhysicsNode: SKShapeNode {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(ofSize size: CGSize) {
        
        super.init()
        
        let rectSize = size
        let rect = CGRect(x: 0, y: 0, width: rectSize.width, height: rectSize.height)
        self.path = CGPath(rect: rect, transform: nil)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rectSize.width / 2.0, y: rectSize.height / 2.0))
    }
}
