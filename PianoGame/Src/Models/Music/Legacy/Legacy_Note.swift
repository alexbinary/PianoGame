

public enum Legacy_Note : CaseIterable {
    
    
    case c
    case c_sharp
    case d
    case d_sharp
    case e
    case f
    case f_sharp
    case g
    case g_sharp
    case a
    case a_sharp
    case b
    
    
    init(fromNoteCode code: UInt) {
        
        let originalNoteCode = Int(code)
        let C4NoteCode = 60
        let noteCodeRelativeToC4 = originalNoteCode - C4NoteCode    // align code on the 4th octave
        let finalNoteCode = noteCodeRelativeToC4 + 5*12 // add as many octaves as needed to guarantee the code is always positive while staying properly aligned on the octaves
        
        self = Legacy_Note.allCases[finalNoteCode % Legacy_Note.allCases.count]
    }
    
    
    func adding(_ interval: Interval) -> Legacy_Note {
        
        return self.addingHalfSteps(Int(interval.lengthInHalfSteps))
    }
    
    
    func addingHalfSteps(_ halfSteps: Int) -> Legacy_Note {
        
        return Legacy_Note.allCases[(Legacy_Note.allCases.firstIndex(of: self)! + halfSteps + 12 * 10) % 12]
    }
    
    
    var sharp: Legacy_Note { return self.addingHalfSteps(1) }
    
    var flat: Legacy_Note { return self.addingHalfSteps(-1) }
    
    var indexInChromaticScale: Int {
        
        switch self {
        case .c:
            return 0
        case .c_sharp:
            return 1
        case .d:
            return 2
        case .d_sharp:
            return 3
        case .e:
            return 4
        case .f:
            return 5
        case .f_sharp:
            return 6
        case .g:
            return 7
        case .g_sharp:
            return 8
        case .a:
            return 9
        case .a_sharp:
            return 10
        case .b:
            return 11
        }
    }
}


extension Legacy_Note: CustomStringConvertible {
    
    
    public var description: String {
        
        let mapping: [Legacy_Note: String] = [
            .c: "C",
            .c_sharp: "C#",
            .d: "D",
            .d_sharp: "D#",
            .e: "E",
            .f: "F",
            .f_sharp: "F#",
            .g: "G",
            .g_sharp: "G#",
            .a: "A",
            .a_sharp: "A#",
            .b: "B",
        ]
        
        return mapping[self]!
    }
    
    
    public func name(using naming: NoteNaming) -> String {
        
        switch naming {
        case .englishNaming:
            
            switch self {
            case .c:
                return "C"
            case .c_sharp:
                return "C#"
            case .d:
                return "D"
            case .d_sharp:
                return "D#"
            case .e:
                return "E"
            case .f:
                return "F"
            case .f_sharp:
                return "F#"
            case .g:
                return "G"
            case .g_sharp:
                return "G#"
            case .a:
                return "A"
            case .a_sharp:
                return "A#"
            case .b:
                return "B"
            }
            
        case .latinNaming:
            
            switch self {
            case .c:
                return "Do"
            case .c_sharp:
                return "Do#"
            case .d:
                return "Ré"
            case .d_sharp:
                return "Ré#"
            case .e:
                return "Mi"
            case .f:
                return "Fa"
            case .f_sharp:
                return "Fa#"
            case .g:
                return "Sol"
            case .g_sharp:
                return "Sol#"
            case .a:
                return "La"
            case .a_sharp:
                return "La#"
            case .b:
                return "Si"
            }
        }
    }
    
    
    var isSharp: Bool { return self.description.contains("#") }
}
