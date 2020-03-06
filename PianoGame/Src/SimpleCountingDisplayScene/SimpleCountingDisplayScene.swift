
import Foundation
import SpriteKit
import MIKMIDI



class SimpleCountingDisplayScene: SKScene {
    
    
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
        
        for note in self.configByNote.map({ $0.note }) {
        
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.fontColor = colorPalette.foregroundColor
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
        
            let circleNode = SKShapeNode(circleOfRadius: noteSize / 2.0)
            circleNode.strokeColor = colorPalette.foregroundColor
            circleNode.setScale(self.configByNote.first { $0.note == note }!.defaultScale)
            
            circleNode.addChild(labelNode)
            self.addChild(circleNode)
            
            self.noteDisplayNodeByNote[note] = circleNode
        }
        
        self.layoutNotes()
    }
    
    
    func layoutNotes() {
        
        let anchorPosition = CGPoint(x: -400, y: 0)
        
        var previousNoteNode: SKNode? = nil
        
        for note in self.configByNote.map({ $0.note }) {
        
            let noteNode = noteDisplayNodeByNote[note]!
            
            let refPosition = previousNoteNode?.position ?? anchorPosition
            
            let offset = (previousNoteNode?.frame.width ?? 0)/2.0

            noteNode.position = refPosition + CGPoint(x: offset  + noteNode.frame.width/2.0, y: 0)
            
            previousNoteNode = noteNode
        }
        
        for note in Note.allCases {
        
            if let noteNode = noteDisplayNodeByNote[note] {
        
                if note.isSharp {
                    
                    noteNode.position += CGPoint(x: 0, y: -40)
                }
            }
        }
    }
    
    
    struct Animation {
        
        var scaleTarget: CGFloat = 2
        var animationDuration: TimeInterval = 2
        
        var scaleInitialValue: CGFloat! = nil
        var timeAnimationStart: TimeInterval! = nil
    }
    
    
    var activeAnimationsByNote: [Note: Animation] = [:]
    
    
    var configByNote: [(note: Note, defaultScale: CGFloat)] = [
        
        (note: .a,          defaultScale: 1),
        (note: .a_sharp,    defaultScale: 0),
        (note: .b,          defaultScale: 1),
        (note: .c,          defaultScale: 1),
        (note: .c_sharp,    defaultScale: 0),
        (note: .d,          defaultScale: 1),
        (note: .d_sharp,    defaultScale: 0),
        (note: .e,          defaultScale: 1),
        (note: .f,          defaultScale: 1),
        (note: .f_sharp,    defaultScale: 0),
        (note: .g,          defaultScale: 1),
        (note: .g_sharp,    defaultScale: 0),
    ]
    
    
    override func update(_ currentTime: TimeInterval) {
        
        for note in Note.allCases {
            if activeAnimationsByNote[note] != nil, activeAnimationsByNote[note]!.timeAnimationStart == nil {
                activeAnimationsByNote[note]!.timeAnimationStart = currentTime
            }
        }
        
        for note in Note.allCases {
        
            if let animation = activeAnimationsByNote[note] {
            
                let circleNode = noteDisplayNodeByNote[note]!
                
                let elapsedTimeSinceAnimationStart = currentTime - animation.timeAnimationStart
                let animationProgress = simd_clamp(elapsedTimeSinceAnimationStart / animation.animationDuration, 0.0, 1.0)
            
                let totalValueAmplitude = animation.scaleTarget - animation.scaleInitialValue
                let finalValue = animation.scaleInitialValue + totalValueAmplitude * CGFloat(animationProgress)
                
                circleNode.setScale(finalValue)
                
//                layoutNotes()
                
                if animationProgress >= 1 {
                     activeAnimationsByNote[note] = nil
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
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        let playedNote = Note(fromNoteCode: noteCode)
        
        let noteDisplayNode = noteDisplayNodeByNote[playedNote]!
        
        // general animation settings
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let scaleUpAmplitude: CGFloat = 1.5
        let appearDuration: Double = 0.1
        
        // animate scale
        
        activeAnimationsByNote[playedNote] = Animation(scaleTarget: scaleUpAmplitude,
                                                       animationDuration: appearDuration,
                                                       scaleInitialValue: noteDisplayNode.xScale,
                                                       timeAnimationStart: nil)
        
        for note in Note.allCases {
            self.noteDisplayNodeByNote[note]!.zPosition = note == playedNote ? 100 : 0
        }
        noteDisplayNode.fillColor = playedNote == self.expectedNote ? colorPalette.correctColor : colorPalette.incorrectColor
         
        // animate jiggle
        
        let jiggleDuration: Double = 0.02 * 4
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor) * 0.5
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0 * jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        // setup an animate
        
        noteDisplayNode.run(jiggleAction, withKey: "jiggle")
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        let playedNote = Note(fromNoteCode: noteCode)
        
        let noteDisplayNode = noteDisplayNodeByNote[playedNote]!
        
        // general animation settings
        
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        activeAnimationsByNote[playedNote] = Animation(scaleTarget: configByNote.first { $0.note == playedNote }!.defaultScale,
                                                       animationDuration: disappearDuration,
                                                       scaleInitialValue: noteDisplayNodeByNote[playedNote]!.xScale,
                                                       timeAnimationStart: nil)
        
        noteDisplayNode.fillColor = .clear
            
        // stop jiggle
        
        noteDisplayNode.removeAction(forKey: "jiggle")
        noteDisplayNode.zRotation = 0
    }
}
