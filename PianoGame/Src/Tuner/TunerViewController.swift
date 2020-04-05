
import UIKit
import AudioKit
import AudioKitUI



class TunerViewController: UIViewController {
    
    
    class ExponentialSmoothingNode {
        
        let smoothingFactor: Double
        let bufferSize: Int
        
        var buffer: [Double] = []
        
        
        init(bufferSize: Int = 30, smoothingFactor: Double = 0.25) {
            
            self.smoothingFactor = smoothingFactor
            self.bufferSize = bufferSize
        }
        
        func inject(_ rawSample: Double) -> Double {
            
            var smoothedSample = rawSample
            
            if let latestBufferValue = self.buffer.first {
                smoothedSample = self.smoothingFactor * rawSample + (1 - self.smoothingFactor) * latestBufferValue
            }
            
            self.buffer.insert(smoothedSample, at: 0)
            while self.buffer.count > self.bufferSize { _ = self.buffer.popLast() }
            
            return smoothedSample
        }
    }
    
    
    var microphoneAudioNode: AKMicrophone!
    var frequencyTrackerAudioNode: AKFrequencyTracker!
    
    let trackingPeriod: TimeInterval = 0.03 // seconds
    
    let amplitudeThreshold: Double = 0.03
    
    
    var label: UILabel! = nil
    
    var volumeCursorView: UIView!
    var volumeThresholdView: UIView!
    
    
    let amplitudeSmoothingBufferSize = 30
    let amplitudeSmoothingFactor: Double = 0.25
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        fatalError("macOS not supported, please run on an iOS device")
        #endif
        
        self.label = UILabel()
        self.label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        self.view.addSubview(self.label)
        
        self.volumeCursorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        self.volumeCursorView.backgroundColor = .black
        self.view.addSubview(volumeCursorView)
        
        self.volumeThresholdView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        self.volumeThresholdView.backgroundColor = .red
        self.view.addSubview(volumeThresholdView)
        
        self.microphoneAudioNode = AKMicrophone()
        self.frequencyTrackerAudioNode = AKFrequencyTracker()
        
        self.microphoneAudioNode.connect(to: self.frequencyTrackerAudioNode)
        AudioKit.output = AKBooster(self.frequencyTrackerAudioNode, gain: 0)
        
        try! AudioKit.start()
        
        let amplitudeSmoothingNode = ExponentialSmoothingNode(bufferSize: self.amplitudeSmoothingBufferSize, smoothingFactor: self.amplitudeSmoothingFactor)
        
        let rawAmplitudeToScreenPosition: (Double) -> CGFloat = { self.view.bounds.height * CGFloat(1 - $0/0.2) }
        
        self.volumeThresholdView.center = CGPoint(x: 0, y: rawAmplitudeToScreenPosition(self.amplitudeThreshold))
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            // amplitude
            
            let rawAmplitude = self.frequencyTrackerAudioNode.amplitude
            let smoothedAmplitude = amplitudeSmoothingNode.inject(rawAmplitude)
            
            self.volumeCursorView.center = CGPoint(x: 0, y: rawAmplitudeToScreenPosition(smoothedAmplitude))
            
            // frequency
            
            if self.frequencyTrackerAudioNode.amplitude > self.amplitudeThreshold {
                
                let rawFrequency: Double = self.frequencyTrackerAudioNode.frequency

                self.label.text = "\(round(rawFrequency)) Hz"
                self.label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
                self.label.sizeToFit()
                self.label.center = self.view.center
                
            } else {
                
                self.label.font = UIFont.systemFont(ofSize: 64, weight: .light)
            }
        }
    }
}
