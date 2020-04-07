
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
            Frequency(valueInHertz: frequencyValue).valueInHertz,
            frequencyValue
        )
    }
    
    
    func test_property_standardA4() {
        
        XCTAssertEqual(
            Frequency.standardA4.valueInHertz,
            440
        )
    }
    
    
    func test_property_description() {
        
        let frequencyValue: Double = 440
        
        XCTAssertEqual(
            Frequency(valueInHertz: frequencyValue).description,
            String(format: "%.2f Hz", frequencyValue)
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
            Frequency(valueInHertz: frequencyValue) * multiplier,
            Frequency(valueInHertz: frequencyValue * multiplier)
        )
    }
    
    
    func test_extension_double_Hz() {
        
        let frequencyValue: Double = 440
        
        XCTAssertEqual(
            frequencyValue.Hz,
            Frequency(valueInHertz: frequencyValue)
        )
    }
}
