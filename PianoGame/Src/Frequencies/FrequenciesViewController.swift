
import UIKit



class FrequenciesViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let octaveRatio: Double = 2
        let fifthRatio: Double = 3
        let thirdRatio: Double = 5
        
        let frequencyRange = 27.5.Hz...4187.Hz
        let baseFrequency = 55.Hz
        
        var allFrequencies: Set<Frequency> = []
        
        print("base frequency:")
        print(Pitch(at: baseFrequency))
        
        print("generating octaves")
        let octaveFrequencies = self.spellFrequencies(fromBase: baseFrequency, withRatio: octaveRatio, inRange: frequencyRange)
        octaveFrequencies.sorted().forEach { print(Pitch(at: $0)) }
        
//        print("generating fifths")
//        for i in 0...5 {
//
//            let f = baseFrequency * pow(fifthRatio, Double(i))
//            print("\(Pitch(at: f))")
//            allFrequencies.insert(f)
//        }
//
//        print("generating thirds")
//        for i in 0...5 {
//
//            let f = baseFrequency * pow(thirdRatio, Double(i))
//            print("\(Pitch(at: f))")
//            allFrequencies.insert(f)
//        }
//
//        print("all frequencies")
//        for f in allFrequencies.sorted() {
//            print("\(Pitch(at: f))")
//        }
    }
    
    
    func spellFrequencies(fromBase baseFrequency: Frequency, withRatio ratio: Double, inRange range: ClosedRange<Frequency>) -> Set<Frequency> {

        let min = log(range.lowerBound/baseFrequency, base: ratio)
        let max = log(range.upperBound/baseFrequency, base: ratio)
        
        return Set<Frequency>((Int(min.rounded())...Int(max.rounded())).map { baseFrequency * pow(ratio, Double($0)) })
    }
}


func log(_ value: Double, base: Double) -> Double {
    
    return log(value) / log(base)
}
