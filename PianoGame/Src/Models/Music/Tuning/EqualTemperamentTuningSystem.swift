
import Foundation



struct EqualTemperamentTuningSystem: TuningSystem {
    
    
    let referenceNote: Note
    let referenceFrequency: Frequency
    
    
    init(withReferenceNote referenceNote: Note, atFrequency referenceFrequency: Frequency) {
        
        self.referenceNote = referenceNote
        self.referenceFrequency = referenceFrequency
    }
        
        
    func frequency(for note: Note) -> Frequency {
        
        return self.referenceFrequency + note.numberOfNotes(relativeTo: self.referenceNote) * 100.cents
    }
}
