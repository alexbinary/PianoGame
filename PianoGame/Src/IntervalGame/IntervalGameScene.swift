
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
    
    let requiredMasteryPointsByNoteAndInterval: [Note: [Interval: UInt]] = [
        .c: [
            .P1: 1,
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
            .m2: 2,
            .M2: 2,
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
    var nextObtainedMasteryPointsByNoteAndInterval: [Note: [Interval: UInt]] = [:]   // non existent key means no next value
    
    let sessions: [Session] = [
        Session(
            notesAndIntervalsSubjects: [
                .c:       [ .P1 ],
                .c_sharp: [ .P1 ],
                .d:       [ .P1 ],
                .d_sharp: [ .P1 ],
                .e:       [ .P1 ],
                .f:       [ .P1 ],
                .f_sharp: [ .P1 ],
                .g:       [ .P1 ],
                .g_sharp: [ .P1 ],
                .a:       [ .P1 ],
                .a_sharp: [ .P1 ],
                .b:       [ .P1 ],
            ],
            grantedMasteryPointsByNoteAndInterval: [
                .c:       [ .P1: 1 ],
                .c_sharp: [ .P1: 1 ],
                .d:       [ .P1: 1 ],
                .d_sharp: [ .P1: 1 ],
                .e:       [ .P1: 1 ],
                .f:       [ .P1: 1 ],
                .f_sharp: [ .P1: 1 ],
                .g:       [ .P1: 1 ],
                .g_sharp: [ .P1: 1 ],
                .a:       [ .P1: 1 ],
                .a_sharp: [ .P1: 1 ],
                .b:       [ .P1: 1 ],
            ],
            nominalProgress: Percent(fraction: 1.0/(12.0*2.0))
        ),
        Session(
            notesAndIntervalsSubjects: [
                .c:       [ .m2 ],
                .c_sharp: [ .m2 ],
                .d:       [ .m2 ],
                .d_sharp: [ .m2 ],
                .e:       [ .m2 ],
                .f:       [ .m2 ],
                .f_sharp: [ .m2 ],
                .g:       [ .m2 ],
                .g_sharp: [ .m2 ],
                .a:       [ .m2 ],
                .a_sharp: [ .m2 ],
                .b:       [ .m2 ],
            ],
            grantedMasteryPointsByNoteAndInterval: [
                .c:       [ .m2: 1 ],
                .c_sharp: [ .m2: 1 ],
                .d:       [ .m2: 1 ],
                .d_sharp: [ .m2: 1 ],
                .e:       [ .m2: 1 ],
                .f:       [ .m2: 1 ],
                .f_sharp: [ .m2: 1 ],
                .g:       [ .m2: 1 ],
                .g_sharp: [ .m2: 1 ],
                .a:       [ .m2: 1 ],
                .a_sharp: [ .m2: 1 ],
                .b:       [ .m2: 1 ],
            ],
            nominalProgress: Percent(fraction: 1.0/(12.0*3.0))
        ),
        Session(
            notesAndIntervalsSubjects: [
                .c:       [ .M2 ],
                .c_sharp: [ .M2 ],
                .d:       [ .M2 ],
                .d_sharp: [ .M2 ],
                .e:       [ .M2 ],
                .f:       [ .M2 ],
                .f_sharp: [ .M2 ],
                .g:       [ .M2 ],
                .g_sharp: [ .M2 ],
                .a:       [ .M2 ],
                .a_sharp: [ .M2 ],
                .b:       [ .M2 ],
            ],
            grantedMasteryPointsByNoteAndInterval: [
                .c:       [ .M2: 1 ],
                .c_sharp: [ .M2: 1 ],
                .d:       [ .M2: 1 ],
                .d_sharp: [ .M2: 1 ],
                .e:       [ .M2: 1 ],
                .f:       [ .M2: 1 ],
                .f_sharp: [ .M2: 1 ],
                .g:       [ .M2: 1 ],
                .g_sharp: [ .M2: 1 ],
                .a:       [ .M2: 1 ],
                .a_sharp: [ .M2: 1 ],
                .b:       [ .M2: 1 ],
            ],
            nominalProgress: Percent(fraction: 1.0/(12.0*3.0))
        ),
        Session(
            notesAndIntervalsSubjects: [
                .c:       [ .m2, .M2 ],
                .c_sharp: [ .m2, .M2 ],
                .d:       [ .m2, .M2 ],
                .d_sharp: [ .m2, .M2 ],
                .e:       [ .m2, .M2 ],
                .f:       [ .m2, .M2 ],
                .f_sharp: [ .m2, .M2 ],
                .g:       [ .m2, .M2 ],
                .g_sharp: [ .m2, .M2 ],
                .a:       [ .m2, .M2 ],
                .a_sharp: [ .m2, .M2 ],
                .b:       [ .m2, .M2 ],
            ],
            grantedMasteryPointsByNoteAndInterval: [
                .c:       [ .m2: 1, .M2: 1 ],
                .c_sharp: [ .m2: 1, .M2: 1 ],
                .d:       [ .m2: 1, .M2: 1 ],
                .d_sharp: [ .m2: 1, .M2: 1 ],
                .e:       [ .m2: 1, .M2: 1 ],
                .f:       [ .m2: 1, .M2: 1 ],
                .f_sharp: [ .m2: 1, .M2: 1 ],
                .g:       [ .m2: 1, .M2: 1 ],
                .g_sharp: [ .m2: 1, .M2: 1 ],
                .a:       [ .m2: 1, .M2: 1 ],
                .a_sharp: [ .m2: 1, .M2: 1 ],
                .b:       [ .m2: 1, .M2: 1 ],
            ],
            nominalProgress: Percent(fraction: 1.0/(24.0*4.0))
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
    
    let backgroundColorLight = NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
    let backgroundColorDark = NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1)
    var dynamicBackgroundColor: NSColor!
    
    let foregroundColorLight = NSColor(red: 44.0/255.0, green: 44.0/255.0, blue: 44.0/255.0, alpha: 1)
    let foregroundColorDark = NSColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
    var dynamicForegroundColor: NSColor!
    
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.connectToMIDIDevice()
        self.loadNextSession()
        self.loadNextQuestion()
        
        self.updateColorScheme(darkModeEnabled: false)
        self.redraw()
    }
    
    
    override func didChangeSize(_ oldSize: CGSize) {
        
        self.redraw()
    }
    
    
    func updateColorScheme(darkModeEnabled: Bool) {
        
        self.dynamicBackgroundColor = darkModeEnabled ? self.backgroundColorDark : self.backgroundColorLight
        self.dynamicForegroundColor = darkModeEnabled ? self.foregroundColorDark : self.foregroundColorLight
        
        self.backgroundColor = self.dynamicBackgroundColor
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
            
            self.computeMultiplier()
            self.computeNextSessionProgress()
            
        } else {
            
            self.numberOfCorrectAnswersSinceLastWrongAnswer += 1
            self.currentQuestionSolutionNoteGiven = true
            self.currentSessionProgress = self.nextSessionProgress
            
            if self.currentSessionProgress >= 100% {
            
                self.obtainedMasteryPointsByNoteAndInterval = self.nextObtainedMasteryPointsByNoteAndInterval
                self.currentDisplayedMultiplier = nil
                
                guard let currentSessionIndex = self.currentSessionIndex else { fatalError("A session was expected to be active but was not.") }
                
                if currentSessionIndex == sessions.count - 1 {

                    self.gameCompleted = true
                }
                
            } else {
        
                self.computeMultiplier()
                self.computeNextSessionProgress()
            }
        }
        
        self.redraw()
    }
    
    
    func onNoteOff(_ code: UInt) {
        
        guard let currentQuestionSolutionNote = currentQuestionSolutionNote else { return }
        
        if Note(fromNoteCode: code) == currentQuestionSolutionNote, self.currentQuestionSolutionNoteGiven {
            
            if self.currentSessionProgress >= 100% {
                
                if !self.gameCompleted {

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
        
        self.computeNextObtainedMasteryPoints()
        
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
    
    
    func computeNextObtainedMasteryPoints() {
        
        self.nextObtainedMasteryPointsByNoteAndInterval = self.addMasteryPoints(self.obtainedMasteryPointsByNoteAndInterval, sessions[self.currentSessionIndex!].grantedMasteryPointsByNoteAndInterval)
    }
    
    
    func computeMultiplier() {
        
        self.currentActualMultiplier = max(1, numberOfCorrectAnswersSinceLastWrongAnswer)
        self.currentDisplayedMultiplier = self.currentActualMultiplier > 1 ? self.currentActualMultiplier : nil
    }
    
    
    func computeNextSessionProgress() {
        
        guard let currentSessionIndex = self.currentSessionIndex else { fatalError("Trying to compute next session progress while no session is active.") }
        
        self.nextSessionProgress = min(100%, self.currentSessionProgress + sessions[currentSessionIndex].nominalProgress * Double(self.currentActualMultiplier))
    }
    
    
    func addMasteryPoints(_ lhs: [Note: [Interval: UInt]], _ rhs: [Note: [Interval: UInt]]) -> [Note: [Interval: UInt]] {
        
        var result = lhs
        
        for (note, pointsByInterval) in rhs {
            for (interval, points) in pointsByInterval {

                result[note] = result[note] ?? [Interval: UInt]()
                result[note]![interval] = (result[note]![interval] ?? 0) + points
            }
        }
        
        return result
    }
    
    
    func redraw() {
        
        self.removeAllChildren()
        
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
        let x = -self.frame.width/2.0 + mainAreaRootNode.size.width/2.0
        mainAreaRootNode.position = CGPoint(x: x, y: 0)
        self.addChild(mainAreaRootNode)
        
        let topMainAreaRootNode = ContainerNode(withSize: CGSize(width: mainAreaRootNode.size.width, height: mainAreaRootNode.size.height * CGFloat(self.topAreaRelativeHeight.fraction)))
        topMainAreaRootNode.position = CGPoint(x: 0, y: mainAreaRootNode.size.height/2.0 - topMainAreaRootNode.size.height/2.0)
        mainAreaRootNode.addChild(topMainAreaRootNode)

        let bottomMainAreaRootNode = ContainerNode(withSize: CGSize(width: mainAreaRootNode.size.width, height: mainAreaRootNode.size.height - topMainAreaRootNode.size.height))
        let y = -mainAreaRootNode.size.height/2.0 + bottomMainAreaRootNode.size.height/2.0
        bottomMainAreaRootNode.position = CGPoint(x: 0, y: y)
        mainAreaRootNode.addChild(bottomMainAreaRootNode)

        // draw question

        let questionNoteLabel = SKLabelNode(text: currentQuestionNote.description.uppercased())
        questionNoteLabel.fontColor = self.dynamicForegroundColor
        let referenceWidth = bottomMainAreaRootNode.size.width/2.0
        let x2 = -referenceWidth*2.0/3.0
        questionNoteLabel.position = CGPoint(x: x2, y: 0)
        questionNoteLabel.verticalAlignmentMode = .center
        questionNoteLabel.horizontalAlignmentMode = .center
        bottomMainAreaRootNode.addChild(questionNoteLabel)

        let solutionNoteLabel = SKLabelNode(text: self.currentQuestionSolutionNoteGiven ? currentQuestionSolutionNote.description.uppercased() : "?")
        solutionNoteLabel.fontColor = self.dynamicForegroundColor
        let x3 = referenceWidth*2.0/3.0
        solutionNoteLabel.position = CGPoint(x: x3, y: 0)
        solutionNoteLabel.verticalAlignmentMode = .center
        solutionNoteLabel.horizontalAlignmentMode = .center
        bottomMainAreaRootNode.addChild(solutionNoteLabel)

        let questionIntervalNameLabel = SKLabelNode(text: String(describing: currentQuestionInterval))
        questionIntervalNameLabel.fontColor = self.dynamicForegroundColor
        questionIntervalNameLabel.position = CGPoint(x: 0, y: questionIntervalNameLabel.calculateAccumulatedFrame().height/2.0 + 10)
        questionIntervalNameLabel.verticalAlignmentMode = .center
        questionIntervalNameLabel.horizontalAlignmentMode = .center
        bottomMainAreaRootNode.addChild(questionIntervalNameLabel)

        let questionIntervalLengthLabel = SKLabelNode(text: "\(Double(currentQuestionInterval.lengthInSemitones)/2.0)T")
        questionIntervalLengthLabel.fontColor = self.dynamicForegroundColor
        questionIntervalLengthLabel.fontSize *= 0.8
        let y2 = -questionIntervalLengthLabel.calculateAccumulatedFrame().height/2.0 - 10
        questionIntervalLengthLabel.position = CGPoint(x: 0, y: y2)
        questionIntervalLengthLabel.verticalAlignmentMode = .center
        questionIntervalLengthLabel.horizontalAlignmentMode = .center
        bottomMainAreaRootNode.addChild(questionIntervalLengthLabel)

        // draw session progress

        let sessionProgressBarWidth = topMainAreaRootNode.size.width * CGFloat(sessionProgressBarRelativeWidth.fraction)
        self.drawProgressBar(parent: topMainAreaRootNode, position: CGPoint(x: 0, y: 0), width: sessionProgressBarWidth, height: self.sessionProgressBarHeight, value: self.currentSessionProgress, markerValue: self.nextSessionProgress)

        // draw multiplier

        if let currentDisplayedMultiplier = self.currentDisplayedMultiplier {

            let multiplierLabel = SKLabelNode(text: "x\(currentDisplayedMultiplier)")
            multiplierLabel.fontColor = self.dynamicForegroundColor
            multiplierLabel.position = CGPoint(x: -sessionProgressBarWidth/2.0 + sessionProgressBarWidth * CGFloat(currentSessionProgress.fraction) , y: sessionProgressBarHeight/2.0 + 10)
            multiplierLabel.verticalAlignmentMode = .bottom
            multiplierLabel.horizontalAlignmentMode = .center
            topMainAreaRootNode.addChild(multiplierLabel)
        }
        
        // compute global progress
        
        var totalRequiredMasteryPointsForEveryNoteAndInterval: UInt = 0
        
        for (_/*note*/, pointsByInterval) in self.requiredMasteryPointsByNoteAndInterval {
            for (_/*interval*/, points) in pointsByInterval {
                
                totalRequiredMasteryPointsForEveryNoteAndInterval += points
            }
        }
        
        var totalObtainedMasteryPointsForEveryNoteAndInterval: UInt = 0
        
        for (_/*note*/, pointsByInterval) in self.obtainedMasteryPointsByNoteAndInterval {
            for (_/*interval*/, points) in pointsByInterval {
                
                totalObtainedMasteryPointsForEveryNoteAndInterval += points
            }
        }
        
        var nextTotalObtainedMasteryPointsForEveryNoteAndInterval: UInt = 0
        
        for (_/*note*/, pointsByInterval) in self.nextObtainedMasteryPointsByNoteAndInterval {
            for (_/*interval*/, points) in pointsByInterval {
                
                nextTotalObtainedMasteryPointsForEveryNoteAndInterval += points
            }
        }
        
        let globalProgress = Percent(fraction: Double(totalObtainedMasteryPointsForEveryNoteAndInterval) / Double(totalRequiredMasteryPointsForEveryNoteAndInterval))
        let nextGlobalProgress = Percent(fraction: Double(nextTotalObtainedMasteryPointsForEveryNoteAndInterval) / Double(totalRequiredMasteryPointsForEveryNoteAndInterval))
        
        // compute progress by note
        
        var totalRequiredMasteryPointsByNote: [Note: UInt] = [:]
        
        for (note, pointsByInterval) in self.requiredMasteryPointsByNoteAndInterval {
            totalRequiredMasteryPointsByNote[note] = pointsByInterval.values.reduce(0, +)
        }
        
        var totalObtainedMasteryPointsByNote: [Note: UInt] = [:]
        
        for (note, pointsByInterval) in self.obtainedMasteryPointsByNoteAndInterval {
            totalObtainedMasteryPointsByNote[note] = pointsByInterval.values.reduce(0, +)
        }
        
        var nextTotalObtainedMasteryPointsByNote: [Note: UInt] = [:]
        
        for (note, pointsByInterval) in self.nextObtainedMasteryPointsByNoteAndInterval {
            nextTotalObtainedMasteryPointsByNote[note] = pointsByInterval.values.reduce(0, +)
        }
        
        var overallProgressByNote: [Note: Percent] = [:]
        
        for (note, totalRequiredMasteryPoints) in totalRequiredMasteryPointsByNote {
            overallProgressByNote[note] = Percent(fraction: Double(totalObtainedMasteryPointsByNote[note] ?? 0) / Double(totalRequiredMasteryPoints))
        }
        
        var nextOverallProgressByNote: [Note: Percent] = [:]
        
        for (note, totalRequiredMasteryPoints) in totalRequiredMasteryPointsByNote {
            nextOverallProgressByNote[note] = Percent(fraction: Double(nextTotalObtainedMasteryPointsByNote[note] ?? 0) / Double(totalRequiredMasteryPoints))
        }
        
        // compute progress by interval
        
        var totalRequiredMasteryPointsByInterval: [Interval: UInt] = [:]
        
        for (_/*note*/, pointsByInterval) in self.requiredMasteryPointsByNoteAndInterval {
            for (interval, points) in pointsByInterval {
                
                totalRequiredMasteryPointsByInterval[interval] = (totalRequiredMasteryPointsByInterval[interval] ?? 0) + points
            }
        }
        
        var totalObtainedMasteryPointsByInterval: [Interval: UInt] = [:]
        
        for (_/*note*/, pointsByInterval) in self.obtainedMasteryPointsByNoteAndInterval {
            for (interval, points) in pointsByInterval {
                
                totalObtainedMasteryPointsByInterval[interval] = (totalObtainedMasteryPointsByInterval[interval] ?? 0) + points
            }
        }
        
        var nextTotalObtainedMasteryPointsByInterval: [Interval: UInt] = [:]
        
        for (_/*note*/, pointsByInterval) in self.nextObtainedMasteryPointsByNoteAndInterval {
            for (interval, points) in pointsByInterval {
                
                nextTotalObtainedMasteryPointsByInterval[interval] = (nextTotalObtainedMasteryPointsByInterval[interval] ?? 0) + points
            }
        }
        
        var overallProgressByInterval: [Interval: Percent] = [:]
        
        for (interval, totalRequiredMasteryPoints) in totalRequiredMasteryPointsByInterval {
            overallProgressByInterval[interval] = Percent(fraction: Double(totalObtainedMasteryPointsByInterval[interval] ?? 0) / Double(totalRequiredMasteryPoints))
        }
        
        var nextOverallProgressByInterval: [Interval: Percent] = [:]
        
        for (interval, totalRequiredMasteryPoints) in totalRequiredMasteryPointsByInterval {
            nextOverallProgressByInterval[interval] = Percent(fraction: Double(nextTotalObtainedMasteryPointsByInterval[interval] ?? 0) / Double(totalRequiredMasteryPoints))
        }
        
        // build progress bars list
        
        var progressBarsList: [(label: String, value: Percent, nextValue: Percent?)] = []
        
        progressBarsList.append((label: "All", value: globalProgress, nextValue: nextGlobalProgress))
        
        for note in Note.allCases {
            if let progress = overallProgressByNote[note] {
                progressBarsList.append((label: note.description.uppercased(), value: progress, nextValue: nextOverallProgressByNote[note]))
            }
        }
        
        for interval in Interval.allCases {
            if let progress = overallProgressByInterval[interval] {
                progressBarsList.append((label: String(describing: interval), value: progress, nextValue: nextOverallProgressByInterval[interval]))
            }
        }
        
        // draw progress bars
        
        for k in 1...progressBarsList.count {
            
            let yk = sideColumnRootNode.size.height/2.0 - CGFloat(k)*sideColumnRootNode.size.height/CGFloat(progressBarsList.count+1)
            let w = sideColumnRootNode.size.width/2.0*0.9
            
            let labelNode = SKLabelNode(text: progressBarsList[k-1].label)
            labelNode.fontColor = self.dynamicForegroundColor
            labelNode.position = CGPoint(x: -60, y: yk)
            labelNode.verticalAlignmentMode = .center
            labelNode.horizontalAlignmentMode = .left
            sideColumnRootNode.addChild(labelNode)
            
            self.drawProgressBar(parent: sideColumnRootNode, position: CGPoint(x: w/2.0 + 10, y: yk), width: w, height: 5, value: progressBarsList[k-1].value, markerValue: progressBarsList[k-1].nextValue)
        }
        
        // end screen
        
        if self.gameCompleted {
            
            let label = SKLabelNode(text: "You have completed the training!")
            label.fontColor = self.dynamicForegroundColor
            label.fontSize *= 2
            self.addChild(label)
        }
    }
    
    func drawProgressBar(parent: ContainerNode, position: CGPoint, width: CGFloat, height: CGFloat, value: Percent, markerValue: Percent?) {
        
        let mainRectNode = SKShapeNode(rectOf: CGSize(width: width, height: height))
        mainRectNode.strokeColor = self.dynamicForegroundColor
        mainRectNode.position = position
        parent.addChild(mainRectNode)
        
        let fillRectNode = SKShapeNode(rectOf: CGSize(width: width * CGFloat(value.fraction), height: height))
        fillRectNode.lineWidth = 0
        fillRectNode.fillColor = NSColor.systemGreen
        let x = position.x - width/2.0 + fillRectNode.frame.width/2.0
        fillRectNode.position = CGPoint(x: x, y: position.y)
        fillRectNode.zPosition = -1
        parent.addChild(fillRectNode)
        
        if let markerValue = markerValue {

            let markerNode = SKShapeNode(rectOf: CGSize(width: 1, height: height))
            markerNode.fillColor = NSColor.systemRed
            markerNode.lineWidth = 0
            markerNode.position = CGPoint(x: position.x - width/2.0 + width * CGFloat(markerValue.fraction), y: position.y)
            markerNode.zPosition = -1
            parent.addChild(markerNode)
        }
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
