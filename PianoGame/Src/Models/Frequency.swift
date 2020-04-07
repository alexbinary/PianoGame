
import Foundation



public struct Frequency {
    
    
    let valueInHertz: Double
    
    
    init(valueInHertz: Double) {
        
        self.valueInHertz = valueInHertz
    }
    
    
    static let standardA4 = 440.Hz
}


extension Frequency: CustomStringConvertible {
    
    
    public var description: String {
        
        return String(format: "%.2f Hz", self.valueInHertz)
    }
}


extension Double {
    
    
    var Hz: Frequency { Frequency(valueInHertz: self) }
}
