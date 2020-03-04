
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
    
    
    var noteDisplayNoteByNote: [Note: SKNode] = [:]
    
    
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
            
            noteDisplayNoteByNote[note] = circleNode
        }
        
        layoutNotes()
    }
    
    
    func layoutNotes() {
        
        let anchorPosition = CGPoint(x: -400, y: 0)
        
        var previousNoteNode: SKNode? = nil
        
        for note in Note.allCases {
        
            let noteNode = noteDisplayNoteByNote[note]!
            
            let refPosition = previousNoteNode?.position ?? anchorPosition
            
            let offset = (previousNoteNode?.frame.width ?? 0)/2.0
            
            noteNode.position = refPosition + CGPoint(x: offset  + noteNode.frame.width/2.0, y: 0)
             
            previousNoteNode = noteNode
        }
    }
    
    
    struct Animation {
        
        var scaleTarget: CGFloat = 2
        var animationDuration: TimeInterval = 2
        
        var scaleInitialValue: CGFloat! = nil
        var timeAnimationStart: TimeInterval! = nil
    }
    
    
    var activeAnimationsByNote: [Note: Animation] = [:]
    
    
    var defaultScaleByNote: [Note: CGFloat] = [
        .c: 1,
        .c_sharp: 0,
        .d: 1,
        .d_sharp: 0,
        .e: 1,
        .f: 1,
        .f_sharp: 0,
        .g: 1,
        .g_sharp: 0,
        .a: 1,
        .a_sharp: 0,
        .b: 1,
    ]
    
    
    override func update(_ currentTime: TimeInterval) {
        
        for note in Note.allCases {
            if activeAnimationsByNote[note] != nil, activeAnimationsByNote[note]!.timeAnimationStart == nil {
                activeAnimationsByNote[note]!.timeAnimationStart = currentTime
            }
        }
        
        for note in Note.allCases {
        
            if let animation = activeAnimationsByNote[note] {
            
                let circleNode = noteDisplayNoteByNote[note]!
                
                let elapsedTimeSinceAnimationStart = currentTime - animation.timeAnimationStart
                let animationProgress = simd_clamp(elapsedTimeSinceAnimationStart / animation.animationDuration, 0.0, 1.0)
            
                let totalValueAmplitude = animation.scaleTarget - animation.scaleInitialValue
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
        
        let playedNote = Note(fromNoteCode: noteCode)
        
        let nodeDisplayNode = noteDisplayNoteByNote[playedNote]!
        
        // general animation settings
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let baseScale: CGFloat = 1
        let scaleUpBaseAmplitude: CGFloat = 1.5
        let scaleUpAmplitudeForPlayedNote: CGFloat = 2
        
        let appearDurationForPlayedNote: Double = 0.1
        
        // animate scale
        
        var initialScaleValueByNote: [Note: CGFloat] = [:]
        var targetScaleValueByNote: [Note: CGFloat] = [:]
        var scaleAnimationDurationByNote: [Note: TimeInterval] = [:]
        
        var affectedNotes: [Note] = []
        
        for note in Note.allCases {
            
            if defaultScaleByNote[note]! != 0 || note == playedNote {
                affectedNotes.append(note)
            }
            
            if note == playedNote { break }
        }
        
        let playedNoteIndex = affectedNotes.firstIndex(of: playedNote)!
        
        for (index, note) in affectedNotes.enumerated() {
            
            initialScaleValueByNote[note] = noteDisplayNoteByNote[note]!.xScale
            targetScaleValueByNote[note] = baseScale + (scaleUpBaseAmplitude - baseScale) * CGFloat(index + 1) / CGFloat(playedNoteIndex + 1)
        }
        
        let speed = (targetScaleValueByNote[playedNote]! - baseScale) / CGFloat(appearDurationForPlayedNote)
        
        for note in affectedNotes {
            
            scaleAnimationDurationByNote[note] = Double(targetScaleValueByNote[note]! - baseScale) / Double(speed)
        }
        
        targetScaleValueByNote[playedNote] = scaleUpAmplitudeForPlayedNote
        
        for note in affectedNotes {
        
            activeAnimationsByNote[note] = Animation(scaleTarget: targetScaleValueByNote[note]!,
                                                     animationDuration: scaleAnimationDurationByNote[note]!,
                                                     scaleInitialValue: initialScaleValueByNote[note]!,
                                                     timeAnimationStart: nil)
        }

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
        
        nodeDisplayNode.run(jiggleAction, withKey: "jiggle")
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        let playedNote = Note(fromNoteCode: noteCode)
        
        let nodeDisplayNode = noteDisplayNoteByNote[playedNote]!
        
        // general animation settings
        
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        for note in Note.allCases {
        
            activeAnimationsByNote[note] = Animation(scaleTarget: defaultScaleByNote[note]!,
                                                     animationDuration: disappearDuration,
                                                     scaleInitialValue: noteDisplayNoteByNote[note]!.xScale,
                                                     timeAnimationStart: nil)
        }
            
        // stop jiggle
        
        nodeDisplayNode.removeAction(forKey: "jiggle")
        nodeDisplayNode.zRotation = 0
    }
}
