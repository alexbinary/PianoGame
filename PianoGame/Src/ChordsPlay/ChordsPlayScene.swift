
import SpriteKit
import MIKMIDI



class ChordsPlayScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    let noteNamingForChords: NoteNaming = .englishNaming
    
    var chordLabelNode: SKLabelNode! = nil
    
    var currentChordNoteCodes: Set<NoteCode> = []
    var currentPlayedNoteCodes: Set<NoteCode> = []
    
    let authorizedChordQualities: [Quality] = [ .major ]
    let authorizedChordInversions: ClosedRange<Int> = 0...0
    let authorizedOctaves: ClosedRange<Int> = 4...4
    let authorizedRootNotes: [Int] = [0, 2, 4, 5, 7, 9, 11] // white keys only
    
    
    var correctNotesPlayed = false
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.backgroundColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
        
        self.chordLabelNode = SKLabelNode()
        self.chordLabelNode.fontColor = .black
        self.chordLabelNode.fontSize = 64
        self.chordLabelNode.fontName = "HelveticaNeue"
        self.chordLabelNode.verticalAlignmentMode = .top
        self.chordLabelNode.horizontalAlignmentMode = .center
        self.chordLabelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 100)
        self.addChild(self.chordLabelNode)
        
        self.nextExercise()
        self.updateDisplay()
        
        self.connectToMIDIDevice()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.nextExercise()
    }
    
    
    func connectToMIDIDevice() {
        
        guard let device = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == self.MIDIDeviceName }) else {
            fatalError("MIDI device \"\(self.MIDIDeviceName)\" not found. Is it turned on?")
        }
        
        try! MIKMIDIDeviceManager.shared.connect(device) { (_, commands) in
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    if noteOnCommand.velocity > 0 {
                        self.onNoteOn(noteCode: noteOnCommand.note, velocity: noteOnCommand.velocity)
                    } else {
                        self.onNoteOff(noteCode: noteOnCommand.note)
                    }
                } else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    self.onNoteOff(noteCode: noteOffCommand.note)
                }
            }
        }
    }
    
    
    func onNoteOn(noteCode: NoteCode, velocity: Velocity) {
        
        self.currentPlayedNoteCodes.insert(noteCode)
        
        self.updateDisplay()
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
        
        self.currentPlayedNoteCodes.remove(noteCode)
        
        self.updateDisplay()
        
        if self.correctNotesPlayed {
            
            self.correctNotesPlayed = false
            self.nextExercise()
        }
    }
    
    
    func updateDisplay() {
        
        let correct = self.currentPlayedNoteCodes.isNotEmpty && self.currentPlayedNoteCodes == self.currentChordNoteCodes
        
        self.chordLabelNode.fontColor = correct ? .green : .black
        
        if correct {
            self.correctNotesPlayed = true
        }
    }
    
    
    func nextExercise() {
        
        let keyboardLowestNoteCode: NoteCode = 21
        let keyboardHighestNoteCode: NoteCode = 109
        
        let octaveLength: NoteCode = 12
        
        let lowestCNoteCode: NoteCode = 24
        let lowestCOctave: Int = 1
        
        let maximumOffsetToRootNote: NoteCode = 16  // standard perfect major/minor chord, inverted up to two times
        
        let minimumEligibleNoteCode: NoteCode = keyboardLowestNoteCode
        let maximumEligibleNoteCode: NoteCode = keyboardHighestNoteCode - maximumOffsetToRootNote
        
        let lowestNoteCodeOfLowestAuthorizedOctave: NoteCode = lowestCNoteCode + NoteCode(self.authorizedOctaves.lowerBound - lowestCOctave) * octaveLength
        let highestNoteCodeOfHighestAuthorizedOctave: NoteCode = lowestCNoteCode + NoteCode(self.authorizedOctaves.upperBound - lowestCOctave) * octaveLength + (octaveLength - 1)
        
        let minimumNoteCode: NoteCode = max(lowestNoteCodeOfLowestAuthorizedOctave, minimumEligibleNoteCode)
        let maximumNoteCode: NoteCode = min(highestNoteCodeOfHighestAuthorizedOctave, maximumEligibleNoteCode)
        
        let chordRootNoteCode: NoteCode = (minimumNoteCode...maximumNoteCode).randomElement()!
        
        let quality = self.authorizedChordQualities.randomElement()
        
        //
        
        var referenceNoteCode: NoteCode = lowestCNoteCode
        var referenceOctave: Int = lowestCOctave
        
        while referenceNoteCode > keyboardLowestNoteCode {
            
            referenceNoteCode -= octaveLength
            referenceOctave -= 1
        }
        
        let octave: Int = Int(chordRootNoteCode - referenceNoteCode) / Int(octaveLength) + referenceOctave
        
        let noteCodeRelativeToCInSameOctave = chordRootNoteCode - lowestCNoteCode - NoteCode(octave - lowestCOctave) * octaveLength
        
        if !self.authorizedRootNotes.contains(Int(noteCodeRelativeToCInSameOctave)) {
            
            self.nextExercise()
            return
        }
        
        print(noteCodeRelativeToCInSameOctave)
        
        let offsetThird: NoteCode = quality == .major ? 4 : 3
        let offsetFifth: NoteCode = quality == .diminished ? 6 : 7
        
        var chordNoteCodes = [chordRootNoteCode, chordRootNoteCode + offsetThird, chordRootNoteCode + offsetFifth]
        
        if self.authorizedChordInversions.upperBound > 0 {
            for i in 1...self.authorizedChordInversions.upperBound {
                if i > self.authorizedChordInversions.lowerBound, Bool.random() {
                    break
                } else {
                    chordNoteCodes = [chordNoteCodes[1], chordNoteCodes[2], chordNoteCodes[0] + 12]
                    print("inverting")
                }
            }
        }
        
        self.currentChordNoteCodes = Set<NoteCode>(chordNoteCodes)
        
        var chordName = Note(fromNoteCode: chordRootNoteCode).name(using: self.noteNamingForChords)
        
        if quality != .major {
            chordName += quality == .minor ? "m" : "d"
        }
        if chordNoteCodes[0] != chordRootNoteCode {
            chordName += "/" + Note(fromNoteCode: chordNoteCodes[0]).name(using: self.noteNamingForChords)
        }
        
        self.chordLabelNode.text = "\(chordName) - \(octave)"
    }
}
