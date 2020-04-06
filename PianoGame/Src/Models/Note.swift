
import Foundation



public struct Note {
    
    
    let name: NoteName
    let octave: Octave
    let alteration: Alteration?
    
    
    init(_ name: NoteName, _ alteration: Alteration? = nil, at octave: Octave) {
        
        self.name = name
        self.alteration = alteration
        self.octave = octave
    }
    
    
    static let A4 = Note(.a, at: Octave(4))
    
    
    func numberOfNotes(relativeTo referenceNote: Note) -> Int {
        
        (self.octave.absoluteNumber - referenceNote.octave.absoluteNumber) * Note.numberOfNotesInOneOctave + (self.indexInChromaticScale - referenceNote.indexInChromaticScale)
    }
    
    
    static let numberOfNotesInOneOctave: Int = 12
    
    
    var indexInChromaticScale: Int {
        
        var index: Int
        
        switch self.name {
            
        case .c:
            index = 0
        case .d:
            index = 2
        case .e:
            index = 4
        case .f:
            index = 5
        case .g:
            index = 7
        case .a:
            index = 9
        case .b:
            index = 11
        }
        
        switch self.alteration {
            
        case .sharp:
            index += 1
            
        case .flat:
            index -= 1
            
        case nil:
            index += 0
        }
        
        return index % Note.numberOfNotesInOneOctave
    }
    
    
    var upOneNoteName: Note {
        
        let newName: NoteName
        
        switch self.name {
            
        case .c:
            newName = .d
        case .d:
            newName = .e
        case .e:
            newName = .f
        case .f:
            newName = .g
        case .g:
            newName = .a
        case .a:
            newName = .b
        case .b:
            newName = .c
        }
        
        return self.replacingNoteName(with: newName)
    }
    
    
    var downOneNoteName: Note {
        
        let newName: NoteName
        
        switch self.name {
            
        case .c:
            newName = .b
        case .d:
            newName = .c
        case .e:
            newName = .d
        case .f:
            newName = .e
        case .g:
            newName = .f
        case .a:
            newName = .g
        case .b:
            newName = .a
        }
        
        return self.replacingNoteName(with: newName)
    }
    
    
    func replacingNoteName(with newName: NoteName) -> Note {
        
        return Note(newName, self.alteration, at: self.octave)
    }
    
    
    var withoutAlteration: Note {
        
        return Note(self.name, at: self.octave)
    }
    
    
    func withAlteration(with newAlteration: Alteration) -> Note {
        
        return Note(self.name, newAlteration, at: self.octave)
    }
    
    
    var oneHalfStepUp: Note {
        
        switch self.alteration {
            
        case .flat:
            return self.withoutAlteration
            
        case nil:
            return self.withAlteration(with: .sharp)
            
        case .sharp:
            var note = self.upOneNoteName
            if ![.e, .b].contains(self.name) {
                note = note.withoutAlteration
            }
            return note
        }
    }
    
    
    var oneHalfStepDown: Note {
        
        switch self.alteration {
            
        case .sharp:
            return self.withoutAlteration
            
        case nil:
            return self.withAlteration(with: .flat)
            
        case .flat:
            var note = self.downOneNoteName
            if ![.f, .c].contains(self.name) {
                note = note.self.withoutAlteration
            }
            return note
        }
    }
    
    
    func addingHalfSteps(_ halfSteps: Int) -> Note {
        
        var note = self
        
        if halfSteps > 0 {

            for _ in 1...halfSteps {
                note = note.oneHalfStepUp
            }
            
        } else if halfSteps < 0 {
            
            for _ in 1...(-halfSteps) {
                note = note.oneHalfStepDown
            }
        }
        
        return note
    }
}
