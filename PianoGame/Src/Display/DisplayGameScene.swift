
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    
    var activeNotes: Set<UInt> = []
    var x: CGFloat = 0.0
    
    var lastNotes: Set<UInt> = []
    var lastTimestamp: Date!
    var lastTimestampNote: UInt!
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        self.physicsWorld.gravity.dy = -1
    }
    
    
    func noteChanged(on: Set<UInt>, off: Set<UInt>) {
        
        activeNotes = on
        
        updateNoteLabel()
        
        on.forEach { self.processNote($0) }
        
        if !on.isEmpty {
            updateChordLabel()
        }
    }
    
    
    func processNote(_ noteCode: UInt) {
        
        if lastTimestamp != nil && DateInterval(start: lastTimestamp!, end: Date()).duration < TimeInterval(0.5) {
            
            lastNotes.insert(lastTimestampNote)
            lastNotes.insert(noteCode)
        }
        else {
            
            lastNotes.removeAll()
        }
        
        lastTimestamp = Date()
        lastTimestampNote = noteCode
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
        
        let notes = Set<UInt>(lastNotes)
        
        var detectedChord = ""
        
        let mappedNotes = Set<Note>(notes.map { Note.fromNoteCode($0) })
        
        if mappedNotes == Set<Note>([.c, .e, .g]) {
            
            detectedChord = "CM"
        }
        
        labelNode.text = [UInt](notes).sorted().map { String(describing: Note.fromNoteCode($0)).uppercased() } .joined(separator: " ") + " (\(detectedChord))"
        
        print("simultaneous notes detected: \(String(describing: labelNode.text))")
        
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
