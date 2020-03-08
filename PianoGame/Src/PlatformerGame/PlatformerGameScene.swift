
import SpriteKit



class PlatformerGameScene: SKScene {
    
    
    var targetsByNote: [Note: SKNode] = [:]
    
    var playerCharacterNode: SKNode!
    
    
    override func didMove(to view: SKView) {
        
        self.initScene()
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        for note in Note.allCases.filter({ !$0.isSharp }) {
            
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.position = CGPoint(x: (-Int(self.size.width)/2...Int(self.size.width)/2).randomElement()!,
                                         y: (-Int(self.size.height)/2...Int(self.size.height)/2).randomElement()!)
            self.addChild(labelNode)
            
            self.targetsByNote[note] = labelNode
        }
        
        self.playerCharacterNode = SKSpriteNode(imageNamed: "jump outline")
        self.addChild(self.playerCharacterNode)
    }
}
