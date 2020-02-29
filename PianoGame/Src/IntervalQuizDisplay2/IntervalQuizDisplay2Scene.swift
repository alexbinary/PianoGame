
import Foundation
import SpriteKit
import MIKMIDI



struct NoteDisplayData {
    
    let node: SKNode
    let disappearAction: SKAction
}


class IntervalQuizDisplay2Scene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    
    var currentQuestionNote: Note? = nil
    var currentQuestionInterval: Interval? = nil
    
    var currentQuestionSolutionNote: Note? = nil
    var currentQuestionSolutionNoteGiven = false
    
    
    var questionNoteLabel: SKLabelNode? = nil
    var solutionNoteLabel: SKLabelNode? = nil
    var questionIntervalNameLabel: SKLabelNode? = nil
    var questionIntervalLengthLabel: SKLabelNode? = nil
    
    
    var noteDisplayDataByNote: [NoteCode: NoteDisplayData] = [:]
    
    
    struct ColorPalette {
        
        let backgroundColor: NSColor
        let foregroundColor: NSColor
    }
    
    let colorPaletteDefault = ColorPalette(
        
        backgroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1)
    )
    
    let colorPaletteDarkMode = ColorPalette(
        
        backgroundColor: NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1),
        foregroundColor: NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
    )
    
    var colorPalette: ColorPalette?
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initStaticUI()
        
        self.loadNextQuestion()
        self.updateQuestionUI()
    }
    
    
    func connectToMIDIDevice() {
        
        guard let device = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == self.MIDIDeviceName }) else {
            fatalError("MIDI device \"\(self.MIDIDeviceName)\" not found. Is it turned on?")
        }
        
        try! MIKMIDIDeviceManager.shared.connect(device) { (_, commands) in
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    if noteOnCommand.velocity > 0 {
                        self.onNoteOn(note: noteOnCommand.note, velocity: noteOnCommand.velocity)
                    } else {
                        self.onNoteOff(noteOnCommand.note)
                    }
                } else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    self.onNoteOff(noteOffCommand.note)
                }
            }
        }
    }
    
    
    func onNoteOn(note code: NoteCode, velocity: Velocity) {
        
        // --- display
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Attempted to use color palette but it was not defined.")
        }
        
        let displayRootPosition = CGPoint(x: 0, y: -self.size.height/2.0 + self.size.height*2.0/3.0)
        
        let minimumNoteCode: UInt = 21
        let maximumNoteCode: UInt = 107
        let noteCodeSpan: UInt = maximumNoteCode - minimumNoteCode
        let noteCodeFromZero: UInt = code - minimumNoteCode
        
        let velocityFactor: Double = Double(velocity)/128.0
        
        let note = Note(fromNoteCode: code)
        let labelNode = SKLabelNode(text: note.description.uppercased())
        labelNode.fontColor = colorPalette.foregroundColor
        
        let horizontalStep: CGFloat = self.size.width / CGFloat(noteCodeSpan + 2)
        let verticalDispatch: CGFloat = 0
        
        labelNode.position = displayRootPosition + CGPoint(
            x: -self.size.width/2.0 + CGFloat(noteCodeFromZero + 1) * horizontalStep,
            y: verticalDispatch * CGFloat(note.isSharp ? 1 : -1))
        
        // general animation settings
        
        let appearDuration: Double = 0.1
        let fadeOutDuration: Double = 10 * velocityFactor
        let disappearDuration: Double = 0.05
        
        // animate scale
        
        let scaleUpAmplitude: CGFloat = 10 * CGFloat(velocityFactor)
        
        let appearScaleAction = SKAction.scale(to: scaleUpAmplitude, duration: appearDuration)
        let fadeOutScaleAction = SKAction.scale(to: 0, duration: fadeOutDuration)
        let disappearScaleAction = SKAction.scale(to: 0, duration: disappearDuration)
        
        // animate fadeout
        
        let fadeOutFadeAction = SKAction.fadeOut(withDuration: fadeOutDuration)
        
        // animate jiggle
        
        let jiggleDuration: Double = 0.02
        let jiggleAmplitude: CGFloat = .pi/12.0 * CGFloat(velocityFactor * velocityFactor)
        let jiggleCount = 5
        
        let jiggleAction = SKAction.repeat(SKAction.sequence([
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
            SKAction.rotate(byAngle: -2.0 * jiggleAmplitude, duration: 2 * jiggleDuration),
            SKAction.rotate(byAngle: jiggleAmplitude, duration: jiggleDuration),
        ]), count: jiggleCount)
        
        // compose final animation
        
        let appearAndFadeOutAction = SKAction.group([
            SKAction.sequence([
                appearScaleAction,
                SKAction.group([fadeOutScaleAction, fadeOutFadeAction])
            ]),
            jiggleAction
        ])
        let disappearAction = disappearScaleAction
        
        // setup an animate
        
        labelNode.setScale(0)
        
        addChild(labelNode)
        labelNode.run(appearAndFadeOutAction)
        
        // register data for teardown
        
        self.noteDisplayDataByNote[code] = NoteDisplayData(node: labelNode, disappearAction: disappearAction)
        
        // --- game logic
        
        if Note(fromNoteCode: code) == self.currentQuestionSolutionNote {
            
            self.currentQuestionSolutionNoteGiven = true
            self.updateQuestionUI()
        }
    }
    
    
    func onNoteOff(_ code: UInt) {
        
        // --- display
        
        if let data = self.noteDisplayDataByNote[code] {
            data.node.run(data.disappearAction, completion: {
                self.removeChildren(in: [data.node])
                self.noteDisplayDataByNote[code] = nil
            })
        }
        
        // --- game logic
        
        if Note(fromNoteCode: code) == currentQuestionSolutionNote, self.currentQuestionSolutionNoteGiven {
            
            self.loadNextQuestion()
            self.updateQuestionUI()
        }
    }
    
    
    func loadNextQuestion() {
        
        self.currentQuestionNote = Note.allCases.randomElement()
        self.currentQuestionInterval = Interval.allCases.randomElement()
        
        self.currentQuestionSolutionNote = self.currentQuestionNote!.adding(self.currentQuestionInterval!)
        self.currentQuestionSolutionNoteGiven = false
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initStaticUI() {
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Attempted to use color palette but it was not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
        
        let questionRootPosition = CGPoint(x: 0, y: -self.size.height/2.0 + self.size.height/3.0)
        let sceneHalfWidth = self.size.width/2.0
        let horizontalSpread = sceneHalfWidth*2.0/3.0
            
        self.questionNoteLabel = SKLabelNode()
        self.questionNoteLabel?.fontColor = colorPalette.foregroundColor
        self.questionNoteLabel!.verticalAlignmentMode = .center
        self.questionNoteLabel!.horizontalAlignmentMode = .center
        self.questionNoteLabel!.position = questionRootPosition + CGPoint(x: -horizontalSpread, y: 0)
        self.addChild(self.questionNoteLabel!)
        
        self.solutionNoteLabel = SKLabelNode()
        self.solutionNoteLabel?.fontColor = colorPalette.foregroundColor
        self.solutionNoteLabel!.verticalAlignmentMode = .center
        self.solutionNoteLabel!.horizontalAlignmentMode = .center
        self.solutionNoteLabel!.position = questionRootPosition + CGPoint(x: +horizontalSpread, y: 0)
        self.addChild(self.solutionNoteLabel!)
        
        self.questionIntervalNameLabel = SKLabelNode()
        self.questionIntervalNameLabel?.fontColor = colorPalette.foregroundColor
        self.questionIntervalNameLabel!.verticalAlignmentMode = .center
        self.questionIntervalNameLabel!.horizontalAlignmentMode = .center
        self.questionIntervalNameLabel!.position = questionRootPosition + CGPoint(x: 0, y: +20)
        self.addChild(self.questionIntervalNameLabel!)
        
        self.questionIntervalLengthLabel = SKLabelNode()
        self.questionIntervalLengthLabel?.fontColor = colorPalette.foregroundColor
        self.questionIntervalLengthLabel!.fontSize *= 0.8
        self.questionIntervalLengthLabel!.verticalAlignmentMode = .center
        self.questionIntervalLengthLabel!.horizontalAlignmentMode = .center
        self.questionIntervalLengthLabel!.position = questionRootPosition + CGPoint(x: 0, y: -20)
        self.addChild(self.questionIntervalLengthLabel!)
    }
    
    
    func updateQuestionUI() {
        
        guard
             let currentQuestionNote = self.currentQuestionNote
            ,let currentQuestionInterval = self.currentQuestionInterval
            ,let currentQuestionSolutionNote = self.currentQuestionSolutionNote
        else { fatalError("Attempting to update question UI while some data have no value.") }
        
        self.questionNoteLabel!.text = currentQuestionNote.description.uppercased()
        
        self.questionIntervalNameLabel!.text = String(describing: currentQuestionInterval)
        self.questionIntervalLengthLabel!.text = "\(Double(currentQuestionInterval.lengthInSemitones)/2.0)T"
        
        self.solutionNoteLabel!.text = self.currentQuestionSolutionNoteGiven ? currentQuestionSolutionNote.description.uppercased() : "?"
    }
}
