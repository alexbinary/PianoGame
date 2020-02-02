
import Foundation
import SpriteKit


class GameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    var playerCharacter: SKShapeNode!
    var backgroundElement: SKNode!
    var ground: SKNode!
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        playerCharacter = SKShapeNode(rectOf: CGSize(width: 50, height: 100))
        self.addChild(playerCharacter)
        playerCharacter.position = CGPoint(x: 0, y: 200)
        playerCharacter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 100))
        
        backgroundElement = SKShapeNode(ellipseOf: CGSize(width: 50, height: 50))
        self.addChild(backgroundElement)
        
        ground = SKShapeNode(rectOf: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        self.addChild(ground)
        ground.position = CGPoint(x: 0, y: -view.frame.height / 4.0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        ground.physicsBody?.isDynamic = false
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        let action = SKAction.moveBy(x: 10, y: 0, duration: 1)
        playerCharacter.run(action)
    }
    
    
    override func didFinishUpdate() {
        
        camera?.position = playerCharacter.position
    }
}
