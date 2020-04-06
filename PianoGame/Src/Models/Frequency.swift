
import Foundation



public struct Frequency {
    
    
    let valueInHertz: Double
    
    
    init(valueInHertz: Double) {
        
        self.valueInHertz = valueInHertz
    }
    
    
    static let A4 = Frequency(valueInHertz: 440)
}
