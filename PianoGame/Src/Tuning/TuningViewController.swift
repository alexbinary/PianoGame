
import UIKit



class TuningViewController: UIViewController {
    
    
    struct MarkOptions {
        
        let color: UIColor
        let size: CGFloat
    }
    
    
    let workingFrequencyRange = 27.5.Hz...4187.Hz
    let referenceFrequency: Frequency = 440.Hz
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .systemPink, .brown, .cyan, .darkGray, .gray, .magenta, .orange, .purple]
        
        for i in 0...11 {
            
            self.drawMarkForAllOctaves(of: self.referenceFrequency + i * 100.cents,
                                       atYPosition: 1/2,
                                       with: MarkOptions(color: colors[i], size: 100))
        }
    }
    
    
    func drawMarkForAllOctaves(of frequency: Frequency, atYPosition y: Double, with options: MarkOptions, optionsForReferenceFrequency: MarkOptions? = nil) {
        
        let frequencies = self.generateFrequencyClass(fromReference: frequency,
                                                      withRatio: 1.octaves,
                                                      withinRange: self.workingFrequencyRange)
        
        self.drawMark(for: frequency, atYPosition: y, with: optionsForReferenceFrequency ?? options)
        
        frequencies.subtracting([frequency]) .forEach { self.drawMark(for: $0, atYPosition: y, with: options) }
    }
    
    
    func drawMark(for frequency: Frequency, atYPosition y: Double, with options: MarkOptions) {
        
        self.drawMark(atX: self.xCoordinate(for: frequency), y: y, with: options)
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
