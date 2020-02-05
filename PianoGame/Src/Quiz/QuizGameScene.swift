
import Foundation
import SpriteKit


class QuizGameScene: SKScene {
    
    
    var labelNode: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        labelNode = SKLabelNode()
        
        addChild(labelNode)
    }
}
