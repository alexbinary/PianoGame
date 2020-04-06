
import UIKit
import AudioKit
import AudioKitUI
import Percent



class Tuner2ViewController: UIViewController {
    
    
    class StabilizerNode {
        
        var threshold: Double
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
    
    let trackingPeriod: TimeInterval = 0.03 // seconds
    let amplitudeThreshold: Double = 0.02
    
    
    var label: UILabel! = nil
    var noteCursorView: UIView!
    
    
    let noteAxisNoteRangeRelativeToA4: ClosedRange<Int> = (-4 * 12)...(3 * 12 + 3)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        fatalError("macOS not supported, please run on an iOS device")
        #endif
        
        self.label = UILabel(frame: self.view.bounds)
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
        self.label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        self.view.addSubview(self.label)
        
        self.drawNotesAxis()
        
        self.noteCursorView = UIView(frame: CGRect(x: self.view.bounds.width - 10, y: 0, width: 10, height: 5))
        self.noteCursorView.backgroundColor = .black
        self.view.addSubview(self.noteCursorView)
        
        self.microphoneAudioNode = AKMicrophone()
        self.frequencyTrackerAudioNode = AKFrequencyTracker()
        
        self.microphoneAudioNode.connect(to: self.frequencyTrackerAudioNode)
        AudioKit.output = AKBooster(self.frequencyTrackerAudioNode, gain: 0)
        
        try! AudioKit.start()
        
        let frequencyStabilizerNode = StabilizerNode(threshold: 1)  // Hz
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            guard self.frequencyTrackerAudioNode.amplitude > self.amplitudeThreshold else { return }
            
            let rawFrequency: Double = self.frequencyTrackerAudioNode.frequency
            let stabilizedFrequency = frequencyStabilizerNode.inject(sample: rawFrequency)
            
            let frequency = stabilizedFrequency
            
            let octaveValueRelativeToA4 = log2(frequency / 440.0)
            let noteValueRelativeToA4 = octaveValueRelativeToA4 * 12  // 12 notes in an octave
            
            let normalizedNoteValue = self.normalize(noteValue: noteValueRelativeToA4)
            self.noteCursorView.center = CGPoint(x: self.noteCursorView.center.x, y: self.convertToScreenCoordinates(normalizedNoteValue: normalizedNoteValue))
            
            let closestIntegerValue = Int(noteValueRelativeToA4.rounded(.toNearestOrAwayFromZero))
            let approximation = (noteValueRelativeToA4 - closestIntegerValue)
            
            let note = Note.a.addingHalfSteps(closestIntegerValue)
            
            self.label.text = """
                \(String(format: "%.0f Hz", stabilizedFrequency.rounded()))
                \(note.name(using: .latinNaming))
                \(String(format: "%.2f", approximation))
                """
        }
    }
    
    
    func normalize(noteValue: Double) -> Percent {
        
        let minNoteValue = Double(self.noteAxisNoteRangeRelativeToA4.lowerBound)
        let maxNoteValue = Double(self.noteAxisNoteRangeRelativeToA4.upperBound)
        let normalizedNoteValue = (noteValue - minNoteValue) / (maxNoteValue - minNoteValue)
        return Percent(fraction: normalizedNoteValue)
    }
    
    
    func convertToScreenCoordinates(normalizedNoteValue: Percent) -> CGFloat {
        
        return self.view.bounds.height * CGFloat(1 - normalizedNoteValue.fraction)
    }
    
    
    func drawNotesAxis() {
        
        for noteValue in self.noteAxisNoteRangeRelativeToA4 {
            
            let normalizedNoteValue = self.normalize(noteValue: Double(noteValue))
            let y = self.convertToScreenCoordinates(normalizedNoteValue: normalizedNoteValue)
            
            let view = UIView(frame: CGRect(x: self.view.bounds.width - 10, y: 0, width: 10, height: 1))
            view.backgroundColor = .black
            view.center = CGPoint(x: view.center.x, y: y)
            self.view.addSubview(view)
        }
    }
}
