
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    
    var currentNotePosition: CGFloat = 0.0
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
    }
    
    
    func onNotesChanged(notesGoingOn: Set<UInt>, notesGoingOff: Set<UInt>) {
        
        if !notesGoingOn.isEmpty {
            onNotesGoingOn(notesGoingOn)
        }
    }
    
    
    func onNotesGoingOn(_ notes: Set<UInt>) {
        
        let labelNode = SKLabelNode()
        
        labelNode.text =  [UInt](notes).sorted().map { String(describing: Note.fromNoteCode($0)).uppercased() } .joined(separator: " ")
        
        labelNode.position = CGPoint(x: currentNotePosition, y: 0)
        
        defaultCamera.position = labelNode.position
        
        currentNotePosition += 100
        
        addChild(labelNode)
    }
}


extension Note {
    
    
    static func fromNoteCode(_ code: UInt) -> Note {
        
        return Note.allCases[(Int(code) - 60 + 8*12) % Note.allCases.count]
    }
}
