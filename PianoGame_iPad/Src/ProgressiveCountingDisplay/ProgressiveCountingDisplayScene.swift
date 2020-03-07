
import Foundation
import SpriteKit
import MIKMIDI



class ProgressiveCountingDisplayScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    struct ColorPalette {
        
        let backgroundColor: NSColor
        let foregroundColor: NSColor
        let correctColor: NSColor
        let incorrectColor: NSColor
    }
    
    let colorPaletteDefault = ColorPalette(
        
        backgroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1),
        correctColor: .systemGreen,
        incorrectColor: .systemRed
    )
    
    let colorPaletteDarkMode = ColorPalette(
        
        backgroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1),
        correctColor: .systemGreen,
        incorrectColor: .systemRed
    )
    
    var colorPalette: ColorPalette!
    
    
    var noteDisplayNodeByNote: [Note: SKShapeNode] = [:]
    
    
    var defaultScaleByNote: [Note: CGFloat] = {
       
        var scaleByNote: [Note: CGFloat] = [
            .c: 1,
            .c_sharp: 1,
            .d: 1,
            .d_sharp: 1,
            .e: 1,
            .f: 1,
            .f_sharp: 1,
            .g: 1,
            .g_sharp: 1,
            .a: 1,
            .a_sharp: 1,
            .b: 1,
        ]
        
//        // promote "white" notes
//
//        for (note, scale) in scaleByNote {
//            if note.isSharp {
//                scaleByNote[note] = 0.7
//            }
//        }
        
//        // promote whole steps
//
//        for (index, note) in Note.allCases.enumerated() {
//            if index % 2 == 1 {
//                scaleByNote[note] = 0.7
//            }
//        }
        
//        // promote notes of the major scale
//
//        for (index, note) in Note.allCases.enumerated() {
//            if ![1,3,5,6,8,10,12].contains(index + 1) {
//                scaleByNote[note] = 0.7
//            }
//        }
        
        // promote notes of the natural minor scale
        
        for (index, note) in Note.allCases.enumerated() {
            if ![1,3,4,6,8,9,11].contains(index + 1) {
                scaleByNote[note] = 0.7
            }
        }
        
        return scaleByNote
    }()
    
    
    lazy var noteDisplayStateByNoteByPlayedNote: [Note: [Note: (targetScaleValue: CGFloat, appearAnimationDuration: TimeInterval)]] = {
        
        var noteDisplayStateByNoteByPlayedNote: [Note: [Note: (targetScaleValue: CGFloat, appearAnimationDuration: TimeInterval)]] = [:]
        
        for playedNote in Note.allCases {
            
            var noteDisplayStateByNote = [Note: (targetScaleValue: CGFloat, appearAnimationDuration: TimeInterval)]()
            
            // general animation settings
            
            let referenceScale: CGFloat = 1
            let scaleUpBaseAmplitude: CGFloat = 1.5
            let scaleUpAmplitudeForPlayedNote: CGFloat = 1.8
            
            let appearDurationForPlayedNote: Double = 0.1
            
            // filter notes that should be animated
            
            var affectedNotes: [Note] = []
            
            for note in Note.allCases {
                
                if defaultScaleByNote[note]! != 0 || note == playedNote {
                    affectedNotes.append(note)
                }
                
                if note == playedNote { break }
            }
            
            // init data structure for affected notes
            
            for note in affectedNotes {
            
                noteDisplayStateByNote[note] = (targetScaleValue: 0, appearAnimationDuration: 0)
            }
            
            // compute theoritical target scale for each note in an ascending pattern, assuming all notes start with the same size
            
            let playedNoteIndex = affectedNotes.firstIndex(of: playedNote)!
            
            for (index, note) in affectedNotes.enumerated() {
                
                // we want both :
                // - indexRatio = 1 when index = playedNoteIndex
                // - indexRatio > 0 when index = 0
                
                let indexRatio = CGFloat(index + 1) / CGFloat(playedNoteIndex + 1)
                
                let progression = pow(indexRatio, 2)    // make the curve parabolic instead of just linear
                
                noteDisplayStateByNote[note]!.targetScaleValue = referenceScale + (scaleUpBaseAmplitude - referenceScale) * progression
            }
            
            // compute animation duration of each note with a constant speed equal to the animation speed of the played note
            
            let speed = (noteDisplayStateByNote[playedNote]!.targetScaleValue - referenceScale) / CGFloat(appearDurationForPlayedNote)
            
            for note in affectedNotes {
                
                noteDisplayStateByNote[note]!.appearAnimationDuration = Double(noteDisplayStateByNote[note]!.targetScaleValue - referenceScale) / Double(speed)
            }
            
            // adjust target scale based on the actual default scale of the note
            
            for note in affectedNotes {
                
                let scaleRatio = noteDisplayStateByNote[note]!.targetScaleValue / referenceScale
                
                noteDisplayStateByNote[note]!.targetScaleValue = defaultScaleByNote[note]! * scaleRatio
            }
            
            // adjust target size of the played note to make it more prominent
            
            noteDisplayStateByNote[playedNote]!.targetScaleValue = scaleUpAmplitudeForPlayedNote
            
            // register data
            
            noteDisplayStateByNoteByPlayedNote[playedNote] = noteDisplayStateByNote
        }
        
        return noteDisplayStateByNoteByPlayedNote
    }()
    
    
    struct NoteAnimation {
        
        var targetScaleValue: CGFloat = 2
        var animationDuration: TimeInterval = 2
        
        var initialScaleValue: CGFloat! = nil
        var animationStartTime: TimeInterval! = nil
    }
    
    
    var activeAnimationsByNote: [Note: NoteAnimation] = [:]
    
    
    var activeNoteCodes: Set<NoteCode> = []
    var activeNotes: Set<Note> { return Set<Note>(activeNoteCodes.map { Note(fromNoteCode: $0) }) }
    
    
    var expectedNote: Note = Note.allCases.randomElement()!
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
        self.initStaticUI()
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initScene() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
    }
    
    
    func initStaticUI() {
    
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
    
        let noteSize: CGFloat = 50
        
        for note in Note.allCases {
        
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.fontColor = colorPalette.foregroundColor
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
        
            let circleNode = SKShapeNode(circleOfRadius: noteSize / 2.0)
            circleNode.strokeColor = colorPalette.foregroundColor
            circleNode.setScale(defaultScaleByNote[note]!)
            
            circleNode.addChild(labelNode)
            self.addChild(circleNode)
            
            self.noteDisplayNodeByNote[note] = circleNode
        }
        
        self.layoutNotes()
    }
    
    
    func layoutNotes() {
        
        let anchorPosition = CGPoint(x: -400, y: 0)
        
        var previousNoteNode: SKNode? = nil
        
        for note in Note.allCases {
        
            let noteNode = self.noteDisplayNodeByNote[note]!
            
            let refPosition = previousNoteNode?.position ?? anchorPosition
            
            let offset = (previousNoteNode?.frame.width ?? 0)/2.0
            
            noteNode.position = refPosition + CGPoint(x: offset  + noteNode.frame.width/2.0, y: 0)
             
            previousNoteNode = noteNode
        }
    }
    
    
    func computeNotesDisplayStateForActiveNotes(_ activeNotes: Set<Note>) -> [Note: (targetScaleValue: CGFloat, targetColor: NSColor, appearAnimationDuration: TimeInterval)] {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        var noteDisplayStateByNote: [Note: (targetScaleValue: CGFloat, targetColor: NSColor, appearAnimationDuration: TimeInterval)] = [:]
        
        // define base values
        
        for (affectedNote, defaultScale) in self.defaultScaleByNote {
            
            noteDisplayStateByNote[affectedNote] = (targetScaleValue: defaultScale, targetColor: .clear, appearAnimationDuration: 0)
        }
        
        // apply values for each active note
        
        for note in Note.allCases.reversed() {
            if activeNotes.contains(note) {
                
                for (affectedNote, state) in self.noteDisplayStateByNoteByPlayedNote[note]! {
                    noteDisplayStateByNote[affectedNote]!.targetScaleValue = state.targetScaleValue
                    noteDisplayStateByNote[affectedNote]!.appearAnimationDuration = state.appearAnimationDuration
                    noteDisplayStateByNote[affectedNote]!.targetColor = note == expectedNote ? colorPalette.correctColor : colorPalette.incorrectColor
                }
            }
        }
        
        return noteDisplayStateByNote
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        for note in Note.allCases {
            if self.activeAnimationsByNote[note] != nil, self.activeAnimationsByNote[note]!.animationStartTime == nil {
                self.activeAnimationsByNote[note]!.animationStartTime = currentTime
            }
        }
        
        for note in Note.allCases {
        
            if let animation = activeAnimationsByNote[note] {
            
                let circleNode = noteDisplayNodeByNote[note]!
                
                // when animation.animationDuration is short, currentTime can be later than (animation.animationStartTime + animation.animationDuration), hence the clamping
                
                let elapsedTimeSinceAnimationStart = currentTime - animation.animationStartTime
                let animationProgress = simd_clamp(elapsedTimeSinceAnimationStart / animation.animationDuration, 0.0, 1.0)
            
                let totalValueAmplitude = animation.targetScaleValue - animation.initialScaleValue
                let finalValue = animation.initialScaleValue + totalValueAmplitude * CGFloat(animationProgress)
                
                circleNode.setScale(finalValue)
                
//                self.layoutNotes()
                
                if animationProgress >= 1 {
                     self.activeAnimationsByNote[note] = nil
                 }
            }
        }
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
        
        self.activeNoteCodes.insert(noteCode)
        
        let playedNote = Note(fromNoteCode: noteCode)
        
        // animate scale progression for relevant notes
        
        let noteDisplayStateByNote = computeNotesDisplayStateForActiveNotes(self.activeNotes)
        
        for (note, state) in noteDisplayStateByNote {
            
            self.activeAnimationsByNote[note] = NoteAnimation(targetScaleValue: state.targetScaleValue,
                                                              animationDuration: state.appearAnimationDuration,
                                                              initialScaleValue: self.noteDisplayNodeByNote[note]!.xScale,
                                                              animationStartTime: nil)
            
            self.noteDisplayNodeByNote[note]!.fillColor = state.targetColor
            
            self.noteDisplayNodeByNote[note]!.zPosition = state.targetScaleValue
        }
        
        // animate jiggle for played note
        
        let nodeDisplayNode = self.noteDisplayNodeByNote[playedNote]!
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue

        let jiggleDuration: Double = 0.02 * 4
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor) * 0.5
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0 * jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        nodeDisplayNode.run(jiggleAction, withKey: "jiggle")
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        self.activeNoteCodes.remove(noteCode)
        
        // animate scale progression for relevant notes
        
        let disappearDuration: Double = 0.05
        
        let noteDisplayStateByNote = computeNotesDisplayStateForActiveNotes(self.activeNotes)
        
        for (note, state) in noteDisplayStateByNote {
            
            self.activeAnimationsByNote[note] = NoteAnimation(targetScaleValue: state.targetScaleValue,
                                                              animationDuration: disappearDuration,
                                                              initialScaleValue: self.noteDisplayNodeByNote[note]!.xScale,
                                                              animationStartTime: nil)
            
            self.noteDisplayNodeByNote[note]!.fillColor = state.targetColor
            
            self.noteDisplayNodeByNote[note]!.zPosition = state.targetScaleValue
        }
        
        // stop jiggle
        
        let playedNote = Note(fromNoteCode: noteCode)
        
        if !self.activeNotes.contains(playedNote) {
        
            let nodeDisplayNode = self.noteDisplayNodeByNote[playedNote]!
            
            nodeDisplayNode.removeAction(forKey: "jiggle")
            nodeDisplayNode.zRotation = 0
        }
    }
}
