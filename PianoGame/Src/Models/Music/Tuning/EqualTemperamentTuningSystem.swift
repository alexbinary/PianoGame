
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
    
    
    func closestNote(for frequency: Frequency) -> Note {
        
        self.referenceNote.addingHalfSteps(Int(self.numberOfNotesBetweenReferenceNote(and: frequency).rounded(.toNearestOrAwayFromZero)))
    }
    
    
    func distanceToClosestNote(from frequency: Frequency) -> FrequencyRatio {
        
        return frequency/self.frequency(for: self.closestNote(for: frequency))
    }
    
    
    private func numberOfNotesBetweenReferenceNote(and frequency: Frequency) -> Double {
        
        return (frequency/self.referenceFrequency).valueInCents / 100
    }
}
