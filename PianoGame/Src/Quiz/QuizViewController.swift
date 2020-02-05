
import Cocoa
import SpriteKit
import MIKMIDI


class QuizViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = QuizGameScene()
        scene.scaleMode = .resizeFill
        
        scene.playerDelegate = self
        
        skView.presentScene(scene)
        
        
        let alesisDevice = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!
        
        try! MIKMIDIDeviceManager.shared.connect(alesisDevice) { (_, commands) in
                
            commands.forEach { command in
                
                print(command)
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    
                    scene.noteOn(noteOnCommand.note)
                }
            }
        }
        
        
        
        
               
              
    }
}


extension QuizViewController : PlayerDelegate {
    
    
    func playNote(_ note: UInt) {
        
        let alesisDevice = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!

        let alesisEntity = alesisDevice.entities.first!

        let alesisDestination = alesisEntity.destinations.first!

        try! MIKMIDIDeviceManager.shared.send([
            MIKMIDINoteOnCommand(note: note, velocity: 64, channel: 0, timestamp: Date().advanced(by: 2)),
            MIKMIDINoteOffCommand(note: note, velocity: 0, channel: 0, timestamp: Date().advanced(by: 4))
        ], to: alesisDestination)
    }
}
