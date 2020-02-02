
import Foundation
import SpriteKit


class GameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    var playerCharacter: SKShapeNode!
    var backgroundElement: SKNode!
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        playerCharacter = SKShapeNode(rectOf: CGSize(width: 50, height: 100))
        self.addChild(playerCharacter)
        
        backgroundElement = SKShapeNode(ellipseOf: CGSize(width: 50, height: 50))
        self.addChild(backgroundElement)
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        let action = SKAction.moveBy(x: 10, y: 0, duration: 1)
        playerCharacter.run(action)
    }
    
    
    override func didFinishUpdate() {
        
        camera?.position = playerCharacter.position
    }
}
