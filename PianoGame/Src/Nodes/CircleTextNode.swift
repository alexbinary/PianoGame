
import SpriteKit


class CircleTextNode: SKShapeNode {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(text: String) {
        
        super.init()
        
        let circleSize = 50
        self.path = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: circleSize, height: circleSize), transform: nil)
        
        let textNode = SKLabelNode(text: text)
        self.addChild(textNode)
        textNode.position = CGPoint(x: self.frame.width / 2.0 - textNode.frame.width / 2.0, y: self.frame.height / 2.0 - textNode.frame.height / 2.0)
    }
}
