
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


extension Double {
    
    
    var octaves: FrequencyRatio { FrequencyRatio(rawValue: pow(2, self)) }
    
    
    var cents: FrequencyRatio { (self/1_200.0).octaves }
}
