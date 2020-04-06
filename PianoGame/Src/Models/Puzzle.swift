
import CoreGraphics



struct Puzzle {

    
    let startingNote: Legacy_Note
    
    let visibleNotes: Set<Legacy_Note>
    let hiddenNoteNames: Set<Legacy_Note>
    
    let expectedNote: Legacy_Note
    let distanceToPreviousPuzzle: CGFloat
    
    
    init(startingNote: Legacy_Note, visibleNotes: Set<Legacy_Note> = Set<Legacy_Note>(Legacy_Note.allCases), hiddenNoteNames: Set<Legacy_Note> = [], expectedNote: Legacy_Note, distanceToPreviousPuzzle: CGFloat = 800) {
        
        self.startingNote = startingNote
        self.visibleNotes = visibleNotes
        self.hiddenNoteNames = hiddenNoteNames
        self.expectedNote = expectedNote
        self.distanceToPreviousPuzzle = distanceToPreviousPuzzle
    }
    
    
    static func random(startingWith startingNote: Legacy_Note) -> Puzzle {
        
        let visibleNotes = Set<Legacy_Note>(Legacy_Note.allCases.filter { !$0.isSharp })
        let expectedNote: Legacy_Note = visibleNotes.randomElement()!
        
        var hiddenNoteNames: Set<Legacy_Note> = [ expectedNote ]
        while hiddenNoteNames.count < 5 {
            hiddenNoteNames.insert(visibleNotes.randomElement()!)
        }
        
        return Puzzle(startingNote: startingNote,
                      visibleNotes: visibleNotes,
                      hiddenNoteNames: hiddenNoteNames,
                      expectedNote: expectedNote)
    }
}
