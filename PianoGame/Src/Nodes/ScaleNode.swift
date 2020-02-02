
import SpriteKit


class ScaleNode: SKNode {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(startingWith firstText: String) {
        
        super.init()
        
        let values = [firstText, "", "2", "", "3", "4", "", "5", "", "6", "", "7"]
        
        var x: CGFloat = 0
        for value in values {
            let circleNode = CircleTextNode(text: value)
            self.addChild(circleNode)
            circleNode.position = CGPoint(x: x, y: 0)
            x += circleNode.frame.width
        }
    }
}
