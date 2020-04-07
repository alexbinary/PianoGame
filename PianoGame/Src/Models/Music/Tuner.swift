
import Foundation



struct Tuner {
    
    
    static func frequency(for note: Note, using tuningSystem: TuningSystem) -> Frequency {
        
        switch tuningSystem {
            
        case .equalTemperament(let referenceNote, let referenceFrequency):
            return self.frequencyUsingEqualTemperament(for: note, withReference: referenceNote, at: referenceFrequency)
            
        default:
            fatalError("unsupported tuning system")
        }
    }
    
    
    static func frequencyUsingEqualTemperament(for note: Note, withReference referenceNote: Note, at referenceFrequency: Frequency) -> Frequency {
        
        let notes = note.numberOfNotes(relativeTo: referenceNote)
        
        return referenceFrequency + notes * 100.cents
    }
}
