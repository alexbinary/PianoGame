
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
}
