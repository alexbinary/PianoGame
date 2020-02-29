
import Foundation
import SpriteKit
import MIKMIDI



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
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.connectToMIDIDevice()
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
        
        if Note(fromNoteCode: code) == self.currentQuestionSolutionNote {
            
            self.currentQuestionSolutionNoteGiven = true
            self.updateQuestionUI()
        }
    }
    
    
    func onNoteOff(_ code: UInt) {
        
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
    
    
    func updateQuestionUI() {
        
        guard
             let currentQuestionNote = self.currentQuestionNote
            ,let currentQuestionInterval = self.currentQuestionInterval
            ,let currentQuestionSolutionNote = self.currentQuestionSolutionNote
        else { fatalError("Attempting to update question UI while some data have no value.") }
        
        let questionRootPosition = CGPoint(x: 0, y: -self.size.height + self.size.height/3.0)
        let sceneHalfWidth = self.size.width/2.0
        let horizontalSpread = sceneHalfWidth*2.0/3.0
        
        if self.questionNoteLabel == nil {
            
            self.questionNoteLabel = SKLabelNode()
            self.questionNoteLabel!.verticalAlignmentMode = .center
            self.questionNoteLabel!.horizontalAlignmentMode = .center
            self.questionNoteLabel!.position = questionRootPosition + CGPoint(x: -horizontalSpread, y: 0)
            self.addChild(self.questionNoteLabel!)
        }
        
        self.questionNoteLabel!.text = currentQuestionNote.description.uppercased()
        
        if self.solutionNoteLabel == nil {
            
            self.solutionNoteLabel = SKLabelNode()
            self.solutionNoteLabel!.verticalAlignmentMode = .center
            self.solutionNoteLabel!.horizontalAlignmentMode = .center
            self.solutionNoteLabel!.position = questionRootPosition + CGPoint(x: +horizontalSpread, y: 0)
            self.addChild(self.solutionNoteLabel!)
        }
        
        self.solutionNoteLabel!.text = self.currentQuestionSolutionNoteGiven ? currentQuestionSolutionNote.description.uppercased() : "?"

        if self.questionIntervalNameLabel == nil {
            
            self.questionIntervalNameLabel = SKLabelNode()
            self.questionIntervalNameLabel!.verticalAlignmentMode = .center
            self.questionIntervalNameLabel!.horizontalAlignmentMode = .center
            self.addChild(self.questionIntervalNameLabel!)
        }
        
        self.questionIntervalNameLabel!.text = String(describing: currentQuestionInterval)
        self.questionIntervalNameLabel!.position = questionRootPosition + CGPoint(x: 0, y: self.questionIntervalNameLabel!.calculateAccumulatedFrame().height/2.0 + 10)

        if self.questionIntervalLengthLabel == nil {
            
            self.questionIntervalLengthLabel = SKLabelNode()
            self.questionIntervalLengthLabel!.fontSize *= 0.8
            self.questionIntervalLengthLabel!.verticalAlignmentMode = .center
            self.questionIntervalLengthLabel!.horizontalAlignmentMode = .center
            self.addChild(self.questionIntervalLengthLabel!)
        }
        
        self.questionIntervalLengthLabel!.text = "\(Double(currentQuestionInterval.lengthInSemitones)/2.0)T"
        self.questionIntervalLengthLabel!.position = questionRootPosition + CGPoint(x: 0, y: -self.questionIntervalLengthLabel!.calculateAccumulatedFrame().height/2.0 - 10)
    }
}
