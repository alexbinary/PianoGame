
import Foundation
import SpriteKit
import MIKMIDI



class CountingDisplayScene: SKScene {
    
    
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
            
            if let previousNoteNode = previousNoteNode {
                
                noteNode.position = previousNoteNode.position + CGPoint(x: previousNoteNode.frame.width/2.0 + noteNode.frame.width/2.0, y: 0)
                
            } else {
            
                noteNode.position = anchorPosition
            }
            
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
                
                print("target value: \(animation.scaleTarget)")
                print("setting final value: \(finalValue)")
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
        
        let note = Note(fromNoteCode: noteCode)
        
        let nodeDisplayNode = noteDisplayNoteByNote[note]!
        
        // general animation settings
        
        let velocityMaxValue: Double = 128.0
        let velocityFactor: Double = Double(velocity)/velocityMaxValue
        
        let scaleUpAmplitude: CGFloat = 2
        let appearDuration: Double = 0.1
        
        // animate scale
        
        activeAnimationsByNote[note] = Animation(scaleTarget: scaleUpAmplitude,
                                                 animationDuration: appearDuration,
                                                 scaleInitialValue: nodeDisplayNode.xScale,
                                                 timeAnimationStart: nil)
        
        return
        
        let appearScaleAction = SKAction.scale(to: scaleUpAmplitude, duration: appearDuration)
        
        // animate jiggle
        
        let jiggleDuration: Double = 0.02 * 4
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor) * 0.5
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0 * jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        // compose final animation
        
        let appearAction = SKAction.group([
            appearScaleAction,
            jiggleAction
        ])
        
        // setup an animate
        
        nodeDisplayNode.run(appearAction)
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        let note = Note(fromNoteCode: noteCode)
        
        let nodeDisplayNode = noteDisplayNoteByNote[note]!
        
        // general animation settings
        
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        activeAnimationsByNote[note] = Animation(scaleTarget: 1,
                                                 animationDuration: disappearDuration,
                                                 scaleInitialValue: nodeDisplayNode.xScale,
                                                 timeAnimationStart: nil)

        return
        
        let disappearScaleAction = SKAction.scale(to: 1, duration: disappearDuration)

        // compose final animation

        let disappearAction = disappearScaleAction

        // setup an animate

        nodeDisplayNode.run(disappearAction)
    }
}
