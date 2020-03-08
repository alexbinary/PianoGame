
import SpriteKit
import AudioKit



enum Sequence: Int {
    
    case melody = 0, bassDrum, snareDrum, snareGhost
}


class AudioKitTestScene: SKScene {
    
    
    var fmOscillator = AKFMOscillatorBank()
    var sequencer = AKAppleSequencer()
    var melodicSound: AKMIDINode!

    
    override func didMove(to view: SKView) {
        
        self.initScene()
        self.startTest()
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    
    func startTest() {
        
        fmOscillator.modulatingMultiplier = 3
        fmOscillator.modulationIndex = 0.3

        melodicSound = AKMIDINode(node: fmOscillator)

        AudioKit.output = melodicSound
        try! AudioKit.start()
        
        setupTracks()
    }
    
    
    func setupTracks() {
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.melody.rawValue].setMIDIOutput(melodicSound.midiIn)
        generateNewMelodicSequence()
        
        sequencer.enableLooping()
        sequencer.setTempo(60)
        sequencer.play()
    }
    
    
    func generateNewMelodicSequence() {
        
        sequencer.tracks[Sequence.melody.rawValue].add(noteNumber: MIDINoteNumber(60),
                                                       velocity: 100,
                                                       position: AKDuration(beats: 0),
                                                       duration: AKDuration(beats: 1/2))
        
        sequencer.tracks[Sequence.melody.rawValue].add(noteNumber: MIDINoteNumber(70),
                                                       velocity: 100,
                                                       position: AKDuration(beats: 1),
                                                       duration: AKDuration(beats: 1/2))
        
        sequencer.tracks[Sequence.melody.rawValue].add(noteNumber: MIDINoteNumber(65),
                                                       velocity: 100,
                                                       position: AKDuration(beats: 2),
                                                       duration: AKDuration(beats: 1))
    }
}
