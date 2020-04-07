
import UIKit
import AudioKit
import AudioKitUI
import Percent



class Tuner2ViewController: UIViewController {
    
    
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
    
    
    struct Target: Hashable {
        
        let targetNoteValueRelativeToA4: Double
        let tolerance: ClosedRange<Double>
    }
    
    
    var microphoneAudioNode: AKMicrophone!
    var frequencyTrackerAudioNode: AKFrequencyTracker!
    
    let trackingPeriod: TimeInterval = 0.03 // seconds
    let amplitudeThreshold: Double = 0.02
    
    
    var label: UILabel! = nil
    var noteCursorView: UIView!
    
    
    let fullKeyboardNoteRange: ClosedRange<Note> = Note(.a, at: Octave(0))...Note(.c, at: Octave(8))
    let standardClefsNoteRange: ClosedRange<Note> = Note(.a, at: Octave(1))...Note(.d, at: Octave(6))
    
    var noteAxisNoteRange: ClosedRange<Note> { self.standardClefsNoteRange }
    
    let targets: Set<Target> = [
        Target(targetNoteValueRelativeToA4: -9-12, tolerance: (-1)...(1)), // C3
        Target(targetNoteValueRelativeToA4: -9, tolerance: (-1)...(1)), // C4
        Target(targetNoteValueRelativeToA4: 3, tolerance: (-1)...(1)),  // C5
    ]
    var metTargets: Set<Target> = []
    
    var targetViews: [Target: UIView] = [:]
    
    
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
        
        self.draw(targets: self.targets)
        self.turnOff(targets: self.targets)
        
        self.drawNotesAxis()
        
        self.noteCursorView = UIView(frame: CGRect(x: self.view.bounds.width - 100, y: 0, width: 100, height: 1))
        self.noteCursorView.backgroundColor = .red
        self.view.addSubview(self.noteCursorView)
        
        self.microphoneAudioNode = AKMicrophone()
        self.frequencyTrackerAudioNode = AKFrequencyTracker()
        
        self.microphoneAudioNode.connect(to: self.frequencyTrackerAudioNode)
        AudioKit.output = AKBooster(self.frequencyTrackerAudioNode, gain: 0)
        
        try! AudioKit.start()
        
        let frequencyStabilizerNode = StabilizerNode(threshold: 1)  // Hz
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            guard self.frequencyTrackerAudioNode.amplitude > self.amplitudeThreshold else { return }
            
            let rawFrequencyValue: Double = self.frequencyTrackerAudioNode.frequency
            let stabilizedFrequencyValue = frequencyStabilizerNode.inject(sample: rawFrequencyValue)
            
            let frequencyValue = stabilizedFrequencyValue

            let pitch = Pitch(at: Frequency(valueInHertz: frequencyValue))
            self.noteCursorView.center = CGPoint(x: self.noteCursorView.center.x, y: self.convertToScreenCoordinates(pitch: pitch))
            
            self.metTargets = self.metTargets(for: pitch)
            self.turnOff(targets: self.targets)
            self.turnOn(targets: self.metTargets)
            
            let closestNote: Note = pitch.closestNote
            let distanceToClosestNote: Double = pitch.numberOfNotesToClosestNote
            
            self.label.text = """
            \(String(format: "%.0f Hz", frequencyValue.rounded()))
            \(closestNote.name.displayName(in: .latinNaming))
            \(String(format: "%.2f", distanceToClosestNote))
            """
        }
    }
    
    
    func convertToScreenCoordinates(pitch: Pitch) -> CGFloat {
    
        return self.convertToScreenCoordinates(noteValueRelativeToA4: pitch.numberOfNotes(relativeTo: .A4))
    }
    
    
    func convertToScreenCoordinates(noteValueRelativeToA4: Double) -> CGFloat {
        
        let minNoteValue = Double(self.noteAxisNoteRange.lowerBound.numberOfNotes(relativeTo: .A4))
        let maxNoteValue = Double(self.noteAxisNoteRange.upperBound.numberOfNotes(relativeTo: .A4))
        
        let normalizedNoteValue = (noteValueRelativeToA4 - minNoteValue) / (maxNoteValue - minNoteValue)
        
        return self.view.bounds.height * CGFloat(1 - normalizedNoteValue)
    }
    
    
    func drawNotesAxis() {
        
        for note in self.noteAxisNoteRange {
            
            let noteValue = note.numberOfNotes(relativeTo: .A4)
            
            let y = self.convertToScreenCoordinates(noteValueRelativeToA4: Double(noteValue))
            
            let noteIndexInCMajorScale = (noteValue - 3 + 12 * 12) % 12
            
            let isC = noteIndexInCMajorScale == 0
            let isSharp = [1, 3, 6, 8, 10].contains(noteIndexInCMajorScale)
            
            let length: CGFloat = isC ? 50 : isSharp ? 10 : 20
            let thickness: CGFloat = isC ? 1 : isSharp ? 2 : 1
            
            let view = UIView(frame: CGRect(x: self.view.bounds.width - length, y: 0, width: length, height: thickness))
            view.backgroundColor = .black
            view.center = CGPoint(x: view.center.x, y: y)
            self.view.addSubview(view)
        }
    }
    
    
    func metTargets(for pitch: Pitch) -> Set<Target> {
        
        return Set<Target>(self.targets.filter { pitch.numberOfNotes(relativeTo: .A4) > ($0.targetNoteValueRelativeToA4 + $0.tolerance.lowerBound) && pitch.numberOfNotes(relativeTo: .A4) < ($0.targetNoteValueRelativeToA4 + $0.tolerance.upperBound) })
    }
    
    
    func draw(targets: Set<Target>) {
        
        for target in targets {
            
            let lowerY = self.convertToScreenCoordinates(noteValueRelativeToA4: Double(target.targetNoteValueRelativeToA4 + target.tolerance.lowerBound))
            let upperY = self.convertToScreenCoordinates(noteValueRelativeToA4: Double(target.targetNoteValueRelativeToA4 + target.tolerance.upperBound))
            
            let width: CGFloat = 100
            
            let view = UIView(frame: CGRect(x: self.view.bounds.width - width, y: upperY, width: width, height: lowerY - upperY))
            self.view.addSubview(view)
            self.view.sendSubviewToBack(view)
            
            self.targetViews[target] = view
        }
    }
    
    
    func turnOn(targets: Set<Target>) {
        
        for target in targets {
            
            self.targetViews[target]!.backgroundColor = .green
        }
    }
    
    
    func turnOff(targets: Set<Target>) {
        
        for target in targets {
            
            self.targetViews[target]!.backgroundColor = .lightGray
        }
    }
}
