
import Foundation
import SpriteKit
import MIKMIDI



typealias NoteCode = UInt


struct NoteData {
    
    let node: SKNode
    let disappearAction: SKAction
}


class Display2Scene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    var noteDataByNote: [NoteCode: NoteData] = [:]
    
    
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
        let noteCodeSpan: UInt = maximumNoteCode - minimumNoteCode
        let noteCodeFromZero: UInt = code - minimumNoteCode
        
        let note = Note(fromNoteCode: code)
        let labelNode = SKLabelNode(text: note.description.uppercased())
        
        let horizontalStep: CGFloat = self.frame.width / CGFloat(noteCodeSpan + 2)
        let verticalDispatch: CGFloat = 100
        
        labelNode.position = CGPoint(
            x: -self.frame.width/2.0 + CGFloat(noteCodeFromZero + 1) * horizontalStep,
            y: verticalDispatch * CGFloat(note.isSharp ? 1 : -1))
        
        // general animation settings
        
        let appearDuration: Double = 0.1
        let fadeOutDuration: Double = 10
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        let velocityFactor: Double = Double(velocity)/128.0
        let scaleUpAmplitude: CGFloat = 10
        
        let appearScaleAction = SKAction.scale(to: scaleUpAmplitude * CGFloat(velocityFactor), duration: appearDuration)
        let fadeOutScaleAction = SKAction.scale(to: 0, duration: fadeOutDuration * velocityFactor)
        let disappearScaleAction = SKAction.scale(to: 0, duration: disappearDuration)
        
        // animate fadeout
        
        let fadeOutFadeAction = SKAction.fadeOut(withDuration: fadeOutDuration * velocityFactor)
        
        // animate jiggle
        
        let jiggleDuration: Double = 0.02
        let jiggleAmplitude: CGFloat = .pi/24.0
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0*jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        // compose final animation
        
        let appearAndFadeOutAction = SKAction.group([
            SKAction.sequence([
                appearScaleAction,
                SKAction.group([fadeOutScaleAction, fadeOutFadeAction])
            ]),
            jiggleAction
        ])
        let disappearAction = disappearScaleAction
        
        // setup an animate
        
        labelNode.setScale(0)
        
        addChild(labelNode)
        labelNode.run(appearAndFadeOutAction)
        
        // register data for teardown
        
        self.noteDataByNote[code] = NoteData(node: labelNode, disappearAction: disappearAction)
    }
    
    
    func onNoteOff(_ code: UInt) {
        
        if let data = self.noteDataByNote[code] {
            data.node.run(data.disappearAction, completion: {
                self.removeChildren(in: [data.node])
                self.noteDataByNote[code] = nil
            })
        }
    }
}
