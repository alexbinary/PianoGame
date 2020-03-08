
import SpriteKit
import AudioKit



enum Sequence: Int {
    
    case melody = 0, bassDrum, snareDrum, snareGhost
}


class AudioKitTestScene: SKScene {
    
    
    var fmOscillator = AKFMOscillatorBank()
    var verb: AKReverb2!
    var sequencer = AKAppleSequencer()
    let sequenceLength = AKDuration(beats: 8.0)
    var melodicSound: AKMIDINode!
    let scale1: [Int] = [0, 2, 4, 7, 9]
    let scale2: [Int] = [0, 3, 5, 7, 10]
    var pumper: AKCompressor!
    var mixer = AKMixer()

    
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
        verb = AKReverb2(melodicSound)
        verb.dryWetMix = 0.5
        verb.decayTimeAt0Hz = 7
        verb.decayTimeAtNyquist = 11
        verb.randomizeReflections = 600
        verb.gain = 1
        
        pumper = AKCompressor(mixer)

        pumper.headRoom = 0.10
        pumper.threshold = -15
        pumper.masterGain = 10
        pumper.attackDuration = 0.01
        pumper.releaseDuration = 0.3

        [verb] >>> mixer

        AudioKit.output = pumper
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        setupTracks()
    }
    
    
    func setupTracks() {
        
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[Sequence.melody.rawValue].setMIDIOutput(melodicSound.midiIn)
        generateNewMelodicSequence(minor: false)
        
        sequencer.enableLooping()
        sequencer.setTempo(100)
        sequencer.play()
    }
    
    
    func generateNewMelodicSequence(_ stepSize: Float = 1 / 8, minor: Bool = false, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.melody.rawValue].clear() }
        sequencer.setLength(sequenceLength)
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        //AKLog("steps in sequence: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if arc4random_uniform(17) > 12 {
                let step = Double(i) * stepSize
                //AKLog("step is \(step)")
                let scale = (minor ? scale2 : scale1)
                let scaleOffset = arc4random_uniform(UInt32(scale.count) - 1)
                var octaveOffset = 0
                for _ in 0 ..< 2 {
                    octaveOffset += Int(12 * (((Float(arc4random_uniform(2))) * 2.0) + (-1.0)))
                    octaveOffset = Int(
                        (Float(arc4random_uniform(2))) *
                        (Float(arc4random_uniform(2))) *
                        Float(octaveOffset)
                    )
                }
                //AKLog("octave offset is \(octaveOffset)")
                let noteToAdd = 60 + scale[Int(scaleOffset)] + octaveOffset
                sequencer.tracks[Sequence.melody.rawValue].add(noteNumber: MIDINoteNumber(noteToAdd),
                                                               velocity: 100,
                                                               position: AKDuration(beats: step),
                                                               duration: AKDuration(beats: 1))
            }
        }
        sequencer.setLength(sequenceLength)
    }
}
