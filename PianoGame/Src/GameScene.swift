
import Foundation
import SpriteKit


class GameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    var playerCharacter: PlayerCharacterNode!
    var ground1: GroundNode!
    var ground2: GroundNode!
    var spikes: SpikesNode!
    
    var scaleNode: ScaleNode!
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        playerCharacter = PlayerCharacterNode()
        playerCharacter.physicsBody?.contactTestBitMask = 1
        self.addChild(playerCharacter)
        resetPlayerPosition()
        
        ground1 = GroundNode(ofSize: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        self.addChild(ground1)
        ground1.position = CGPoint(x: -ground1.frame.width / 2.0, y: -ground1.frame.height)
        
        ground2 = GroundNode(ofSize: CGSize(width: view.frame.width, height: view.frame.height / 2.0))
        self.addChild(ground2)
        ground2.position = CGPoint(x: ground1.frame.maxX + 4 * ScaleNode.circleSize, y: -ground2.frame.height)
        
        spikes = SpikesNode(ofWidth: 100)
        spikes.physicsBody?.contactTestBitMask = 1
        self.addChild(spikes)
        spikes.position = CGPoint(x: ground2.frame.minX + 100, y: ground2.frame.maxY)
        
        scaleNode = ScaleNode(startingWith: "A", numberOfElements: 4)
        self.addChild(scaleNode)
        scaleNode.position = CGPoint(x: ground1.frame.maxX - ScaleNode.circleSize, y: ground1.frame.maxY - ScaleNode.circleSize)
        
        physicsWorld.contactDelegate = self
    }
    
    
    func midiEvent(note: UInt, velocity: UInt) {
        
        playerCharacter.physicsBody?.applyImpulse(CGVector(dx: 100, dy: Int(velocity) * 5))
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        playerCharacter.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 50))
    }
    
    
    override func didFinishUpdate() {
        
        camera?.position.x = playerCharacter.position.x
        
        if playerCharacter.position.y < -10 {
           gameoverFlag = true
        }
        
        if gameoverFlag {
            gameover()
        }
    }
    
    
    func gameover() {
        
        resetPlayerPosition()
        
        gameoverFlag = false
    }
    
    var gameoverFlag = false
    
    
    func resetPlayerPosition() {
        
        playerCharacter.physicsBody?.velocity = CGVector.zero
        playerCharacter.position = CGPoint(x: 0, y: 0)
    }
}


extension GameScene : SKPhysicsContactDelegate {
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let names = Set([contact.bodyA.node?.name, contact.bodyB.node?.name])
        if names.contains(PlayerCharacterNode.nodeName) && names.contains("spikes") {
            
            gameoverFlag = true
        }
    }
}
