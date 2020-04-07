
import XCTest

@testable import PianoGame



class FrequencyRatioTests: XCTestCase {
    
    
    func test_init_betweenF1andF2() {
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 440.Hz).rawValue,
            1.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 880.Hz, and: 440.Hz).rawValue,
            2.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 880.Hz).rawValue,
            0.5
        )
    }
    
    
    func test_property_rawValue() {
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 440.Hz).rawValue,
            1.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 880.Hz, and: 440.Hz).rawValue,
            2.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 880.Hz).rawValue,
            0.5
        )
    }
    
    
    func test_property_valueInOctave() {
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 440.Hz).valueInOctaves,
            0.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 880.Hz).valueInOctaves,
            -1.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 880.Hz, and: 440.Hz).valueInOctaves,
            1.0
        )
    }
}
