
import UIKit
import MIKMIDI


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(MIKMIDIDeviceManager.shared.availableDevices)
    }
}

