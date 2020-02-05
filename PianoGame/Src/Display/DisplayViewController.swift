
import Cocoa
import SpriteKit
import MIKMIDI


class DisplayViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        let scene = DisplayGameScene()
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        
        let alesisDevice = MIKMIDIDeviceManager.shared.availableDevices.first(where: { $0.displayName == "Alesis Recital Pro " })!
        
        try! MIKMIDIDeviceManager.shared.connect(alesisDevice) { (_, commands) in
                
            commands.forEach { command in
                
                if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                    
                    if noteOnCommand.velocity > 0 {
                        
                        scene.noteOn(noteOnCommand.note)
                    }
                }
            }
        }
    }
}
