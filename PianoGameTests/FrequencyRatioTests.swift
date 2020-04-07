
import XCTest

@testable import PianoGame



class FrequencyRatioTests: XCTestCase {
    
    
    func test_init_betweenF1andF2() {
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 440.Hz).ratio,
            1.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 880.Hz, and: 440.Hz).ratio,
            2.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 880.Hz).ratio,
            0.5
        )
    }
    
    
    func test_valueInOctave() {
        
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
