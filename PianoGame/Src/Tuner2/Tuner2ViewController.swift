
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
    
    
    struct PitchValue {
        
        let numberOfNotesRelativeToA4: Double
        
        init(withFrequency frequency: Double) {
            
            let octaveValueRelativeToA4 = log2(frequency / 440.0)
            let numberOfNotesRelativeToA4 = octaveValueRelativeToA4 * 12  // 12 notes in an octave
            
            self.init(fromNumberOfNotesRelativeToA4: numberOfNotesRelativeToA4)
        }
        
        init(fromNumberOfNotesRelativeToA4 numberOfNotesRelativeToA4: Double) {
            
            self.numberOfNotesRelativeToA4 = numberOfNotesRelativeToA4
        }
        
        init(fromNote note: Legacy_Note, atOctave octave: Int) {
            
            let notesInOneOctave: Int = 12
            let A4OctaveValue: Int = 4
            let A4IndexInChromaticScale: Int = Legacy_Note.a.indexInChromaticScale
            
            let octaveValueRelativeToA4: Int = (octave - A4OctaveValue)
            let indexInChromaticScaleRelativeToA4: Int = note.indexInChromaticScale - A4IndexInChromaticScale
            
            self.numberOfNotesRelativeToA4 = octaveValueRelativeToA4 * notesInOneOctave + indexInChromaticScaleRelativeToA4
        }
        
        var numberOfNotesRelativeToA4ClosestIntegerValue: Int { Int(self.numberOfNotesRelativeToA4.rounded(.toNearestOrAwayFromZero)) }
        var distanceToClosestNote: Double { self.numberOfNotesRelativeToA4 - numberOfNotesRelativeToA4ClosestIntegerValue }
        
        var closestNote: Legacy_Note { Legacy_Note.a.addingHalfSteps(self.numberOfNotesRelativeToA4ClosestIntegerValue) }
        
        func numberOfNotes(fromNote note: Legacy_Note, atOctave octave: Int) -> Double {
        
            self.numberOfNotesRelativeToA4 - PitchValue(fromNote: note, atOctave: octave).numberOfNotesRelativeToA4
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
    
    
    let fullKeyboardNoteRangeRelativeToA4: ClosedRange<Int> = (-4 * 12)...(3 * 12 + 3)
    let standardClefsNoteRangeRelativeToA4: ClosedRange<Int> = (-3 * 12)...(1 * 12 + 5) // A1 to D6
    
    var noteAxisNoteRangeRelativeToA4: ClosedRange<Int> { self.standardClefsNoteRangeRelativeToA4 }
    
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
            
            let rawFrequency: Double = self.frequencyTrackerAudioNode.frequency
            let stabilizedFrequency = frequencyStabilizerNode.inject(sample: rawFrequency)
            
            let frequency = stabilizedFrequency

            let pitchValue = PitchValue(withFrequency: frequency)
            self.noteCursorView.center = CGPoint(x: self.noteCursorView.center.x, y: self.convertToScreenCoordinates(pitchValue: pitchValue))
            
            self.metTargets = self.metTargets(forPitchValue: pitchValue)
            self.turnOff(targets: self.targets)
            self.turnOn(targets: self.metTargets)
            
            let closestNote: Legacy_Note = pitchValue.closestNote
            let distanceToClosestNote: Double = pitchValue.distanceToClosestNote
            
            self.label.text = """
            \(String(format: "%.0f Hz", frequency.rounded()))
            \(closestNote.name(using: .latinNaming))
            \(String(format: "%.2f", distanceToClosestNote))
            """
        }
    }
    
    
    func convertToScreenCoordinates(pitchValue: PitchValue) -> CGFloat {
    
        let minNoteValue = Double(self.noteAxisNoteRangeRelativeToA4.lowerBound)
        let maxNoteValue = Double(self.noteAxisNoteRangeRelativeToA4.upperBound)
        let normalizedNoteValue = (pitchValue.numberOfNotesRelativeToA4 - minNoteValue) / (maxNoteValue - minNoteValue)
        
        return self.view.bounds.height * CGFloat(1 - normalizedNoteValue)
    }
    
    
    func drawNotesAxis() {
        
        for noteValue in self.noteAxisNoteRangeRelativeToA4 {
            
            let pitchValue = PitchValue(fromNumberOfNotesRelativeToA4: Double(noteValue))
            
            let y = self.convertToScreenCoordinates(pitchValue: pitchValue)
            
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
    
    
    func metTargets(forPitchValue pitchValue: PitchValue) -> Set<Target> {
        
        return Set<Target>(self.targets.filter { pitchValue.numberOfNotesRelativeToA4 > ($0.targetNoteValueRelativeToA4 + $0.tolerance.lowerBound) && pitchValue.numberOfNotesRelativeToA4 < ($0.targetNoteValueRelativeToA4 + $0.tolerance.upperBound) })
    }
    
    
    func draw(targets: Set<Target>) {
        
        for target in targets {
            
            let lowerY = self.convertToScreenCoordinates(pitchValue: PitchValue(fromNumberOfNotesRelativeToA4: Double(target.targetNoteValueRelativeToA4 + target.tolerance.lowerBound)))
            let upperY = self.convertToScreenCoordinates(pitchValue: PitchValue(fromNumberOfNotesRelativeToA4: Double(target.targetNoteValueRelativeToA4 + target.tolerance.upperBound)))
            
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
