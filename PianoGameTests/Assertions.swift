
import XCTest



func XCTAssertEqual(_ expr1: Double, _ expr2: Double, within epsilon: Double, file: StaticString = #file, line: UInt = #line) {
    
    XCTAssertLessThan(abs(expr1 - expr2), epsilon, file: file, line: line)
}
