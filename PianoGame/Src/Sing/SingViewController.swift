
import UIKit
import AudioKit
import AudioKitUI



class SingViewController: UIViewController {
    
    
    class AverageFilter: Filter {
        
        var bufferSize: Int = 1
        var accumulator: [Double] = []
        
        init(bufferSize: Int) {
            self.bufferSize = bufferSize
        }
        
        func inject(sample: Double) -> Double {
            
            self.accumulator.insert(sample, at: 0)
            while self.accumulator.count > self.bufferSize { _ = self.accumulator.popLast() }
            
            let sum = self.accumulator.reduce(0, +)
            let average = sum / self.accumulator.count
            
            return average
        }
    }
    
    
    class StabilizerFilter: Filter {
        
        var threshold: Double
        var previousSample: Double! = nil
        
        init(threshold: Double) {
            self.threshold = threshold
        }
        
        func inject(sample: Double) -> Double {
            
            if self.previousSample == nil || abs(sample - self.previousSample!) > self.threshold {
                self.previousSample = sample
                return sample
            } else {
                return self.previousSample
            }
        }
    }
    
    
    var tracker: AKMicrophoneTracker!
    let trackingPeriod: TimeInterval = 0.01
    var smoothingPeriod: TimeInterval = 0.1
    
    var cursorView1: UIView!
    let cursorView1Height: CGFloat = 1
    let cursorView1Color: UIColor = .red
    
    var cursorView2: UIView!
    let cursorView2Height: CGFloat = 1
    let cursorView2Color: UIColor = .green
    
    let transformRawSampleToActualFrequencyInHz: (Double) -> Double = { $0 * 440.0 / 262.0 }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        fatalError("macOS not supported, please run on an iOS device")
        #endif
        
        self.cursorView1 = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/2, height: self.cursorView1Height))
        self.cursorView1.backgroundColor = self.cursorView1Color
        self.view.addSubview(cursorView1)
        
        self.cursorView2 = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/2, height: self.cursorView2Height))
        self.cursorView2.backgroundColor = self.cursorView2Color
        self.view.addSubview(cursorView2)
        
        self.tracker = AKMicrophoneTracker()
        self.tracker.start()
        
        let filters: [Filter] = [
            AverageFilter(bufferSize: Int(self.smoothingPeriod / self.trackingPeriod)),
            StabilizerFilter(threshold: 1),
        ]
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            let rawSample: Double = self.tracker.frequency
            
            let y1 = self.view.bounds.height - CGFloat(rawSample)
            self.cursorView1.center = CGPoint(x: self.view.bounds.width/4, y: y1)
            
            let filteredSample = filters.reduce(rawSample, { $1.inject(sample: $0) })
            
            let y2 = self.view.bounds.height - CGFloat(filteredSample)
            self.cursorView2.center = CGPoint(x: self.view.bounds.width*3/4, y: y2)
            
            print(filteredSample)
            
            let actualFrequencyInHz = self.transformRawSampleToActualFrequencyInHz(filteredSample)
            print("\(round(actualFrequencyInHz)) Hz")
        }
    }
}


protocol Filter {
    
    func inject(sample: Double) -> Double
}
