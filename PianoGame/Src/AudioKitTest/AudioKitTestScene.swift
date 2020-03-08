
import SpriteKit
import AudioKit



class AudioKitTestScene: SKScene {
    
    
    var oscillator1 = AKOscillator()
//    var oscillator2 = AKOscillator()
//    var mixer = AKMixer()
    
    
    override func didMove(to view: SKView) {
        
        self.initScene()
        self.startTest()
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    
    func startTest() {
        
//        mixer = AKMixer(oscillator1, oscillator2)
//
//        // Cut the volume in half since we have two oscillators
//        mixer.volume = 0.5
//        AudioKit.output = mixer
//        do {
//            try AudioKit.start()
//        } catch {
//            AKLog("AudioKit did not start!")
//        }
    }
    
    
//    func toggleSound(_ sender: UIButton) {
//        if oscillator1.isPlaying {
//            oscillator1.stop()
//            oscillator2.stop()
//            sender.setTitle("Play Sine Waves", for: .normal)
//        } else {
//            oscillator1.frequency = random(in: 220 ... 880)
//            oscillator1.start()
//            oscillator2.frequency = random(in: 220 ... 880)
//            oscillator2.start()
//            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz & \(Int(oscillator2.frequency))Hz", for: .normal)
//        }
//    }
}
