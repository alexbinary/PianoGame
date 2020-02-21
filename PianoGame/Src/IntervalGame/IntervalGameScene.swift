
import Foundation
import SpriteKit
import MIKMIDI
import Percent


struct Session {
    
    let notesAndIntervalsSubjects: [Note: [Interval]]
    let grantedMasterPointsByNoteAndInterval: [Note: [Interval: UInt]]
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
    let obtainedMasterPointsByNoteAndInterval: [Note: [Interval: UInt]] = [:]   // non existent key means 0 points
    
    
    
    
    
}
