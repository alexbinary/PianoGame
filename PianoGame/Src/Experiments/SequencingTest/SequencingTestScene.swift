
import SpriteKit
import MIKMIDI



class SequencingTestScene: SKScene {
    
    
    override func didMove(to view: SKView) {
        
        self.initScene()
        self.startSequencerTest()
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    
    func startSequencerTest() {
        
        let sequence = MIKMIDISequence()
//        sequence.setTempo(60, atTimeStamp: 0)
        sequence.setOverallTempo(60)
        sequence.setOverallTimeSignature(MIKMIDITimeSignatureMake(4, 4))
        
//        let tempoTrack = sequence.tempoTrack
//        let tempoEvent = MIKMIDITempoEvent(timeStamp: 0, tempo: 60)
//        tempoTrack.addEvent(tempoEvent)
        
//        let musicTrack = try! sequence.addTrack()
        
        let event = MIKMIDINoteEvent(timeStamp: 2000, note: 60, velocity: 128, duration: 2000, channel: 1)
        sequence.tracks[0].addEvent(event)
        
        
        
        let sequencer = MIKMIDISequencer(sequence: sequence)
        sequencer.startPlayback()
        
//        let synth = sequencer.builtinSynthesizer(for: musicTrack)
//        print(synth)
    }
}
