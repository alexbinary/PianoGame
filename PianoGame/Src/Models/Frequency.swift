
import Foundation



struct Frequency {
    
    
    let valueInHertz: Double
    
    
    init(valueInHertz: Double) {
        
        self.valueInHertz = valueInHertz
    }
    
    
    static let standardA4 = 440.Hz
}


extension Frequency: CustomStringConvertible {
    
    
    var description: String {
        
        return String(format: "%.2f Hz", self.valueInHertz)
    }
}


extension Frequency: Equatable {
    
    
}


extension Frequency: Hashable {
    
    
}


extension Frequency: Comparable {
    
    
    static func < (lhs: Frequency, rhs: Frequency) -> Bool {
        
        return lhs.valueInHertz < rhs.valueInHertz
    }
}


extension Frequency {
    
    
    static func * (left: Frequency, right: Double) -> Frequency {
        
        return Frequency(valueInHertz: left.valueInHertz * right)
    }
}


extension Double {
    
    
    var Hz: Frequency { Frequency(valueInHertz: self) }
}
