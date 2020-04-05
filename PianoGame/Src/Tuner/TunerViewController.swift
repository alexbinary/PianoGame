
import UIKit
import AudioKit
import AudioKitUI



class TunerViewController: UIViewController {
    
    
    var microphoneAudioNode: AKMicrophone!
    var frequencyTrackerAudioNode: AKFrequencyTracker!
    
    let trackingPeriod: TimeInterval = 0.01 // seconds
    
    let amplitudeThreshold: Double = 0.01
    
    
    var label: UILabel! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        fatalError("macOS not supported, please run on an iOS device")
        #endif
        
        self.label = UILabel()
        self.label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        self.view.addSubview(self.label)
        
        self.microphoneAudioNode = AKMicrophone()
        self.frequencyTrackerAudioNode = AKFrequencyTracker()
        
        self.microphoneAudioNode.connect(to: self.frequencyTrackerAudioNode)
        AudioKit.output = AKBooster(self.frequencyTrackerAudioNode, gain: 0)
        
        try! AudioKit.start()
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            guard self.frequencyTrackerAudioNode.amplitude > self.amplitudeThreshold else { return }
            
            let frequency: Double = self.frequencyTrackerAudioNode.frequency
            
            self.label.text = "\(round(frequency)) Hz"
            self.label.sizeToFit()
            self.label.center = self.view.center
        }
    }
}
