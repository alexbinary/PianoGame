
import XCTest

@testable import PianoGame



class TunerTests: XCTestCase {
    
    
    let frequencyComparisonPrecision: Double = 0.001
    
    
    func test_frequencyForNote() {
        
        let equalTemperamentWithA4at440Hz: TuningSystem = .equalTemperament(referenceNote: .A4, referenceFrequency: .standardA4)
        
        XCTAssertEqual(
            Tuner.frequency(for: .A0, using: equalTemperamentWithA4at440Hz).valueInHertz,
            27.5, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: Note(.g, at: Octave(2)), using: equalTemperamentWithA4at440Hz).valueInHertz,
            97.99886, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: Note(.f, at: Octave(3)), using: equalTemperamentWithA4at440Hz).valueInHertz,
            174.6141, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: Note(.e, at: Octave(6)), using: equalTemperamentWithA4at440Hz).valueInHertz,
            1318.510, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: .A4, using: equalTemperamentWithA4at440Hz).valueInHertz,
            440, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: .middleC, using: equalTemperamentWithA4at440Hz).valueInHertz,
            261.6256, within: self.frequencyComparisonPrecision
        )
        
        XCTAssertEqual(
            Tuner.frequency(for: .C8, using: equalTemperamentWithA4at440Hz).valueInHertz,
            4186.009, within: self.frequencyComparisonPrecision
        )
    }
}
