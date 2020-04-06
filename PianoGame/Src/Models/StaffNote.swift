
import Foundation



struct StaffNote {
    
    let note: Legacy_Note
    let octave: Int
    
    init(_ note: Legacy_Note, octave: Int) {
        self.note = note
        self.octave = octave
    }
    
    func upOnOctave() -> StaffNote {
        StaffNote(self.note, octave: self.octave + 1)
    }
    
    func addingStaffOffset(_ offset: Int) -> StaffNote {
        
        let naturalNotes = Legacy_Note.allCases.filter { !$0.isSharp }
        let absoluteIndex = naturalNotes.firstIndex(of: self.note)! + offset
        let note = naturalNotes[(absoluteIndex + 7) % 7]
        
        var octave = self.octave
        
        if absoluteIndex > 6 {
            octave += Int(absoluteIndex)/Int(7)
        }
        if absoluteIndex < 0 {
            octave -= Int(absoluteIndex)/Int(7) + 1
        }
        
        return StaffNote(note, octave: octave)
    }
}
