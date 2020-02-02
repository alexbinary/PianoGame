
import Foundation
import SpriteKit


class GameScene: SKScene {
    
    
    var label: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        
        label = SKLabelNode(text: "Hello")
        
        addChild(label)
        label.fontSize = 128
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        label.text = "Hi"
    }
}
