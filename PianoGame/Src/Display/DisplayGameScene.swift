
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
        
        notes.forEach { note in
        
            let timeIntervalSinceStart = DateInterval(start: dateStart, end: Date()).duration
            let distanceToReferencePoint = CGFloat(timeIntervalSinceStart) * displaySpeed
            let position = referencePosition + distanceToReferencePoint
            
            let minimumNoteCode: UInt = 21
            let maximumNoteCode: UInt = 107
            
            let noteCodeStartingAtZero = note - minimumNoteCode // [0; max]
            let noteCodeFractionnal = Double(noteCodeStartingAtZero) / Double(maximumNoteCode - minimumNoteCode + 2) // [0; 1]
            let noteCodeFractionnalCentered = (noteCodeFractionnal - 0.5) * 2   // [-1; 1]
            let scaleFactor: Double = Double(self.size.height) / 2.0 * 0.9
            let noteCodeFractionnalCenteredScaled = noteCodeFractionnalCentered * scaleFactor    // [-h/2; +h/2]
            
            let labelNode = SKLabelNode()
            labelNode.text =  String(describing: Note.fromNoteCode(note)).uppercased()
            labelNode.position = CGPoint(x: position, y: CGFloat(noteCodeFractionnalCenteredScaled))
            
            addChild(labelNode)
        }
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


extension Note: CustomStringConvertible {
    
    
    var description: String {
        
        let mapping: [Note: String] = [
            .c: "C",
            .c_sharp: "C#",
            .d: "D",
            .d_sharp: "D#",
            .e: "E",
            .f: "F#",
            .f_sharp: "F#",
            .g: "G",
            .g_sharp: "G#",
            .a: "A",
            .a_sharp: "A#",
            .b: "B",
        ]
        
        return mapping[self]!
    }
}
