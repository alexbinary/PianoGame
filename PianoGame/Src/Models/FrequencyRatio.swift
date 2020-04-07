
import Foundation



struct FrequencyRatio {
    
    
    let ratio: Double
    
    
    init(between frequency1: Frequency, and frequency2: Frequency) {
        
        self.ratio = frequency1.valueInHertz / frequency2.valueInHertz
    }
}


extension FrequencyRatio: Equatable {
    
    
}


extension FrequencyRatio {
    
    
    var valueInOctaves: Double { log2(self.ratio) }
}
