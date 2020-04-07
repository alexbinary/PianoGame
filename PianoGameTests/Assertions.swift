
import XCTest



func XCTAssertEqual(_ expr1: Double, _ expr2: Double, within epsilon: Double) {
    
    XCTAssertTrue(abs(expr1 - expr2) < epsilon)
}
