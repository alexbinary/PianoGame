
import UIKit



class FrequenciesViewController: UIViewController {
    
    
    let octaveFrequencyRatio: Double = 2
    let fifthFrequencyRatio: Double = 3.0/2.0
    let thirdFrequencyRatio: Double = 5.0/4.0
    
    let workingFrequencyRange = 27.5.Hz...4187.Hz
    let referenceFrequency = 352.Hz
    
    var collectedFrequencies: [(source: String, frequency: Frequency)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("")
        print("reference frequency")
        print(Pitch(at: referenceFrequency))
        
        print("")
        print("octaves from reference frequency")
        self.printAndCollectOctaves(fromReference: self.referenceFrequency,
                                    withinRange: self.workingFrequencyRange,
                                    source: "base")
        
        for (name, ratio) in [
            (name: "fifth", ratio: self.fifthFrequencyRatio),
            (name: "third", ratio: self.thirdFrequencyRatio),
        ] {
            
            print("")
            print("\(name)s from reference frequency")
            self.printAndCollectFrequencyClass(fromReference: self.referenceFrequency,
                                               withRatio: ratio,
                                               withinRange: self.workingFrequencyRange,
                                               source: "\(name)s",
                prefix: { "\(name) #\($0)" })
            
            for (index, frequency) in self.generateFrequencyClass(fromReference: self.referenceFrequency,
                                                                  withRatio: ratio,
                                                                  withinRange: self.workingFrequencyRange
            ).sorted().enumerated() {

                print("")
                print("\(name) #\(index)")
                print(Pitch(at: frequency))

                print("")
                print("octaves from \(name) #\(index)")
                self.printAndCollectOctaves(fromReference: frequency,
                                            withinRange: self.workingFrequencyRange,
                                            source: "\(name) #\(index)")
            }
        }
        
        print("")
        print("summary")
        self.printCollectedFrequencies(self.collectedFrequencies)
    }
    
    
    func generateFrequencyClass(fromReference baseFrequency: Frequency, withRatio ratio: Double, withinRange range: ClosedRange<Frequency>) -> Set<Frequency> {
        
        let min = log((range.lowerBound/baseFrequency).rawValue, base: ratio)
        let max = log((range.upperBound/baseFrequency).rawValue, base: ratio)
        
        return Set<Frequency>((Int(min.rounded(.up))...Int(max.rounded(.down))).map { baseFrequency * pow(ratio, Double($0)) })
    }
    
    
    func printFrequencies(_ frequencies: Set<Frequency>, prefix: (_ index: Int) -> String = { _ in "" }) {
        
        frequencies.sorted().enumerated().forEach { print("\(prefix($0.offset)) \(Pitch(at: $0.element))") }
    }
    
    
    func collectFrequencies(_ frequencies: Set<Frequency>, source: String) {
        
        self.collectedFrequencies.append(contentsOf: frequencies.map { (source: source, frequency: $0) })
        self.collectedFrequencies.sort(by: { $0.frequency < $1.frequency })
    }
    
    
    func printAndCollectFrequencyClass(fromReference baseFrequency: Frequency, withRatio ratio: Double, withinRange range: ClosedRange<Frequency>, source: String, prefix: (_ index: Int) -> String = { _ in "" }) {
        
        let frequencies = self.generateFrequencyClass(fromReference: baseFrequency, withRatio: ratio, withinRange: range)
        self.printFrequencies(frequencies, prefix: prefix)
        self.collectFrequencies(frequencies, source: source)
    }
    
    
    func printAndCollectOctaves(fromReference baseFrequency: Frequency, withinRange range: ClosedRange<Frequency>, source: String) {
        
        self.printAndCollectFrequencyClass(fromReference: baseFrequency, withRatio: self.octaveFrequencyRatio, withinRange: range, source: source)
    }
    
    
    func printCollectedFrequencies(_ collectedFrequencies: [(source: String, frequency: Frequency)]) {
        
        collectedFrequencies.forEach {
            
            print("\(Pitch(at: $0.frequency)) \t \($0.source)")
        }
    }
}


func log(_ value: Double, base: Double) -> Double {
    
    return log(value) / log(base)
}
