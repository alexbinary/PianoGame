
import Foundation



enum TuningSystem {
    
    case equalTemperament(referenceNote: Note, referenceFrequency: Frequency)
    case pythagorean(referenceNote: Note, referenceFrequency: Frequency)
    case mesotonic
    case physicist
}
