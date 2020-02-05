
import Cocoa
import SpriteKit
import MIKMIDI


class QuizViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = QuizGameScene()
        scene.scaleMode = .resizeFill
        
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
