
import Foundation



typealias Scale = [Note]


extension Scale {
    
    
    var isMajorSale: Bool {
        
        guard self.count == 7 else { return false }
        
        guard Interval(from: self[0], to: self[1]).lengthInHalfSteps == 2 else { return false }
        guard Interval(from: self[1], to: self[2]).lengthInHalfSteps == 2 else { return false }
        guard Interval(from: self[2], to: self[3]).lengthInHalfSteps == 1 else { return false }
        guard Interval(from: self[3], to: self[4]).lengthInHalfSteps == 2 else { return false }
        guard Interval(from: self[4], to: self[5]).lengthInHalfSteps == 2 else { return false }
        guard Interval(from: self[5], to: self[6]).lengthInHalfSteps == 2 else { return false }
        
        return true
    }
}
