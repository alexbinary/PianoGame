
import UIKit
import AudioKit
import AudioKitUI
import Percent



class SingingGameViewController: UIViewController {
    
    
    class StabilizerNode {
        
        let threshold: Double
        var previousSample: Double! = nil
        
        init(threshold: Double) {
            
            self.threshold = threshold
        }
        
        func inject(sample: Double) -> Double {
            
            if self.previousSample == nil || abs(sample - self.previousSample!) > self.threshold {
                self.previousSample = sample
                return sample
            } else {
                return self.previousSample
            }
        }
    }
    
    
    var microphoneAudioNode: AKMicrophone!
    var frequencyTrackerAudioNode: AKFrequencyTracker!
    
    let trackingRefreshPeriod: TimeInterval = 0.03 // seconds
    let amplitudeThreshold: Double = 0.02
    
    
    var cursorView: UIView!
    var cursorGuideViewX: UIView!
    var cursorGuideViewY: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        fatalError("macOS not supported, please run on an iOS device")
        #endif
        
        self.cursorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.cursorView.backgroundColor = .black
        self.view.addSubview(self.cursorView)
        
        self.cursorGuideViewX = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: self.view.bounds.height))
        self.cursorGuideViewX.backgroundColor = .black
        self.view.addSubview(self.cursorGuideViewX)
        
        self.cursorGuideViewY = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        self.cursorGuideViewY.backgroundColor = .black
        self.view.addSubview(self.cursorGuideViewY)
        
        self.microphoneAudioNode = AKMicrophone()
        self.frequencyTrackerAudioNode = AKFrequencyTracker()
        
        self.microphoneAudioNode.connect(to: self.frequencyTrackerAudioNode)
        AudioKit.output = AKBooster(self.frequencyTrackerAudioNode, gain: 0)
        
        try! AudioKit.start()
        
        let frequencyStabilizerNode = StabilizerNode(threshold: 1.Hz.valueInHertz)
        let amplitudeStabilizerNode = StabilizerNode(threshold: 0.005)
        
        Timer.scheduledTimer(withTimeInterval: self.trackingRefreshPeriod, repeats: true) { _ in
            
//            print("Amplitude: \(self.frequencyTrackerAudioNode.amplitude)")
//            print("Frequency: \(self.frequencyTrackerAudioNode.frequency)Hz")
            
            guard self.frequencyTrackerAudioNode.amplitude > self.amplitudeThreshold else { return }
            
            let rawFrequency = Frequency(valueInHertz: self.frequencyTrackerAudioNode.frequency)
            let stabilizedFrequency = Frequency(valueInHertz: frequencyStabilizerNode.inject(sample: rawFrequency.valueInHertz))
            
            let frequency = stabilizedFrequency
            
            let rawAmplitude = self.frequencyTrackerAudioNode.amplitude
            let stabilizedAmplitude = amplitudeStabilizerNode.inject(sample: rawAmplitude)
            
            let amplitude = stabilizedAmplitude

            self.cursorView.center = CGPoint(x: self.convertAmplitudeToScreenX(amplitude), y: self.convertFrequencyToScreenY(frequency))
            self.cursorGuideViewX.center = CGPoint(x: self.cursorView.center.x, y: self.view.center.y)
            self.cursorGuideViewY.center = CGPoint(x: self.view.center.x, y: self.cursorView.center.y)
        }
    }
    
    
    func convertFrequencyToScreenY(_ frequency: Frequency) -> CGFloat {
        
        let minFrequency = 100.Hz
        let maxFrequency = 800.Hz
        
        let normalizedFrequency = (log2(frequency.valueInHertz) - log2(minFrequency.valueInHertz)) / (log2(maxFrequency.valueInHertz) - log2(minFrequency.valueInHertz))
        
        return self.view.bounds.height * CGFloat(1 - normalizedFrequency)
    }
    
    
    func convertAmplitudeToScreenX(_ amplitude: Double) -> CGFloat {
        
        let minAmplitude: Double = 0
        let maxAmplitude: Double = 0.20
        
        let normalizedAmplitude: Double = (amplitude - minAmplitude) / (maxAmplitude - minAmplitude)
        
        return self.view.bounds.width * CGFloat(normalizedAmplitude)
    }
}
