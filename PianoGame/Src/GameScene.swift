
import Foundation
import SpriteKit


class GameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    var playerCharacter: PlayerCharacterNode!
    var ground1: SKNode!
    var ground2: SKNode!
    var spikes: SKNode!
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        playerCharacter = PlayerCharacterNode()
        self.addChild(playerCharacter)
        playerCharacter.position = CGPoint(x: 0, y: 200)
        
        ground1 = SKShapeNode(rectOf: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        self.addChild(ground1)
        ground1.position = CGPoint(x: 0, y: -view.frame.height / 4.0)
        ground1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        ground1.physicsBody?.isDynamic = false
        
        ground2 = SKShapeNode(rectOf: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        self.addChild(ground2)
        ground2.position = CGPoint(x: view.frame.width + 200, y: -view.frame.height / 4.0)
        ground2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        ground2.physicsBody?.isDynamic = false
        
        spikes = SKShapeNode(rectOf: CGSize(width: 100, height: 50))
        self.addChild(spikes)
        spikes.position = CGPoint(x: ground2.frame.minX + 100, y: ground2.frame.maxY + 50 / 2.0)
        spikes.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 50))
        spikes.physicsBody?.isDynamic = false
        spikes.physicsBody?.contactTestBitMask = 1
        spikes.name = "spikes"
        
        physicsWorld.contactDelegate = self
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        playerCharacter.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 50))
    }
    
    
    override func didFinishUpdate() {
        
        camera?.position.x = playerCharacter.position.x
        
        if playerCharacter.position.y < 0 {
           gameoverFlag = true
        }
        
        if gameoverFlag {
            gameover()
        }
    }
    
    
    func gameover() {
        
        playerCharacter.physicsBody?.velocity = CGVector.zero
        playerCharacter.position = CGPoint(x: 0, y: 200)
        
        gameoverFlag = false
    }
    
    var gameoverFlag = false
}


extension GameScene : SKPhysicsContactDelegate {
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let names = Set([contact.bodyA.node?.name, contact.bodyB.node?.name])
        if names.contains(PlayerCharacterNode.nodeName) && names.contains("spikes") {
            
            gameoverFlag = true
        }
    }
}
