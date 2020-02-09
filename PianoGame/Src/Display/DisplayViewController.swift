
import Cocoa
import SpriteKit
import MIKMIDI


class DisplayViewController: NSViewController {
    
    
    var scene: DisplayGameScene!
    
    var synth: MIKMIDISynthesizer!
    
    
    // game parameters
    let useComputerSound = false     // false to use native device sound, true to let the app generate the sounds
    let useEmulatedInput = true     // false to use device input, true to emulate device input from a MIDI file
    let emulatedInputFilename = "wedding"   // without extension, assumed to be .mid
    let emulatedInputStartPlaybackTime: MusicTimeStamp = 0
    
    // control flags derived from game parameters
    var synthInputCommands: Bool { return useComputerSound }
    var sendEmulatedInputToDevice: Bool { return !useComputerSound }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initScene()
        connectToDevice()
        
        if synthInputCommands {
            synth = MIKMIDISynthesizer()
        }
        
        if useEmulatedInput {
            startEmulatedInput()
        }
    }
    
    
    func initScene() {
        
        scene = DisplayGameScene()
        scene.scaleMode = .resizeFill
        
        (view as! SKView).presentScene(scene)
    }
    
    
    func connectToDevice() {
        
        let alesisDevice = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!
        
        try! MIKMIDIDeviceManager.shared.connect(alesisDevice) { (_, commands) in
            print("received commands from device: \(commands)")
            self.onCommands(commands)
        }
    }
    
    
    func startEmulatedInput() {
        
        let url = Bundle.main.url(forResource: emulatedInputFilename, withExtension: "mid")!
        
        let sequence = try! MIKMIDISequence(fileAt: url)
        print("MIDI sequence has \(sequence.tracks.count) track(s)")
        print("Track 0 has \(sequence.tracks[0].events.count) event(s): \(sequence.tracks[0].events)")
        
        let sequencer = MIKMIDISequencer(sequence: sequence)
        sequencer.shouldCreateSynthsIfNeeded = false
        sequence.tracks.forEach { sequencer.setCommandScheduler(self, for: $0) }

        sequencer.startPlayback(atTimeStamp: emulatedInputStartPlaybackTime)
    }
    
    
    func onCommands(_ commands: [MIKMIDICommand]) {
        
        if synthInputCommands {
            synth.handleMIDIMessages(commands)
        }
        
        var on: Set<UInt> = []
        var off: Set<UInt> = []
        
        commands.forEach { command in
            if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                if noteOnCommand.velocity > 0 {
                    on.insert(noteOnCommand.note)
                } else {
                    off.insert(noteOnCommand.note)
                }
            }
            else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                off.insert(noteOffCommand.note)
            }
        }
        
        scene.noteChanged(on: on, off: off)
    }
}


extension DisplayViewController: MIKMIDICommandScheduler {
    
    
    func scheduleMIDICommands(_ commands: [MIKMIDICommand]) {
        
        print("received commands from sequencer: \(commands)")
        
        onCommands(commands)
        
        if sendEmulatedInputToDevice {
            try! MIKMIDIDeviceManager.shared.send(commands, to: MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!.entities.first!.destinations.first!)
        }
    }
}
