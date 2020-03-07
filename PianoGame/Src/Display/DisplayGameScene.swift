
import Foundation
import SpriteKit


class DisplayGameScene: SKScene {
    
    
    var defaultCamera: SKCameraNode!
    
    var referencePosition: CGFloat = 0.0
    var dateStart: Date!
    
    let displaySpeed: CGFloat = 100    // points per second
    
    var previousNote: UInt!
    var previousNoteDate: Date!
    var allNoteIntervalsPlayed: [(dateStart: Date, interval: Int, duration: TimeInterval)] = []
    let patternAnalysisTimeWindow = TimeInterval(5)
    
    
    override func didMove(to view: SKView) {
        
        defaultCamera = SKCameraNode()
        self.addChild(defaultCamera)
        self.camera = defaultCamera
        
        dateStart = Date()
    }
    
    
    override func didFinishUpdate() {
        
        let timeIntervalSinceStart = DateInterval(start: dateStart, end: Date()).duration
        let distanceToReferencePoint = CGFloat(timeIntervalSinceStart) * displaySpeed
        let position = referencePosition + distanceToReferencePoint
        
        defaultCamera.position = CGPoint(x: position, y: 0)
    }
    
    
    func onNotesChanged(notesGoingOn: Set<UInt>, notesGoingOff: Set<UInt>) {
        
        if !notesGoingOn.isEmpty {
            onNotesGoingOn(notesGoingOn)
        }
    }
    
    
    func createNoteLabel(note: UInt, date: Date) {
        
        let timeIntervalSinceStart = DateInterval(start: dateStart, end: date).duration
        let distanceToReferencePoint = CGFloat(timeIntervalSinceStart) * displaySpeed
        let position = referencePosition + distanceToReferencePoint
        
        let minimumNoteCode: UInt = 21
        let maximumNoteCode: UInt = 107
        
        let noteCodeStartingAtZero = note - minimumNoteCode // [0; max]
        let noteCodeFractionnal = Double(noteCodeStartingAtZero) / Double(maximumNoteCode - minimumNoteCode + 2) // [0; 1]
        let noteCodeFractionnalCentered = (noteCodeFractionnal - 0.5) * 2   // [-1; 1]
        let scaleFactor: Double = Double(self.size.height) / 2.0 * 0.9
        let noteCodeFractionnalCenteredScaled = noteCodeFractionnalCentered * scaleFactor    // [-h/2; +h/2]
        
        let labelNode = SKLabelNode()
        labelNode.text =  String(describing: Note(fromNoteCode: note)).uppercased()
        labelNode.position = CGPoint(x: position, y: CGFloat(noteCodeFractionnalCenteredScaled))
        
        addChild(labelNode)
    }
    
    
    func onNotesGoingOn(_ notes: Set<UInt>) {
        
        notes.forEach { note in
        
            createNoteLabel(note: note, date: Date())
            
            //
            
            if previousNote != nil {
            
                let interval: Int = Int(note) - Int(previousNote)
                let duration = DateInterval(start: previousNoteDate, end: Date()).duration
                
                allNoteIntervalsPlayed.append((dateStart: Date(), interval: interval, duration: duration))
                print("allNoteIntervalsPlayed: \(allNoteIntervalsPlayed)")
                
                let intervalsForPatternAnalysis = allNoteIntervalsPlayed.filter { return DateInterval(start: $0.dateStart, end: Date()).duration < patternAnalysisTimeWindow }
                print("intervalsForPatternAnalysis: \(intervalsForPatternAnalysis)")
                
                let allNoteIntervalsPlayedWithoutPattern = allNoteIntervalsPlayed.filter { return DateInterval(start: $0.dateStart, end: Date()).duration >= patternAnalysisTimeWindow }
                
                let firstPatternElement = intervalsForPatternAnalysis.first!
                let offsets = allNoteIntervalsPlayedWithoutPattern.enumerated().filter { $0.element.interval == firstPatternElement.interval } .map { $0.offset }
                
                var keptOffsets: [Int] = []
                for offset in offsets {
                    var i = 0
                    var mismatch = false
                    while offset + i < allNoteIntervalsPlayedWithoutPattern.count && i < intervalsForPatternAnalysis.count {
                        if intervalsForPatternAnalysis[i].interval != allNoteIntervalsPlayedWithoutPattern[offset + i].interval {
                            mismatch = true
                            break
                        }
                        i += 1
                    }
                    if !mismatch {
                        keptOffsets.append(offset)
                    }
                }
                
                if !keptOffsets.isEmpty {
                
                    var i = 0
                    while keptOffsets.max()! + i < allNoteIntervalsPlayedWithoutPattern.count {
                        
                        var counters: [Int: Int] = [:]  // key = interval, value = count
                        
                        for offset in keptOffsets {
                            let interval = allNoteIntervalsPlayedWithoutPattern[offset + i].interval
                            counters[interval] = (counters[interval] ?? 0) + 1
                        }
                        
                        let max = counters.map { $0.value } .max()!
                        let selectedInterval = counters.keys.filter { counters[$0] == max } .first!
                        
                        keptOffsets = keptOffsets.filter { allNoteIntervalsPlayedWithoutPattern[$0 + i].interval == selectedInterval }
                        
                        i += 1
                    }
                    
                    let predictedPattern = allNoteIntervalsPlayedWithoutPattern[keptOffsets.first!..<(keptOffsets.first! + i)]

                    if intervalsForPatternAnalysis.count < predictedPattern.count {
                    
                        let predictedPatternWithoutPlayedIntervals = predictedPattern[intervalsForPatternAnalysis.count..<predictedPattern.count]
                        
                        let referenceNote = note
                        
                        let mappedNotes = predictedPatternWithoutPlayedIntervals.map { (note: UInt(Int(referenceNote) + $0.interval), date: $0.dateStart) }
                        
                        mappedNotes.forEach {
                            
                            createNoteLabel(note: $0.note, date: $0.date)
                        }
                    }
                }
            }
            
            previousNote = note
            previousNoteDate = Date()
        }
    }
}
