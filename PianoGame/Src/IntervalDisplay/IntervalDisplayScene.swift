
import Foundation
import SpriteKit
import MIKMIDI


class IntervalDisplayScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    var activeNoteCodes: Set<UInt> = []
    var activeNotes: Set<Note> { return Set<Note>(activeNoteCodes.map { Note.fromNoteCode($0) }) }
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.connectToMIDIDevice()
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
                    } else {
                        self.onNoteOff(noteOnCommand.note)
                    }
                } else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    self.onNoteOff(noteOffCommand.note)
                }
            }
        }
    }
    
    
    func onNoteOn(_ code: UInt) {
        
        self.activeNoteCodes.insert(code)
        self.redraw()
    }
    
    
    func onNoteOff(_ code: UInt) {
        
        self.activeNoteCodes.remove(code)
        self.redraw()
    }
    
    
    func redraw() {
        
        self.removeAllChildren()
        
        if activeNotes.count == 0 {
            
            self.drawStartupLabel()
            
        } else if activeNotes.count == 1 {
            
            self.drawNoteLabel([Note](activeNotes)[0], at: CGPoint(x: 0, y: 0))
            
        } else {
            
            let orderedNotes = activeNotes.map { (note: $0, index: Note.allCases.firstIndex(of: $0)!) } .sorted { $0.index < $1.index } . map { $0.note }
            let numberOfLines = orderedNotes.count - 1
            let referenceNote = orderedNotes.first!
            
            for k in 1...numberOfLines {
                
                let yk = CGFloat(self.frame.height)/2.0 - CGFloat(k) * CGFloat(self.frame.height)/CGFloat(numberOfLines + 1)
                let intervalNote = orderedNotes[k]
                let intervalLength = UInt(Note.allCases.firstIndex(of: intervalNote)! - Note.allCases.firstIndex(of: referenceNote)!)
                let intervalName = String(describing: Interval(from: intervalLength))
                self.drawIntervalLine(leftNote: referenceNote, rightNote: intervalNote, intervalLength: intervalLength, intervalName: intervalName, position: yk)
            }
        }
    }
    
    
    func drawStartupLabel() {
        
        let label = SKLabelNode(text: "Play one or more notes")
        label.position = CGPoint(x: 0, y: 0)
        self.addChild(label)
    }
    
    
    func drawNoteLabel(_ note: Note, at position: CGPoint) {
        
        let label = SKLabelNode(text: "\(note.description.uppercased())")
        label.position = position
        self.addChild(label)
    }
    
    
    func drawIntervalLine(leftNote: Note, rightNote: Note, intervalLength: UInt, intervalName: String, position: CGFloat) {
        
        self.drawNoteLabel(leftNote, at: CGPoint(x: -2 * (self.frame.width/2)/3, y: position))
        self.drawNoteLabel(rightNote, at: CGPoint(x: +2 * (self.frame.width/2)/3, y: position))
        
        let intervalNameLabel = SKLabelNode(text: intervalName)
        intervalNameLabel.position = CGPoint(x: 0, y: position + intervalNameLabel.calculateAccumulatedFrame().height/2 + 10)
        self.addChild(intervalNameLabel)
        
        let intervalLengthLabel = SKLabelNode(text: "\(Double(intervalLength)/2.0)T")
        intervalLengthLabel.position = CGPoint(x: 0, y: position - intervalLengthLabel.calculateAccumulatedFrame().height/2 - 10)
        intervalLengthLabel.fontSize *= 0.8
        self.addChild(intervalLengthLabel)
    }
}


enum Interval: CaseIterable {
    
    case P1
    case m2
    case M2
    case m3
    case M3
    case P4
    case A4
    case P5
    case m6
    case M6
    case m7
    case M7
    
    init(from semitones: UInt) {
        self = Interval.allCases[Int(semitones % 12)]
    }
}
