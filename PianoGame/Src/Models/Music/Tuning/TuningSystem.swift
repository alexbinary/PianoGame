
import Foundation



protocol TuningSystem {
    
    
    func frequency(for note: Note) -> Frequency
    
    func closestNote(for frequency: Frequency) -> Note
    
    func distanceToClosestNote(from frequency: Frequency) -> FrequencyRatio
}
