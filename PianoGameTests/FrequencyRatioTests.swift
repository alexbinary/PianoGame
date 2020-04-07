
import XCTest

@testable import PianoGame



class FrequencyRatioTests: XCTestCase {
    
    
    func test_init_rawValue() {
        
        XCTAssertEqual(
            FrequencyRatio(rawValue: 1.0).rawValue,
            1.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(rawValue: 2.0).rawValue,
            2.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(rawValue: 0.5).rawValue,
            0.5
        )
    }
    
    
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
    
    
    func test_property_valueInCents() {
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 440.Hz).valueInCents,
            0.0
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 440.Hz, and: 880.Hz).valueInCents,
            -1_200
        )
        
        XCTAssertEqual(
            FrequencyRatio(between: 880.Hz, and: 440.Hz).valueInCents,
            1_200
        )
    }
}


class FrequencyRatioTests_ExtensionsOnOtherClasses: XCTestCase {
    
    
    func test_double_property_octaves() {
        
        XCTAssertEqual(
            Double(1.0).octaves,
            FrequencyRatio(rawValue: 2)
        )
        
        XCTAssertEqual(
            Double(2.0).octaves,
            FrequencyRatio(rawValue: 4)
        )
    }
    
    
    func test_double_property_cents() {
        
        XCTAssertEqual(
            Double(1_200.0).cents,
            1.octaves
        )
        
        XCTAssertEqual(
            Double(2_400.0).cents,
            2.octaves
        )
    }
    
    
    func test_int_property_octaves() {
        
        XCTAssertEqual(
            Int(1).octaves,
            FrequencyRatio(rawValue: 2)
        )
        
        XCTAssertEqual(
            Int(2).octaves,
            FrequencyRatio(rawValue: 4)
        )
    }
    
    
    func test_int_property_cents() {
        
        XCTAssertEqual(
            Int(1_200).cents,
            1.octaves
        )
        
        XCTAssertEqual(
            Int(2_400).cents,
            2.octaves
        )
    }
}
