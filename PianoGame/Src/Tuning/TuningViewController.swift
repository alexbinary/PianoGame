
import UIKit



class TuningViewController: UIViewController {
    
    
    struct MarkOptions {
        
        let color: UIColor
        let size: CGFloat
    }
    
    
    let standardPianoFrequencyRange = 27.5.Hz...4187.Hz
    var workingFrequencyRange: ClosedRange<Frequency> { (standardPianoFrequencyRange.lowerBound + (-150).cents)...(standardPianoFrequencyRange.upperBound + (150).cents) }
    
    let fifthFrequencyRatio = FrequencyRatio(rawValue: 3.0/2.0)
    
    
    let colors: [UIColor] = [.red, .blue, .green, .yellow, .systemPink, .brown, .cyan, .darkGray, .gray, .magenta, .orange, .purple]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var y: Double
        var ref: Frequency
        
        // equal temperament based on 440Hz
        
        ref = 27.5.Hz
        y = 9/10
        
        self.drawMark(for: ref, atYPosition: y, with: MarkOptions(color: .white, size: 300))
        
        for i in 0...11 {
            
            self.drawMarkForAllOctaves(of: ref + i * 100.cents,
                                       atYPosition: y,
                                       with: MarkOptions(color: .red, size: 200))
        }
        
        // Pythagorean
        
        ref = 27.5.Hz
        y = 1/2
        
        self.drawMark(for: ref, atYPosition: y, with: MarkOptions(color: .white, size: 300))
        
        self.drawMarkForAllOctaves(of: ref,
                                   atYPosition: y,
                                   with: MarkOptions(color: .white, size: 100))
        
        for i in 1...12 {
            
            let fifth = ref + i * self.fifthFrequencyRatio
            let color = self.colors[i-1]
            
            self.drawMark(for: fifth, atYPosition: y, with: MarkOptions(color: color, size: 300))
            
            self.drawMarkForAllOctaves(of: fifth,
                                       atYPosition: y,
                                       with: MarkOptions(color: color, size: 100))
        }
    }
    
    
    func drawMarkForAllOctaves(of frequency: Frequency, atYPosition y: Double, with options: MarkOptions, optionsForReferenceFrequency: MarkOptions? = nil) {
        
        let frequencies = self.generateFrequencyClass(fromReference: frequency,
                                                      withRatio: 1.octaves,
                                                      withinRange: self.workingFrequencyRange)
        
        self.drawMark(for: frequency, atYPosition: y, with: optionsForReferenceFrequency ?? options)
        
        frequencies.subtracting([frequency]) .forEach { self.drawMark(for: $0, atYPosition: y, with: options) }
    }
    
    
    func drawMark(for frequency: Frequency, atYPosition y: Double, with options: MarkOptions, drawGhost: Bool = false) {
        
        let x = self.xCoordinate(for: frequency)
        
        if drawGhost {
            self.drawMark(atX: x, y: 1/2, with: MarkOptions(color: UIColor.white.withAlphaComponent(0.1), size: self.view.bounds.height))
        }
        
        self.drawMark(atX: x, y: y, with: options)
    }
    
    
    func drawMark(atX x: Double, y: Double, with options: MarkOptions) {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: options.size))
        view.backgroundColor = options.color
        view.center = CGPoint(x: self.view.bounds.width * CGFloat(x), y: self.view.bounds.height * CGFloat(y))
        self.view.addSubview(view)
    }
    
    
    func xCoordinate(for frequency: Frequency) -> Double {
        
        let min = log(self.workingFrequencyRange.lowerBound.valueInHertz)
        let max = log(self.workingFrequencyRange.upperBound.valueInHertz)
        
        let val = log(frequency.valueInHertz)
        
        return (val - min) / (max - min)
    }
    
    
    func generateFrequencyClass(fromReference baseFrequency: Frequency, withRatio ratio: FrequencyRatio, withinRange range: ClosedRange<Frequency>) -> Set<Frequency> {
        
        let min = log((range.lowerBound/baseFrequency).rawValue, base: ratio.rawValue)
        let max = log((range.upperBound/baseFrequency).rawValue, base: ratio.rawValue)
        
        return Set<Frequency>((Int(min.rounded(.up))...Int(max.rounded(.down))).map { baseFrequency * pow(ratio.rawValue, Double($0)) })
    }
}
