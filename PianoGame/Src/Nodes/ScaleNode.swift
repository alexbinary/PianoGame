
import SpriteKit


class ScaleNode: SKNode {
    
    
    static let circleSize: CGFloat = 50
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(startingWith firstText: String, numberOfElements: Int) {
        
        super.init()
        
        let values = [firstText, "", "2", "", "3", "4", "", "5", "", "6", "", "7"]
        
        var x: CGFloat = 0
        for value in values[0..<numberOfElements] {
            let circleNode = CircleTextNode(text: value, size: ScaleNode.circleSize)
            self.addChild(circleNode)
            circleNode.position = CGPoint(x: x, y: 0)
            x += circleNode.frame.width
        }
    }
}
