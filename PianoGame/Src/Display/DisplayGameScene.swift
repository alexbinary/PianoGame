
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    
    var activeNotes: Set<UInt> = []
    var x: CGFloat = 0.0
    
    var detectedChords: Set<String> = []
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        self.physicsWorld.gravity.dy = -1
    }
    
    
    func noteChanged(on: Set<UInt>, off: Set<UInt>) {
        
        activeNotes = activeNotes.union(on).subtracting(off)
        
        updateNoteLabel()
        
        detectChords()
        
        updateChordLabel()
}
    
    
    func detectChords() {
        
        detectedChords.removeAll()
        
        let notes = Set<UInt>(activeNotes)
        
        let mappedNotes = Set<Note>(notes.map { Note.fromNoteCode($0) })

        if mappedNotes == Set<Note>([.c, .e, .g]) {

            detectedChords.insert("CM")
        }
    }
    
    
    func updateNoteLabel() {

        let labelNode = SKLabelNode()
        
        let notes = Set<UInt>(activeNotes)
        
        labelNode.text =  [UInt](notes).sorted().map { String(describing: Note.fromNoteCode($0)).uppercased() } .joined(separator: " ")
        
        labelNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        
        labelNode.position = CGPoint(x: x, y: 0)
        
        defaultCamera.position = labelNode.position
        
        x += 10
        
        addChild(labelNode)
    }
    
    
    func updateChordLabel() {

        let labelNode = SKLabelNode()
        
        labelNode.text = detectedChords.joined(separator: " - ")
        
        print("detected chords: \(String(describing: detectedChords))")
        
        labelNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        
        labelNode.position = CGPoint(x: x, y: 200)
        
        addChild(labelNode)
    }
}


extension Note {
    
    
    static func fromNoteCode(_ code: UInt) -> Note {
        
        return Note.allCases[(Int(code) - 60 + 8*12) % Note.allCases.count]
    }
}
