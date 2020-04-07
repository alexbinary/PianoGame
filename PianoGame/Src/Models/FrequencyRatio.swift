
import Foundation



struct FrequencyRatio {
    
    
    let rawValue: Double
    
    
    init(between frequency1: Frequency, and frequency2: Frequency) {
        
        self.rawValue = frequency1.valueInHertz / frequency2.valueInHertz
    }
}


extension FrequencyRatio: Equatable {
    
    
}


extension FrequencyRatio {
    
    
    var valueInOctaves: Double { log2(self.rawValue) }
    
    
    var valueInCents: Double { self.valueInOctaves * 1_200 }
}
