
import Foundation
import SpriteKit
import MIKMIDI


class IntervalQuizScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    var referenceNote: Note!
    var intervalLength: UInt!
    var expectedNote: Note!
    var expectedNotePlayed = false
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.connectToMIDIDevice()
        self.pickExercise()
        self.redraw()
    }
    
    
    override func didChangeSize(_ oldSize: CGSize) {
        
        self.redraw()
    }
    
    
    func connectToMIDIDevice() {
        
        let device = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == MIDIDeviceName })!
        
        try! MIKMIDIDeviceManager.shared.connect(device) { (_, commands) in
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    if noteOnCommand.velocity > 0 {
                        self.onNoteOn(noteOnCommand.note)
                    }
                }
            }
        }
    }
    
    
    func onNoteOn(_ code: UInt) {
        
        if Note.fromNoteCode(code) == expectedNote {
            
            expectedNotePlayed = true
            self.redraw()
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                
                self.pickExercise()
                self.redraw()
            }
        }
    }
    
    
    func pickExercise() {
        
        referenceNote = Note.allCases.randomElement()
        intervalLength = UInt.random(in: 0...11)
        expectedNote = Note.allCases[(Note.allCases.firstIndex(of: referenceNote!)! + Int(intervalLength)) % 12]
        expectedNotePlayed = false
    }
    
    
    func redraw() {
        
        self.removeAllChildren()
        
        guard let referenceNote = referenceNote
             ,let intervalLength = intervalLength
             ,let expectedNote = expectedNote
        else { return }
        
        let referenceNoteLabel = SKLabelNode(text: referenceNote.description.uppercased())
        referenceNoteLabel.position = CGPoint(x: -2 * (self.frame.width/2)/3, y: 0)
        self.addChild(referenceNoteLabel)
        
        let expectedNoteLabel = SKLabelNode(text: expectedNotePlayed ? expectedNote.description.uppercased() : "?")
        expectedNoteLabel.position = CGPoint(x: +2 * (self.frame.width/2)/3, y: 0)
        self.addChild(expectedNoteLabel)
        
        let intervalNameLabel = SKLabelNode(text: String(describing: Interval(from: intervalLength)))
        intervalNameLabel.position = CGPoint(x: 0, y: +intervalNameLabel.calculateAccumulatedFrame().height/2 + 10)
        self.addChild(intervalNameLabel)
        
        let intervalLengthLabel = SKLabelNode(text: "\(Double(intervalLength)/2.0)T")
        intervalLengthLabel.fontSize *= 0.8
        intervalLengthLabel.position = CGPoint(x: 0, y: -intervalLengthLabel.calculateAccumulatedFrame().height/2 - 10)
        self.addChild(intervalLengthLabel)
    }
}
