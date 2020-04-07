
import Foundation



struct Pitch {
    
    
    let frequency: Frequency
    
    
    init(at frequency: Frequency) {
        
        self.frequency = frequency
    }
    
    
    func numberOfNotes(relativeTo referenceNote: Note) -> Double {
        
        let pitchNumberOfOctavesRelativeToA4: Double = log2(self.frequency.valueInHertz / Frequency.standardA4.valueInHertz)
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


extension Pitch: CustomStringConvertible {
    
    
    public var description: String {
        
        return "\(self.frequency.description.paddedLeft(toLength: 20)) \t \(self.closestNote.description.paddedLeft(toLength: 7)) \t \(String(format: "%0.2f", self.numberOfNotesToClosestNote).paddedLeft(toLength: 5))"
    }
}


extension String {
    
    
    func paddedLeft(toLength length: Int) -> String {
        
        var paddedString = self
        
        let padLength = length - self.count
        if padLength > 0 {
            for _ in 1...padLength {
                paddedString.insert(" ", at: paddedString.startIndex)
            }
        }
        
        return paddedString
    }
}
