
import Cocoa
import SpriteKit
import MIKMIDI


class DisplayViewController: NSViewController {
    
    
    var scene: DisplayGameScene!
    
    var synth: MIKMIDISynthesizer!
    
    
    // game parameters
    let useComputerSound = false     // false to use native device sound, true to let the app generate the sounds
    let useEmulatedInput = true     // false to use device input, true to emulate device input from a MIDI file
    
    // control flags derived from game parameters
    var synthInputCommands: Bool { return useComputerSound }
    var sendEmulatedInputToDevice: Bool { return !useComputerSound }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        scene = DisplayGameScene()
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        
        let alesisDevice = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!
        
        try! MIKMIDIDeviceManager.shared.connect(alesisDevice) { (_, commands) in
                
            print("commands from device: \(commands)")
            
            self.onCommands(commands)
        }
        
        let url = Bundle.main.url(forResource: "sample", withExtension: "mid")!
        
        let sequence = try! MIKMIDISequence(fileAt: url)
        print("MIDI sequence has \(sequence.tracks.count) track(s)")
        print("Track 0 has \(sequence.tracks[0].events.count) event(s): \(sequence.tracks[0].events)")
        
        let sequencer = MIKMIDISequencer(sequence: sequence)
        sequencer.shouldCreateSynthsIfNeeded = false
        sequencer.setCommandScheduler(self, for: sequence.tracks[1])
        sequencer.setCommandScheduler(self, for: sequence.tracks[2])
        
        if useEmulatedInput {
            sequencer.startPlayback()
        }
        
        synth = MIKMIDISynthesizer()
    }
    
    
    func onCommands(_ commands: [MIKMIDICommand]) {
        
        if synthInputCommands {
            synth.handleMIDIMessages(commands)
        }
        
        commands.forEach { command in
            
            print("now: \(Date()) - command timestamp: \(command.timestamp)")
            
            if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                
                if noteOnCommand.velocity > 0 {
                    
                    scene.noteOn(noteOnCommand.note)
                
                } else {
                    
                    scene.noteOff(noteOnCommand.note)
                }
            }
            else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    
                scene.noteOff(noteOffCommand.note)
            }
        }
    }
}


extension DisplayViewController: MIKMIDICommandScheduler {
    
    
    func scheduleMIDICommands(_ commands: [MIKMIDICommand]) {
        
        print("commands from sequencer: \(commands)")
        
        onCommands(commands)
        
        if sendEmulatedInputToDevice {
            try! MIKMIDIDeviceManager.shared.send(commands, to: MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!.entities.first!.destinations.first!)
        }
    }
}
