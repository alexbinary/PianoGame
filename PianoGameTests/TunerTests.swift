
import XCTest

@testable import PianoGame



class TunerTests: XCTestCase {
    
    
    let frequencyComparisonPrecision: Double = 0.01
    
    
    func test_frequencyForNote() {
        
        let tuningSystem: TuningSystem = .equalTemperament(referenceNote: .A4, referenceFrequency: .standardA4)
        
        XCTAssertEqual(
            Tuner.frequency(for: .A4, using: tuningSystem),
            440.Hz
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: .middleC, using: tuningSystem).valueInHertz,
            261.63,
            within: self.frequencyComparisonPrecision
        )
    }
}
