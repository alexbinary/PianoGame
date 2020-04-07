
import XCTest

@testable import PianoGame



class EqualTemperamentTuningSystemTests: XCTestCase {
    
    
    let frequencyValueComparisonPrecision: Double = 0.001
    let frequencyRatioComparisonPrecision: Double = 0.0001
    
    
    func test_frequencyForNote() {
        
        let tuningSystem = EqualTemperamentTuningSystem(withReferenceNote: .A4, atFrequency: .standardA4)
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .A4).valueInHertz,
            440, within: self.frequencyValueComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .A0).valueInHertz,
            27.5, within: self.frequencyValueComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .middleC).valueInHertz,
            261.6256, within: self.frequencyValueComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: .C8).valueInHertz,
            4186.009, within: self.frequencyValueComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: Note(.g, at: Octave(2))).valueInHertz,
            97.99886, within: self.frequencyValueComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: Note(.f, at: Octave(3))).valueInHertz,
            174.6141, within: self.frequencyValueComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.frequency(for: Note(.e, at: Octave(6))).valueInHertz,
            1318.510, within: self.frequencyValueComparisonPrecision
        )
    }
    
    
    func test_closestNoteForFrequency() {
    
        let tuningSystem = EqualTemperamentTuningSystem(withReferenceNote: .A4, atFrequency: .standardA4)
        
        XCTAssertEqual(
            tuningSystem.closestNote(for: 440.Hz),
            Note.A4
        )
        
        XCTAssertEqual(
            tuningSystem.closestNote(for: 27.5.Hz),
            Note.A0
        )
        
        XCTAssertEqual(
            tuningSystem.closestNote(for: 261.Hz),
            Note.middleC
        )
    }
    
    
    func test_distanceToClosestNoteFromFrequency() {
    
        let tuningSystem = EqualTemperamentTuningSystem(withReferenceNote: .A4, atFrequency: .standardA4)
        
        XCTAssertEqual(
            tuningSystem.distanceToClosestNote(from: 440.Hz).valueInCents,
            0, within: self.frequencyRatioComparisonPrecision
        )
        
        XCTAssertEqual(
            tuningSystem.distanceToClosestNote(from: 27.5.Hz).valueInCents,
            0, within: self.frequencyRatioComparisonPrecision
        )
        
        // Pythagorean comma
        XCTAssertEqual(
            tuningSystem.distanceToClosestNote(from: (27.5 * pow(3.0/2.0, 12)).Hz).valueInCents,
            23.46, within: self.frequencyRatioComparisonPrecision
        )
    }
}
