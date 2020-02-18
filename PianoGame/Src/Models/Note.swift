

enum Note : CaseIterable {

    
    case c
    case c_sharp
    case d
    case d_sharp
    case e
    case f
    case f_sharp
    case g
    case g_sharp
    case a
    case a_sharp
    case b
    
    
    init(fromNoteCode code: UInt) {
        
        let originalNoteCode = Int(code)
        let C4NoteCode = 60
        let noteCodeRelativeToC4 = originalNoteCode - C4NoteCode    // align code on the 4th octave
        let finalNoteCode = noteCodeRelativeToC4 + 5*12 // add as many octaves as needed to guarantee the code is always positive while staying properly aligned on the octaves
        
        self = Note.allCases[finalNoteCode % Note.allCases.count]
    }
}


extension Note: CustomStringConvertible {
    
    
    var description: String {
        
        let mapping: [Note: String] = [
            .c: "C",
            .c_sharp: "C#",
            .d: "D",
            .d_sharp: "D#",
            .e: "E",
            .f: "F",
            .f_sharp: "F#",
            .g: "G",
            .g_sharp: "G#",
            .a: "A",
            .a_sharp: "A#",
            .b: "B",
        ]
        
        return mapping[self]!
    }
}
