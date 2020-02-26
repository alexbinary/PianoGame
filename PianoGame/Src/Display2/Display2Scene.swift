
import Foundation
import SpriteKit
import MIKMIDI



typealias NoteCode = UInt


class Display2Scene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    var nodesByNote: [NoteCode: SKNode] = [:]
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.connectToMIDIDevice()
    }
    
    
    func connectToMIDIDevice() {
        
        let device = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == self.MIDIDeviceName })!
        
        try! MIKMIDIDeviceManager.shared.connect(device) { (_, commands) in
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    if noteOnCommand.velocity > 0 {
                        self.onNoteOn(note: noteOnCommand.note, velocity: noteOnCommand.velocity)
                    } else {
                        self.onNoteOff(noteOnCommand.note)
                    }
                } else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    self.onNoteOff(noteOffCommand.note)
                }
            }
        }
    }
    
    
    func onNoteOn(note code: UInt, velocity: UInt) {
        
        let minimumNoteCode: UInt = 21
        let maximumNoteCode: UInt = 107
        let noteCodeSpan = maximumNoteCode - minimumNoteCode
        let noteCodeFromZero = code - minimumNoteCode
        let step = self.frame.width / CGFloat(noteCodeSpan + 2)
        let referencePoint = -self.frame.width/2.0
        
        let note = Note(fromNoteCode: code)
        
        let x = referencePoint + CGFloat(noteCodeFromZero + 1) * step
        let y = CGFloat(note.isSharp ? 50 : 0)
        
        let labelNode = SKLabelNode(text: note.description.uppercased())
        labelNode.position = CGPoint(x: x, y: y)
        addChild(labelNode)
        
        let scaleUpAction = SKAction.scale(to: CGFloat(2*Double(velocity)/128.0), duration: 0.1)
        let scaleDownAction = SKAction.scale(to: 0, duration: 10*Double(velocity)/128.0*100)
        let fadeOutAction = SKAction.fadeOut(withDuration: 10*Double(velocity)/128.0)
        
        labelNode.setScale(0)
        labelNode.run(SKAction.sequence([scaleUpAction, SKAction.group([scaleDownAction, fadeOutAction])]))
        
        self.nodesByNote[code] = labelNode
        
        print(self.nodesByNote)
    }
    
    
    func onNoteOff(_ code: UInt) {
        
        if let node = self.nodesByNote[code] {
            
            self.removeChildren(in: [node])
            self.nodesByNote[code] = nil
            
            print(self.nodesByNote)
        }
    }
}
