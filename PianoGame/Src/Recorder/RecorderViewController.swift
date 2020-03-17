
import UIKit
import AudioKit



class RecorderViewController: UIViewController {

    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    var fmOscillator = AKFMOscillatorBank()
    var sequencer = AKAppleSequencer()
    var melodicSound: AKMIDINode!
    var track: AKMusicTrack!
    
    var lastNoteOn: [MIDINoteNumber: (timeStart: AKDuration, velocity: MIDIVelocity)] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fmOscillator.modulatingMultiplier = 3
        fmOscillator.modulationIndex = 0.3
        melodicSound = AKMIDINode(node: fmOscillator)
        AudioKit.output = melodicSound
        
        let midi = AudioKit.midi
        midi.openInput(name: MIDIDeviceName)
        midi.addListener(self)
        
        midi.openOutput()
        
        let out = midi.endpoints.first(where: {
            midi.destinationName(for: $0.key) == self.MIDIDeviceName
        })!.value
        
        track = sequencer.newTrack()
        track.setMIDIOutput(out)
        
        sequencer.setTempo(60)
        
        try! AudioKit.start()
    }
    
    
    @IBAction func record() {
        
        sequencer.rewind()
        sequencer.play()
    }
    
    
    @IBAction func play() {
        
        sequencer.rewind()
        sequencer.play()
    }
}


extension RecorderViewController: AKMIDIListener {
    
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        
        if velocity > 0 {
            
            self.lastNoteOn[noteNumber] = (timeStart: sequencer.currentPosition, velocity: velocity)
            
        } else {
            
            if let noteOn = self.lastNoteOn[noteNumber] {
            
                track.add(noteNumber: noteNumber,
                          velocity: noteOn.velocity,
                          position: noteOn.timeStart,
                          duration: sequencer.currentPosition - noteOn.timeStart)
            }
        }
    }
}
