

public enum NoteName : CaseIterable {
    
    
    case c
    case d
    case e
    case f
    case g
    case a
    case b
}


public extension NoteName {
    
    
    func displayName(in naming: NoteNaming) -> String {
        
        switch naming {
            
        case .englishNaming:
            
            switch self {
            case .c:
                return "C"
            case .d:
                return "D"
            case .e:
                return "E"
            case .f:
                return "F"
            case .g:
                return "G"
            case .a:
                return "A"
            case .b:
                return "B"
            }
            
        case .latinNaming:
            
            switch self {
            case .c:
                return "Do"
            case .d:
                return "Ré"
            case .e:
                return "Mi"
            case .f:
                return "Fa"
            case .g:
                return "Sol"
            case .a:
                return "La"
            case .b:
                return "Si"
            }
        }
    }
}
