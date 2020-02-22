
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
    
    let sideColumnRelativeWidth: Percent = 30%
    let topAreaRelativeHeight: Percent = 30%
    
    let sessionProgressBarRelativeWidth: Percent = 90%
    let sessionProgressBarHeight: CGFloat = 10
    
    
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
            
                guard let currentSessionIndex = self.currentSessionIndex else { fatalError("A session was expected to be active but was not.") }
                
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
                
                guard let currentSessionIndex = self.currentSessionIndex else { fatalError("A session was expected to be active but was not.") }
                
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
        
        guard let currentSessionIndex = self.currentSessionIndex else { fatalError("Trying to load question while no session is active.") }
        
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
        
        guard let currentSessionIndex = self.currentSessionIndex else { fatalError("Trying to compute next session progress while no session is active.") }
        
        self.nextSessionProgress = min(100%, self.currentSessionProgress + sessions[currentSessionIndex].nominalProgress * Double(self.currentActualMultiplier))
    }
    
    
    func redraw() {
        
        self.removeAllChildren()
        
        if self.gameCompleted {
            
            let label = SKLabelNode(text: "You have completed the training!")
            self.addChild(label)
            
            return
        }
        
        guard
             let currentQuestionNote = self.currentQuestionNote
            ,let currentQuestionSolutionNote = self.currentQuestionSolutionNote
            ,let currentQuestionInterval = self.currentQuestionInterval
        else { return }
        
        // define UI main areas
        
        let sideColumnRootNode = ContainerNode(withSize: CGSize(width: self.frame.width * CGFloat(self.sideColumnRelativeWidth.fraction), height: self.frame.height))
        sideColumnRootNode.position = CGPoint(x: self.frame.width/2.0 - sideColumnRootNode.size.width/2.0, y: 0)
        self.addChild(sideColumnRootNode)
        
        let mainAreaRootNode = ContainerNode(withSize: CGSize(width: self.frame.width - sideColumnRootNode.size.width, height: self.frame.height))
        mainAreaRootNode.position = CGPoint(x: -self.frame.width/2.0 + mainAreaRootNode.size.width/2.0, y: 0)
        self.addChild(mainAreaRootNode)
        
        let topMainAreaRootNode = ContainerNode(withSize: CGSize(width: mainAreaRootNode.size.width, height: mainAreaRootNode.size.height * CGFloat(self.topAreaRelativeHeight.fraction)))
        topMainAreaRootNode.position = CGPoint(x: 0, y: mainAreaRootNode.size.height/2.0 - topMainAreaRootNode.size.height/2.0)
        mainAreaRootNode.addChild(topMainAreaRootNode)
        
        let bottomMainAreaRootNode = ContainerNode(withSize: CGSize(width: mainAreaRootNode.size.width, height: mainAreaRootNode.size.height - topMainAreaRootNode.size.height))
        bottomMainAreaRootNode.position = CGPoint(x: 0, y: -mainAreaRootNode.size.height/2.0 + bottomMainAreaRootNode.size.height/2.0)
        mainAreaRootNode.addChild(bottomMainAreaRootNode)
        
        // draw question
        
        let questionNoteLabel = SKLabelNode(text: currentQuestionNote.description.uppercased())
        questionNoteLabel.position = CGPoint(x: -(bottomMainAreaRootNode.size.width/2.0)*2.0/3.0, y: 0)
        bottomMainAreaRootNode.addChild(questionNoteLabel)
        
        let solutionNoteLabel = SKLabelNode(text: self.currentQuestionSolutionNoteGiven ? currentQuestionSolutionNote.description.uppercased() : "?")
        solutionNoteLabel.position = CGPoint(x: (bottomMainAreaRootNode.size.width/2.0)*2.0/3.0, y: 0)
        bottomMainAreaRootNode.addChild(solutionNoteLabel)
        
        let questionIntervalNameLabel = SKLabelNode(text: String(describing: currentQuestionInterval))
        questionIntervalNameLabel.position = CGPoint(x: 0, y: questionIntervalNameLabel.calculateAccumulatedFrame().height/2.0 + 10)
        bottomMainAreaRootNode.addChild(questionIntervalNameLabel)
        
        let questionIntervalLengthLabel = SKLabelNode(text: "\(Double(currentQuestionInterval.lengthInSemitones)/2.0)T")
        questionIntervalLengthLabel.fontSize *= 0.8
        questionIntervalLengthLabel.position = CGPoint(x: 0, y: -questionIntervalLengthLabel.calculateAccumulatedFrame().height/2.0 - 10)
        bottomMainAreaRootNode.addChild(questionIntervalLengthLabel)
        
        // draw session progress
        
        let sessionProgressBarWidth = topMainAreaRootNode.size.width * CGFloat(sessionProgressBarRelativeWidth.fraction)
        self.drawProgressBar(parent: topMainAreaRootNode, position: CGPoint(x: 0, y: 0), width: sessionProgressBarWidth, height: self.sessionProgressBarHeight, value: self.currentSessionProgress, markerValue: self.nextSessionProgress)
        
        // draw multiplier
        
        if let currentDisplayedMultiplier = self.currentDisplayedMultiplier {
        
            let multiplierLabel = SKLabelNode(text: "x\(currentDisplayedMultiplier)")
            multiplierLabel.position = CGPoint(x: -sessionProgressBarWidth/2.0 + sessionProgressBarWidth * CGFloat(currentSessionProgress.fraction) , y: sessionProgressBarHeight/2.0 + multiplierLabel.calculateAccumulatedFrame().height/2.0 + 10)
            topMainAreaRootNode.addChild(multiplierLabel)
        }
    }
    
    
    func drawProgressBar(parent: ContainerNode, position: CGPoint, width: CGFloat, height: CGFloat, value: Percent, markerValue: Percent) {
        
        let mainRectNode = SKShapeNode(rectOf: CGSize(width: width, height: height))
        mainRectNode.position = position
        parent.addChild(mainRectNode)
        
        let fillRectNode = SKShapeNode(rectOf: CGSize(width: width * CGFloat(value.fraction), height: height))
        fillRectNode.position = CGPoint(x: -width/2.0 + fillRectNode.frame.width/2.0, y: 0)
        parent.addChild(fillRectNode)
        
        let markerNode = SKShapeNode(rectOf: CGSize(width: 1, height: height))
        markerNode.position = CGPoint(x: -width/2.0 + width * CGFloat(markerValue.fraction), y: 0)
        parent.addChild(markerNode)
    }
}


class ContainerNode: SKNode {
    
    let size: CGSize
    
    required init?(coder aDecoder: NSCoder) {
        
        self.size = CGSize.zero
        super.init(coder: aDecoder)
    }
    
    init(withSize size: CGSize) {
        
        self.size = size
        super.init()
    }
}
