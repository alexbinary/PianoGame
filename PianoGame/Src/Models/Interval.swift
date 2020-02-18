

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

    
    init(from semitones: UInt) {
        
        self = Interval.allCases[Int(semitones % 12)]
    }
}
