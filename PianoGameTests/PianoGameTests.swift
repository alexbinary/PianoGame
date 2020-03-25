
import XCTest
import PianoGame



class NoteTests: XCTestCase {
    
    
    func test_allCases() {
        
        XCTAssertEqual(Note.allCases, [Note]([
            .c,
            .c_sharp,
            .d,
            .d_sharp,
            .e,
            .f,
            .f_sharp,
            .g,
            .g_sharp,
            .a,
            .a_sharp,
            .b,
        ]))
    }
}
