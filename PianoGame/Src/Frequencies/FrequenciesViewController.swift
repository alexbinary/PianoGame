
import UIKit



class FrequenciesViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let baseFrequency: Double = 55
        
        let octaveRatio: Double = 2
        let fifthRatio: Double = 3
        let thirdRatio: Double = 5
        
        var allFrequencies: Set<Double> = []
        
        print("base frequency:")
        print(Pitch(at: Frequency(valueInHertz: baseFrequency)))
        
        print("generating octaves")
        for i in 0...7 {
            
            let f = baseFrequency * pow(octaveRatio, Double(i))
            print("\(Pitch(at: Frequency(valueInHertz: f)))")
            allFrequencies.insert(f)
        }
        
        print("generating fifths")
        for i in 0...5 {
            
            let f = baseFrequency * pow(fifthRatio, Double(i))
            print("\(Pitch(at: Frequency(valueInHertz: f)))")
            allFrequencies.insert(f)
        }
        
        print("generating thirds")
        for i in 0...5 {
            
            let f = baseFrequency * pow(thirdRatio, Double(i))
            print("\(Pitch(at: Frequency(valueInHertz: f)))")
            allFrequencies.insert(f)
        }
        
        print("all frequencies")
        for f in [Double](allFrequencies).sorted() {
            print("\(Pitch(at: Frequency(valueInHertz: f)))")
        }
    }
    
    
//    func spellFrequencies(fromBase baseFrequency: Frequency, withRatio ratio: Double, inRange range: ClosedRange<Frequency>) -> Set<Frequency> {
//        
//        
//    }
}