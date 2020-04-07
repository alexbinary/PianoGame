
import UIKit
import AudioKit
import AudioKitUI



class SingViewController: UIViewController {
    
    
    class AverageSignalProcessor: SignalProcessor {
        
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
    
    
    class StabilizerSignalProcessor: SignalProcessor {
        
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
    
    
    var mic: AKMicrophone!
    var tracker1: AKFrequencyTracker!
    var tracker2: AKFrequencyTracker!
    
    let trackingPeriod: TimeInterval = 0.01
    var smoothingPeriod: TimeInterval = 0.1
    
    var micLowPassFilter: AKLowPassFilter!
    let micHightCutoffFrequency: Double = 1600 // Hz
    
    var micBandPassFilter: AKBandPassButterworthFilter!
    let micBandPassCenterFrequency: Double = 440 // Hz
    let micBandPassBandwidth: Double = 100 // cents
    
    let amplitudeThreshold: Double = 0.01
    
    var cursorView1: UIView!
    let cursorView1Height: CGFloat = 1
    let cursorView1Color: UIColor = .purple
    
    var cursorView2: UIView!
    let cursorView2Height: CGFloat = 1
    let cursorView2Color: UIColor = .blue
    
    let trackerValueToActualFrequencyRatio: Double = 1 // result in Hz
    
    let plotMinFrequency: Double = 20 // Hz
    let plotMaxFrequency: Double = 2000 // Hz
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        fatalError("macOS not supported, please run on an iOS device")
        #endif
        
        // UI setup
        
        self.cursorView1 = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/2, height: self.cursorView1Height))
        self.cursorView1.backgroundColor = self.cursorView1Color
        self.view.addSubview(cursorView1)
        
        self.cursorView2 = UIView(frame: CGRect(x: self.view.bounds.width/2, y: 0, width: self.view.bounds.width/2, height: self.cursorView2Height))
        self.cursorView2.backgroundColor = self.cursorView2Color
        self.view.addSubview(cursorView2)
        
        // Audio pipeline setup
        
        self.mic = AKMicrophone()
        self.micLowPassFilter = AKLowPassFilter(AKBooster(self.mic, gain: 10), cutoffFrequency: self.micHightCutoffFrequency, resonance: 0)
        self.micBandPassFilter = AKBandPassButterworthFilter(AKBooster(self.mic, gain: 10), centerFrequency: self.micBandPassCenterFrequency, bandwidth: self.micBandPassBandwidth)
        self.tracker1 = AKFrequencyTracker(self.micLowPassFilter)
        self.tracker2 = AKFrequencyTracker(self.micBandPassFilter)
        
        AudioKit.output = AKBooster(AKMixer(self.tracker1, self.tracker2), gain: 0)
        try! AudioKit.start()
        
        // Signal processing setup
        
        let signalProcessors1: [SignalProcessor] = [
            AverageSignalProcessor(bufferSize: Int(self.smoothingPeriod / self.trackingPeriod)),
            StabilizerSignalProcessor(threshold: 1),
        ]
        
        let signalProcessors2: [SignalProcessor] = [
            AverageSignalProcessor(bufferSize: Int(self.smoothingPeriod / self.trackingPeriod)),
            StabilizerSignalProcessor(threshold: 1),
        ]
        
        // Sample processing setup
        
        let convertTrackerValueToActualFrequency: SampleProcessor = { $0 * self.trackerValueToActualFrequencyRatio }
        
        let sampleProcessors: [SampleProcessor] = [ convertTrackerValueToActualFrequency ]
        
        let samplePlotter: SamplePlotter = { sample in
        
            let logValue = log2(sample)
            let minLogValue = log2(self.plotMinFrequency)
            let maxLogValue = log2(self.plotMaxFrequency)
            let normalized = (logValue - minLogValue) / (maxLogValue - minLogValue)
            return CGFloat(normalized)
        }
        
        let plotRawSample = { (rawSample: Double, cursorView: UIView) in
            
            let processedSample = sampleProcessors.reduce(rawSample, { $1($0) })
            let plotValue = samplePlotter(processedSample)
            
            cursorView.center = CGPoint(x: cursorView.center.x, y: self.view.bounds.height * (1 - plotValue))
        }
        
        //
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            guard self.tracker1.amplitude > self.amplitudeThreshold else { return }
            
            let rawSignalSample: Double = self.tracker1.frequency
            let processedSignalSample = signalProcessors1.reduce(rawSignalSample, { $1.inject(sample: $0) })
            plotRawSample(processedSignalSample, self.cursorView1)
        }
        
        Timer.scheduledTimer(withTimeInterval: self.trackingPeriod, repeats: true) { _ in
            
            guard self.tracker2.amplitude > self.amplitudeThreshold else { return }
            
            let rawSignalSample: Double = self.tracker2.frequency
            let processedSignalSample = signalProcessors2.reduce(rawSignalSample, { $1.inject(sample: $0) })
            plotRawSample(processedSignalSample, self.cursorView2)
        }
    }
}


protocol SignalProcessor {
    
    func inject(sample: Double) -> Double
}


typealias SampleProcessor = (Double) -> Double
typealias SamplePlotter = (Double) -> CGFloat
