
import Foundation
import SpriteKit
import MIKMIDI
import Percent


struct Session {
    
    let notesAndIntervalsSubjects: [Note: [Interval]]
    let grantedMasteryPointsByNoteAndInterval: [Note: [Interval: UInt]]
    let nominalProgress: Percent
}


class IntervalGameScene: SKScene {
    
    
    let MIDIDeviceName = "Alesis Recital Pro "  // trailing space intentional
    
    let requiredMasterPointsByNoteAndInterval: [Note: [Interval: UInt]] = [
        .c: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .c_sharp: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .d: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .d_sharp: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .e: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .f: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .f_sharp: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .g: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .g_sharp: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .a: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .a_sharp: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ],
        .b: [
            .P1: 1,
            .m2: 1,
            .M2: 1,
            .m3: 1,
            .M3: 1,
            .P4: 1,
            .A4: 1,
            .P5: 1,
            .m6: 1,
            .M6: 1,
            .m7: 1,
            .M7: 1,
        ]
    ]
    var obtainedMasteryPointsByNoteAndInterval: [Note: [Interval: UInt]] = [:]   // non existent key means 0 points
    
    let sessions: [Session] = [
        Session(
            notesAndIntervalsSubjects: [
                .c: [ .P1 ],
                .c_sharp: [ .P1 ]
            ],
            grantedMasteryPointsByNoteAndInterval: [
                .c: [
                    .P1: 1
                ],
                .c_sharp: [
                    .P1: 1
                ]
            ],
            nominalProgress: 10%
        ),
        Session(
            notesAndIntervalsSubjects: [
                .c: [ .m2 ],
                .c_sharp: [ .m2 ]
            ],
            grantedMasteryPointsByNoteAndInterval: [
                .c: [
                    .m2: 1
                ],
                .c_sharp: [
                    .m2: 1
                ]
            ],
            nominalProgress: 10%
        )
    ]
    var currentSessionIndex: Int? = nil
    
    var currentSessionProgress: Percent = 0%
    var nextSessionProgress: Percent = 0%
    
    var currentActualMultiplier: UInt = 1
    var currentDisplayedMultiplier: UInt? = nil
    
    var currentQuestionNote: Note? = nil
    var currentQuestionInterval: Interval? = nil
    
    var currentQuestionSolutionNote: Note? = nil
    var currentQuestionSolutionNoteGiven = false
    
    var numberOfCorrectAnswersSinceLastWrongAnswer: UInt = 0
    var gameCompleted = false
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.connectToMIDIDevice()
        self.loadNextSession()
        self.loadNextQuestion()
        self.redraw()
    }
    
    
    override func didChangeSize(_ oldSize: CGSize) {
        
        self.redraw()
    }
    
    
    func connectToMIDIDevice() {
        
        let device = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == self.MIDIDeviceName })!
        
        try! MIKMIDIDeviceManager.shared.connect(device) { (_, commands) in
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    if noteOnCommand.velocity > 0 {
                        self.onNoteOn(noteOnCommand.note)
                    } else {
                        self.onNoteOff(noteOnCommand.note)
                    }
                } else if let noteOffCommand = command as? MIKMIDINoteOffCommand {
                    self.onNoteOff(noteOffCommand.note)
                }
            }
        }
    }
    
    
    func onNoteOn(_ code: UInt) {
        
        guard let currentQuestionSolutionNote = currentQuestionSolutionNote else { return }
        
        if Note(fromNoteCode: code) != currentQuestionSolutionNote {
            
            self.numberOfCorrectAnswersSinceLastWrongAnswer = 0
            
        } else {
            
            self.numberOfCorrectAnswersSinceLastWrongAnswer += 1
            self.currentQuestionSolutionNoteGiven = true
            self.currentSessionProgress = self.nextSessionProgress
            
            if self.currentSessionProgress >= 100% {
            
                guard let currentSessionIndex = currentSessionIndex else { fatalError("A session was expected to be active but was not.") }
                
                for (note, pointsByInterval) in sessions[currentSessionIndex].grantedMasteryPointsByNoteAndInterval {
                    for (interval, points) in pointsByInterval {

                        self.obtainedMasteryPointsByNoteAndInterval[note] = self.obtainedMasteryPointsByNoteAndInterval[note] ?? [Interval: UInt]()
                        self.obtainedMasteryPointsByNoteAndInterval[note]![interval] = (self.obtainedMasteryPointsByNoteAndInterval[note]![interval] ?? 0) + points
                    }
                }
            }
        }
        
        self.computeMultiplier()
        self.computeNextSessionProgress()
        self.redraw()
    }
    
    
    func onNoteOff(_ code: UInt) {
        
        guard let currentQuestionSolutionNote = currentQuestionSolutionNote else { return }
        
        if Note(fromNoteCode: code) == currentQuestionSolutionNote, self.currentQuestionSolutionNoteGiven {
            
            if self.currentSessionProgress >= 100% {
                
                guard let currentSessionIndex = currentSessionIndex else { fatalError("A session was expected to be active but was not.") }
                
                if currentSessionIndex == sessions.count - 1 {

                    self.gameCompleted = true
                    
                } else {

                    self.loadNextSession()
                    self.loadNextQuestion()
                }
                
            } else {
                
                self.loadNextQuestion()
            }
            
            self.redraw()
        }
    }
    
    
    func loadNextSession() {
        
        if self.currentSessionIndex == nil {
            self.currentSessionIndex = 0
        } else {
            self.currentSessionIndex! += 1
        }
        
        self.currentSessionProgress = 0%
        self.numberOfCorrectAnswersSinceLastWrongAnswer = 0
        
        self.computeMultiplier()
        self.computeNextSessionProgress()
    }
    
    
    func loadNextQuestion() {
        
        guard let currentSessionIndex = currentSessionIndex else { fatalError("Tying to load question while no session is active.") }
        
        self.currentQuestionNote = sessions[currentSessionIndex].notesAndIntervalsSubjects.keys.randomElement()
        self.currentQuestionInterval = sessions[currentSessionIndex].notesAndIntervalsSubjects[currentQuestionNote!]!.randomElement()
        
        self.currentQuestionSolutionNote = self.currentQuestionNote!.adding(self.currentQuestionInterval!)
        self.currentQuestionSolutionNoteGiven = false
    }
    
    
    func computeMultiplier() {
        
        self.currentActualMultiplier = max(1, numberOfCorrectAnswersSinceLastWrongAnswer)
        self.currentDisplayedMultiplier = self.currentActualMultiplier > 1 ? self.currentActualMultiplier : nil
    }
    
    
    func computeNextSessionProgress() {
        
        guard let currentSessionIndex = currentSessionIndex else { fatalError("Tying to compute next session progress while no session is active.") }
        
        self.nextSessionProgress = min(100%, self.currentSessionProgress + sessions[currentSessionIndex].nominalProgress * Double(self.currentActualMultiplier))
    }
    
    
    func redraw() {
        
        print("===== Redraw")
        
        print("gameCompleted: \(self.gameCompleted)")
        
        print("currentQuestionNote: \(self.currentQuestionNote)")
        print("currentQuestionInterval: \(self.currentQuestionInterval)")
        print("currentQuestionSolutionNote: \(self.currentQuestionSolutionNote)")
        print("currentQuestionSolutionNoteGiven: \(self.currentQuestionSolutionNoteGiven)")
        
        print("currentSessionProgress: \(self.currentSessionProgress)")
        print("nextSessionProgress: \(self.nextSessionProgress)")
        
        print("currentActualMultiplier: \(self.currentActualMultiplier)")
        print("currentDisplayedMultiplier: \(self.currentDisplayedMultiplier)")
        
        print("obtainedMasteryPointsByNoteAndInterval: \(self.obtainedMasteryPointsByNoteAndInterval)")
    }
}
