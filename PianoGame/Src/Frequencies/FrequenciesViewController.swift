
import UIKit



class FrequenciesViewController: UIViewController {
    
    
    let octaveRatio: Double = 2
    let fifthRatio: Double = 3
    let thirdRatio: Double = 5
    
    let frequencyRange = 27.5.Hz...4187.Hz
    let baseFrequency = 55.Hz
    
    var collectedFrequencies: [(source: String, frequency: Frequency)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("")
        print("base frequency")
        print(Pitch(at: baseFrequency))
        
        print("")
        print("octaves from base frequency")
        self.printAndCollectFrequencies(fromBase: self.baseFrequency,
                                        withRatio: self.octaveRatio,
                                        withinRange: self.frequencyRange,
                                        source: "base")
        
        let firstFifthFrequency = self.baseFrequency * self.fifthRatio
        print("")
        print("first fifth")
        print(Pitch(at: firstFifthFrequency))
        
        print("")
        print("octaves from first fifth")
        self.printAndCollectFrequencies(fromBase: firstFifthFrequency,
                                        withRatio: self.octaveRatio,
                                        withinRange: self.frequencyRange,
                                        source: "first fifth")
                
        print("")
        print("summary")
        printCollectedFrequencies(self.collectedFrequencies)
    }
    
    
    func spellFrequencies(fromBase baseFrequency: Frequency, withRatio ratio: Double, withinRange range: ClosedRange<Frequency>) -> Set<Frequency> {

        let min = log(range.lowerBound/baseFrequency, base: ratio)
        let max = log(range.upperBound/baseFrequency, base: ratio)
        
        return Set<Frequency>((Int(min.rounded(.up))...Int(max.rounded(.down))).map { baseFrequency * pow(ratio, Double($0)) })
    }
    
    
    func printFrequencies(_ frequencies: Set<Frequency>) {
        
        frequencies.sorted().forEach { print(Pitch(at: $0)) }
    }
    
    
    func collectFrequencies(_ frequencies: Set<Frequency>, source: String) {
        
        self.collectedFrequencies.append(contentsOf: frequencies.map { (source: source, frequency: $0) })
        
        self.collectedFrequencies.sort(by: { $0.frequency < $1.frequency })
    }
    
    
    func printAndCollectFrequencies(fromBase baseFrequency: Frequency, withRatio ratio: Double, withinRange range: ClosedRange<Frequency>, source: String) {
        
        let frequencies = self.spellFrequencies(fromBase: baseFrequency, withRatio: ratio, withinRange: range)
        self.printFrequencies(frequencies)
        self.collectFrequencies(frequencies, source: source)
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
