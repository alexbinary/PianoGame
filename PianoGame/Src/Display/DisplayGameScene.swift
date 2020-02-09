
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    
    var referencePosition: CGFloat = 0.0
    var dateStart: Date!
    
    let displaySpeed: CGFloat = 100    // points per second
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        dateStart = Date()
    }
    
    
    override func didFinishUpdate() {
        
        let timeIntervalSinceStart = DateInterval(start: dateStart, end: Date()).duration
        let distanceToReferencePoint = CGFloat(timeIntervalSinceStart) * displaySpeed
        let position = referencePosition + distanceToReferencePoint
        
        defaultCamera.position = CGPoint(x: position, y: 0)
    }
    
    
    func onNotesChanged(notesGoingOn: Set<UInt>, notesGoingOff: Set<UInt>) {
        
        if !notesGoingOn.isEmpty {
            onNotesGoingOn(notesGoingOn)
        }
    }
    
    
    func onNotesGoingOn(_ notes: Set<UInt>) {
        
        let timeIntervalSinceStart = DateInterval(start: dateStart, end: Date()).duration
        let distanceToReferencePoint = CGFloat(timeIntervalSinceStart) * displaySpeed
        let position = referencePosition + distanceToReferencePoint
        
        let labelNode = SKLabelNode()
        labelNode.text =  [UInt](notes).sorted().map { String(describing: Note.fromNoteCode($0)).uppercased() } .joined(separator: " ")
        labelNode.position = CGPoint(x: position, y: 0)
        
        addChild(labelNode)
    }
}


extension Note {
    
    
    static func fromNoteCode(_ code: UInt) -> Note {
        
        let originalNoteCode = Int(code)
        let C4NoteCode = 60
        let noteCodeRelativeToC4 = originalNoteCode - C4NoteCode    // align code on the 4th octave
        let finalNoteCode = noteCodeRelativeToC4 + 5*12 // add as many octaves as needed to guarantee the code is always positive while staying properly aligned on the octaves
        
        return Note.allCases[finalNoteCode % Note.allCases.count]
    }
}
