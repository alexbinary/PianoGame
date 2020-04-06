
import Foundation



struct Pitch {
    
    
    let frequency: Frequency
    
    
    init(at frequency: Frequency) {
        
        self.frequency = frequency
    }
    
    
    func numberOfNotes(relativeTo referenceNote: Note) -> Double {
        
        let pitchNumberOfOctavesRelativeToA4: Double = log2(self.frequency.valueInHertz / Frequency.A4.valueInHertz)
        let pitchNumberOfNotesRelativeToA4 = pitchNumberOfOctavesRelativeToA4 * Double(Note.numberOfNotesInOneOctave)
        
        return pitchNumberOfNotesRelativeToA4 - Double(referenceNote.numberOfNotes(relativeTo: .A4))
    }
    
    
    var closestNote: Note {
        
        Note.A4.addingHalfSteps(Int(self.numberOfNotes(relativeTo: .A4).rounded(.toNearestOrAwayFromZero)))
    }
    
    
    var numberOfNotesToClosestNote: Double {
        
        self.numberOfNotes(relativeTo: .A4) - self.numberOfNotes(relativeTo: .A4).rounded(.toNearestOrAwayFromZero)
    }
}
