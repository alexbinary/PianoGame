
import XCTest

@testable import PianoGame



class FrequencyTests: XCTestCase {
    
    
    func test_init_valueInHertz() {
        
        let frequencyValue: Double = 440
        
        XCTAssertEqual(
            Frequency(valueInHertz: frequencyValue).valueInHertz,
            frequencyValue
        )
    }
    
    
    func test_property_valueInHertz() {
        
        let frequencyValue: Double = 440
        
        XCTAssertEqual(
            frequencyValue.Hz.valueInHertz,
            frequencyValue
        )
    }
    
    
    func test_property_standardA4() {
        
        XCTAssertEqual(
            Frequency.standardA4,
            440.Hz
        )
    }
    
    
    func test_property_description() {
        
        let frequency = 440.Hz
        
        XCTAssertEqual(
            frequency.description,
            String(format: "%.2f Hz", frequency.valueInHertz)
        )
    }
    
    
    func test_operator_lowerThan() {
        
        XCTAssertTrue(440.Hz < 441.Hz)
        XCTAssertFalse(441.Hz < 440.Hz)
        XCTAssertFalse(440.Hz < 440.Hz)
    }
    
    
    func test_operator_multiplyByDouble() {
        
        let frequencyValue: Double = 440
        let multiplier: Double = 2
        
        XCTAssertEqual(
            frequencyValue.Hz * multiplier,
            (frequencyValue * multiplier).Hz
        )
    }
    
    
    func test_operator_dividedBy() {
        
        let frequency1 = 440.Hz
        let frequency2 = 880.Hz
        
        XCTAssertEqual(
            frequency1/frequency2,
            FrequencyRatio(between: frequency1, and: frequency2)
        )
    }
}


class FrequencyTests_ExtensionsOnOtherClasses: XCTestCase {
    
    
    func test_double_property_Hz() {
        
        let frequencyValue: Double = 440
        
        XCTAssertEqual(
            frequencyValue.Hz,
            Frequency(valueInHertz: frequencyValue)
        )
    }
}
