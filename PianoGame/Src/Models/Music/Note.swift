
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
        
        var newName: NoteName
        var newOctave = self.octave
        
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
            newOctave = Octave(self.octave.absoluteNumber + 1)
        }
        
        return self.replacingNoteName(with: newName).replacingOctave(with: newOctave)
    }
    
    
    var downOneNoteName: Note {
        
        let newName: NoteName
        var newOctave = self.octave
        
        switch self.name {
            
        case .c:
            newName = .b
            newOctave = Octave(self.octave.absoluteNumber - 1)
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
        
        return self.replacingNoteName(with: newName).replacingOctave(with: newOctave)
    }
    
    
    func replacingOctave(with newOctave: Octave) -> Note {
        
        return Note(self.name, self.alteration, at: newOctave)
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


extension Note: Comparable {
    
    
    public static func < (lhs: Note, rhs: Note) -> Bool {
        
        let referenceNote: Note = .A4
        
        return lhs.numberOfNotes(relativeTo: referenceNote) < rhs.numberOfNotes(relativeTo: referenceNote)
    }
    
    
    public static func == (lhs: Note, rhs: Note) -> Bool {
        
        let referenceNote: Note = .A4
        
        return lhs.numberOfNotes(relativeTo: referenceNote) == rhs.numberOfNotes(relativeTo: referenceNote)
    }
}


extension Note: Strideable {
    
    
    public typealias Stride = Int
    
    
    public func distance(to other: Note) -> Int {
        
        return self.numberOfNotes(relativeTo: other)
    }
    
    public func advanced(by n: Int) -> Note {
        
        return self.addingHalfSteps(n)
    }
}


extension Note: CustomStringConvertible {
    
    
    public var description: String {
        
        var name: String
        
        switch (self.numberOfNotes(relativeTo: .A4) - 3 + 12*12) % 12 {
            
        case 0:
            name = "C"
        case 1:
            name = "C#/Db"
        case 2:
            name = "D"
        case 3:
            name = "D#/Eb"
        case 4:
            name = "E"
        case 5:
            name = "F"
        case 6:
            name = "F#/Gb"
        case 7:
            name = "G"
        case 8:
            name = "G#/Ab"
        case 9:
            name = "A"
        case 10:
            name = "A#/Bb"
        case 11:
            name = "B"
        default:
            name = ""
        }
        
        name += "\(self.octave.absoluteNumber)"
        
        return name
    }
}


extension Note {
    
    
    static let A0 = Note(.a, at: Octave(0))
    
    static let middleC = Note(.c, at: Octave(4))
    
    static let A4 = Note(.a, at: Octave(4))
    
    static let C8 = Note(.c, at: Octave(8))
}
