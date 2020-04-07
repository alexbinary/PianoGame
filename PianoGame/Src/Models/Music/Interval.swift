

enum Interval: CaseIterable {

    
    case P1
    case m2
    case M2
    case m3
    case M3
    case P4
    case A4
    case P5
    case m6
    case M6
    case m7
    case M7

    
    init(fromHalfSteps halfSteps: UInt) {
        
        self = Interval.allCases[Int(halfSteps % 12)]
    }
    
    
    init(from bottomNote: Legacy_Note, to topNote: Legacy_Note) {
        
        self.init(fromHalfSteps: UInt(((Legacy_Note.allCases.firstIndex(of: topNote)! - Legacy_Note.allCases.firstIndex(of: bottomNote)!)+12) % 12))
    }
    
    
    var lengthInHalfSteps: UInt { return UInt(Interval.allCases.firstIndex(of: self)!) }
}
