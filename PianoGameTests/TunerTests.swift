
import XCTest

@testable import PianoGame



class TunerTests: XCTestCase {
    
    
    func test_frequencyForNote() {
        
        let tuningSystem: TuningSystem = .equalTemperament(referenceNote: .A4, referenceFrequency: .standardA4)
        
        XCTAssertEqual(
            Tuner.frequency(for: .A4, using: tuningSystem),
            440.Hz
        )
        
//        XCTAssertEqual(
//            Tuner.frequency(for: .middleC, using: tuningSystem),
//            261.6255653005986.Hz
//        )
    }
}
