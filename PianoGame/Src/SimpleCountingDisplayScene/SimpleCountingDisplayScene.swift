
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
    
    
    var configByNote: [(note: Note, visibleByDefault: Bool, labelVisibleByDefault: Bool)] = [
        
        (note: .a,          visibleByDefault: true,     labelVisibleByDefault: true),
        (note: .a_sharp,    visibleByDefault: false,    labelVisibleByDefault: true),
        (note: .b,          visibleByDefault: true,     labelVisibleByDefault: true),
        (note: .c,          visibleByDefault: false,    labelVisibleByDefault: false),
        (note: .c_sharp,    visibleByDefault: true,     labelVisibleByDefault: false),
        (note: .d,          visibleByDefault: true,     labelVisibleByDefault: false),
        (note: .d_sharp,    visibleByDefault: false,    labelVisibleByDefault: true),
        (note: .e,          visibleByDefault: true,     labelVisibleByDefault: true),
        (note: .f,          visibleByDefault: false,    labelVisibleByDefault: true),
        (note: .f_sharp,    visibleByDefault: true,     labelVisibleByDefault: true),
        (note: .g,          visibleByDefault: false,    labelVisibleByDefault: true),
        (note: .g_sharp,    visibleByDefault: true,     labelVisibleByDefault: true),
    ]
    
    
    var expectedNote: Note = .c_sharp
    
    
    struct NoteAnimation {
        
        var scaleTargetValue: CGFloat
        var scaleAnimationDuration: TimeInterval
        
        var scaleInitialValue: CGFloat! = nil
        var scaleAnimationStartTime: TimeInterval! = nil
    }
    
    
    var activeAnimationsByNote: [Note: NoteAnimation] = [:]
    
    
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
        
        for config in self.configByNote {
        
            let labelNode = SKLabelNode(text: config.note.description.uppercased())
            labelNode.fontColor = colorPalette.foregroundColor
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .center
            labelNode.alpha = config.labelVisibleByDefault ? 1 : 0
        
            let circleNode = SKShapeNode(circleOfRadius: noteSize / 2.0)
            circleNode.strokeColor = colorPalette.foregroundColor
            circleNode.lineWidth = config.note == self.expectedNote ? 4 : 1
            circleNode.setScale(config.visibleByDefault ? 1 : 0)
            
            circleNode.addChild(labelNode)
            self.addChild(circleNode)
            
            self.noteDisplayNodeByNote[config.note] = circleNode
        }
        
        self.layoutNotes()
    }
    
    
    func layoutNotes() {
        
        let totalNoteWidth = self.noteDisplayNodeByNote.reduce(0) { $0 + $1.value.frame.width }
        
        let anchorPosition = CGPoint(x: -totalNoteWidth/2.0, y: 0)
        
        var previousNoteNode: SKNode? = nil
        
        for note in self.configByNote.map({ $0.note }) {
        
            let noteNode = noteDisplayNodeByNote[note]!
            
            let refPosition = previousNoteNode?.position ?? anchorPosition
            
            let offset = (previousNoteNode?.frame.width ?? 0)/2.0

            noteNode.position = refPosition + CGPoint(x: offset  + noteNode.frame.width/2.0, y: 0)
            
            previousNoteNode = noteNode
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        for note in Note.allCases {
            if activeAnimationsByNote[note] != nil, activeAnimationsByNote[note]!.scaleAnimationStartTime == nil {
                activeAnimationsByNote[note]!.scaleAnimationStartTime = currentTime
            }
        }
        
        for note in Note.allCases {
        
            if let animation = activeAnimationsByNote[note] {
            
                let circleNode = noteDisplayNodeByNote[note]!
                
                let elapsedTimeSinceAnimationStart = currentTime - animation.scaleAnimationStartTime
                let animationProgress = simd_clamp(elapsedTimeSinceAnimationStart / animation.scaleAnimationDuration, 0.0, 1.0)
            
                let totalValueAmplitude = animation.scaleTargetValue - animation.scaleInitialValue
                let finalValue = animation.scaleInitialValue + totalValueAmplitude * CGFloat(animationProgress)
                
                circleNode.setScale(finalValue)
                
                layoutNotes()
                
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
        
        let scaleUpAmplitude: CGFloat = 1.1 + CGFloat(velocityFactor) * 2
        let appearDuration: Double = 0.1
        
        // animate scale
        
        activeAnimationsByNote[playedNote] = NoteAnimation(scaleTargetValue: scaleUpAmplitude,
                                                           scaleAnimationDuration: appearDuration,
                                                           scaleInitialValue: noteDisplayNode.xScale,
                                                           scaleAnimationStartTime: nil)
        
        for note in Note.allCases {
            self.noteDisplayNodeByNote[note]!.zPosition = note == playedNote ? 100 : 0
        }
        noteDisplayNode.fillColor = playedNote == self.expectedNote ? colorPalette.correctColor : colorPalette.incorrectColor
        
        noteDisplayNode.children.forEach { $0.alpha = 1 }
         
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
        
        activeAnimationsByNote[playedNote] = NoteAnimation(scaleTargetValue: configByNote.first { $0.note == playedNote }!.visibleByDefault ? 1 : 0,
                                                           scaleAnimationDuration: disappearDuration,
                                                           scaleInitialValue: noteDisplayNodeByNote[playedNote]!.xScale,
                                                           scaleAnimationStartTime: nil)
        
        noteDisplayNode.fillColor = .clear
        
        noteDisplayNode.children.forEach { $0.alpha = self.configByNote.first { $0.note == playedNote }!.labelVisibleByDefault ? 1 : 0 }
            
        // stop jiggle
        
        noteDisplayNode.removeAction(forKey: "jiggle")
        noteDisplayNode.zRotation = 0
    }
}
