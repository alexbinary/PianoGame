
import Cocoa
import SpriteKit
import MIKMIDI


class DefaultViewController: NSViewController {
    
    
    var synth: MIKMIDISynthesizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = DefaultGameScene()
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        
        guard let alesisDevice = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " }) else {
            fatalError("Could not find MIDI device")
        }
        
        guard let alesisEntity = alesisDevice.entities.first else {
            fatalError("MIDI device has no entity")
        }
        
        guard let alesisSource = alesisEntity.sources.first else {
            fatalError("MIDI entity has no source endpoints")
        }
        
        guard let alesisDestination = alesisEntity.destinations.first else {
            fatalError("MIDI entity has no destination endpoints")
        }
        
        do {
            try MIKMIDIDeviceManager.shared.send([
                MIKMIDINoteOnCommand(note: 60, velocity: 64, channel: 0, timestamp: Date()),
                MIKMIDINoteOffCommand(note: 60, velocity: 64, channel: 0, timestamp: Date().advanced(by: 0.5))
            ], to: alesisDestination)
        } catch {
            fatalError("failed to send commands")
        }
        
        do {
            try MIKMIDIDeviceManager.shared.connect(alesisDevice) { (endpoint, commands) in
                print("commands from endpoint: \(endpoint)")
                commands.forEach {
                    if let noteOnCommand = $0 as? MIKMIDINoteOnCommand {
                        print("Note ON - note: \(noteOnCommand.note) velocity: \(Int(noteOnCommand.velocity))")
                        scene.midiEvent(note: noteOnCommand.note, velocity: noteOnCommand.velocity)
                    }
                    else if let controlChangeCommand = $0 as? MIKMIDIControlChangeCommand {
                        print("Control change - number: \(controlChangeCommand.controllerNumber) value: \(controlChangeCommand.controllerValue)")
                    }
                    else {
                        print("unrecognized command: \($0)")
                    }
                }
            }
        } catch {
            fatalError("failed to connect to source")
        }
        
        do {
            synth = try MIKMIDIEndpointSynthesizer(midiSource: alesisSource, error: ())
        } catch {
            fatalError("failed to init synthesizer")
        }
        
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "mid") else {
            fatalError("could not find resource file")
        }
        
        print(url)
        
        let sequence = try! MIKMIDISequence(fileAt: url)
        print(sequence.tracks.count)
        
        let sequencer = MIKMIDISequencer(sequence: sequence)
        sequencer.setCommandScheduler(alesisDestination, for: sequence.tracks.first!)
        sequencer.setCommandScheduler(alesisDestination, for: sequence.tracks[1])
        sequencer.setCommandScheduler(alesisDestination, for: sequence.tracks[2])
//        sequencer.startPlayback()
    }
}
