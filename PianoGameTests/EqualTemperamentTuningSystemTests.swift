
import XCTest

@testable import PianoGame



class EqualTemperamentTuningSystemTests: XCTestCase {
    
    
    let frequencyComparisonPrecision: Double = 0.001
    
    
    func test_frequencyForNote() {
        
        let tuningSystem = EqualTemperamentTuningSystem(withReferenceNote: .A4, atFrequency: .standardA4)
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .A4).valueInHertz,
            440, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .A0).valueInHertz,
            27.5, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .middleC).valueInHertz,
            261.6256, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .C8).valueInHertz,
            4186.009, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: Note(.g, at: Octave(2))).valueInHertz,
            97.99886, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: Note(.f, at: Octave(3))).valueInHertz,
            174.6141, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: Note(.e, at: Octave(6))).valueInHertz,
            1318.510, within: self.frequencyComparisonPrecision
        )
    }
}
