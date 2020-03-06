
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
    
    
    let noteSize: CGFloat = 50
    
    var noteDisplayNodeByNote: [Note: SKShapeNode] = [:]
    
    
    struct Puzzle {
    
        let startingNote: Note
        
        let visibleNotes: Set<Note>
        let hiddenNoteNames: Set<Note>
        
        let expectedNote: Note
        let distanceToPreviousPuzzle: CGFloat
        
        init(startingNote: Note, visibleNotes: Set<Note> = Set<Note>(Note.allCases), hiddenNoteNames: Set<Note> = [], expectedNote: Note, distanceToPreviousPuzzle: CGFloat = 100) {
            
            self.startingNote = startingNote
            self.visibleNotes = visibleNotes
            self.hiddenNoteNames = hiddenNoteNames
            self.expectedNote = expectedNote
            self.distanceToPreviousPuzzle = distanceToPreviousPuzzle
        }
    }
    
    
    var puzzle = Puzzle(startingNote: .c,
                        visibleNotes: Set<Note>(Note.allCases.filter { !$0.isSharp }),
                        hiddenNoteNames: [.c, .d, .e],
                        expectedNote: .d)
    
    
    var simpleCountingDisplayNode: SimpleCountingDisplayNode!
    var simpleCountingDisplayNode2: SimpleCountingDisplayNode!
    
    var activeCountingDisplayNode: SimpleCountingDisplayNode?
        
    
    override func didMove(to view: SKView) {
        
        self.connectToMIDIDevice()
        
        self.configureColorPalette()
        self.initScene()
    }
    
    
    func configureColorPalette() {
        
        self.colorPalette = self.view?.effectiveAppearance.name == NSAppearance.Name.darkAqua ? self.colorPaletteDarkMode : self.colorPaletteDefault
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        guard let colorPalette = self.colorPalette else {
            fatalError("Color palette is not defined.")
        }
        
        self.backgroundColor = colorPalette.backgroundColor
        
        self.simpleCountingDisplayNode = SimpleCountingDisplayNode(colorPalette: colorPalette, puzzle: self.puzzle)
        self.simpleCountingDisplayNode.position = CGPoint(x: 0, y: 200)
        self.addChild(self.simpleCountingDisplayNode)
        
        self.simpleCountingDisplayNode2 = SimpleCountingDisplayNode(colorPalette: colorPalette, puzzle: self.puzzle)
        self.simpleCountingDisplayNode2.position = CGPoint(x: 0, y: -200)
        self.addChild(self.simpleCountingDisplayNode2)
        
        self.activeCountingDisplayNode = self.simpleCountingDisplayNode2
    }
    
    
    override func didFinishUpdate() {
        
        self.simpleCountingDisplayNode.layoutNotes()
        self.simpleCountingDisplayNode2.layoutNotes()
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
        
        self.activeCountingDisplayNode?.onNoteOn(noteCode: noteCode, velocity: velocity)
    }
    
    
    func onNoteOff(noteCode: NoteCode) {
    
        self.activeCountingDisplayNode?.onNoteOff(noteCode: noteCode)
    }
}
