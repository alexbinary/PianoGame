
import Foundation



struct FrequencyRatio {
    
    
    let rawValue: Double
    
    
    init(rawValue: Double) {
        
        self.rawValue = rawValue
    }
    
    
    init(between frequency1: Frequency, and frequency2: Frequency) {
        
        self.init(rawValue: frequency1.valueInHertz / frequency2.valueInHertz)
    }
}


extension FrequencyRatio: Equatable {
    
    
}


extension FrequencyRatio {
    
    
    var valueInOctaves: Double { log2(self.rawValue) }
    
    
    var valueInCents: Double { self.valueInOctaves * 1_200 }
}


extension FrequencyRatio {
    
    
    static func * (left: Double, right: FrequencyRatio) -> FrequencyRatio {
        
        return (right.valueInCents * left).cents
    }
    
    
    static func * (left: Int, right: FrequencyRatio) -> FrequencyRatio {
        
        return Double(left) * right
    }
}


extension Double {
    
    
    var octaves: FrequencyRatio { FrequencyRatio(rawValue: pow(2, self)) }
    
    
    var cents: FrequencyRatio { (self/1_200.0).octaves }
}



extension Int {
    
    
    var octaves: FrequencyRatio { Double(self).octaves }
    
    
    var cents: FrequencyRatio { Double(self).cents }
}
