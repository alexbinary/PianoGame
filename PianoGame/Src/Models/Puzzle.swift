
import CoreGraphics



struct Puzzle {

    
    let startingNote: Note
    
    let visibleNotes: Set<Note>
    let hiddenNoteNames: Set<Note>
    
    let expectedNote: Note
    let distanceToPreviousPuzzle: CGFloat
    
    
    init(startingNote: Note, visibleNotes: Set<Note> = Set<Note>(Note.allCases), hiddenNoteNames: Set<Note> = [], expectedNote: Note, distanceToPreviousPuzzle: CGFloat = 800) {
        
        self.startingNote = startingNote
        self.visibleNotes = visibleNotes
        self.hiddenNoteNames = hiddenNoteNames
        self.expectedNote = expectedNote
        self.distanceToPreviousPuzzle = distanceToPreviousPuzzle
    }
    
    
    static func random(startingWith startingNote: Note) -> Puzzle {
        
        let visibleNotes = Set<Note>(Note.allCases.filter { !$0.isSharp })
        let expectedNote: Note = visibleNotes.randomElement()!
        
        var hiddenNoteNames: Set<Note> = [ expectedNote ]
        while hiddenNoteNames.count < 5 {
            hiddenNoteNames.insert(visibleNotes.randomElement()!)
        }
        
        return Puzzle(startingNote: startingNote,
                      visibleNotes: visibleNotes,
                      hiddenNoteNames: hiddenNoteNames,
                      expectedNote: expectedNote)
    }
}
