
import SpriteKit

import Speech



class SpeechGameScene: SKScene {
    
    
    var targetsByNote: [Note: SKNode] = [:]
    
    var playerCharacterNode: SKNode!
    
    
    let inputAudioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    
    override func didMove(to view: SKView) {
        
        self.initScene()
        self.recordAndRecognizeSpeech()
    }
    
    
    func initScene() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        for note in Note.allCases.filter({ !$0.isSharp }) {
            
            let labelNode = SKLabelNode(text: note.description.uppercased())
            labelNode.position = CGPoint(x: (-Int(self.size.width)/2...Int(self.size.width)/2).randomElement()!,
                                         y: (-Int(self.size.height)/2...Int(self.size.height)/2).randomElement()!)
            self.addChild(labelNode)
            
            self.targetsByNote[note] = labelNode
        }
        
        self.playerCharacterNode = SKSpriteNode(imageNamed: "jump outline")
        self.addChild(self.playerCharacterNode)
    }
    
    
    var currentNoteIndex = 0
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.currentNoteIndex += 1
        
        let note = Note.allCases.filter { !$0.isSharp } [self.currentNoteIndex % 7]
        
        self.move(to: note)
    }
    
    
    func move(to note: Note) {
        
        let target = targetsByNote[note]!
        
        self.playerCharacterNode.run(SKAction.move(to: target.position, duration: 0.4))
    }
    
    
    func recordAndRecognizeSpeech() {
        
        let node = self.inputAudioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        self.inputAudioEngine.prepare()
        try! self.inputAudioEngine.start()

        self.recognitionTask = self.speechRecognizer!.recognitionTask(with: self.request) { result, error in
            print("-----------")
            print("substring: \(result!.bestTranscription.segments.last?.substring)")
            print("alternativeSubstrings: \(result!.bestTranscription.segments.last?.alternativeSubstrings)")
            
            let letter = result!.bestTranscription.segments.last?.substring.last!.uppercased()
            print("letter: \(letter)")
            
            switch letter {
                case "A":
                self.move(to: .a)
                case "B":
                self.move(to: .b)
                case "C":
                self.move(to: .c)
                case "D":
                self.move(to: .d)
                case "E":
                self.move(to: .e)
                case "F":
                self.move(to: .f)
                case "G":
                self.move(to: .g)
            default:
                print("")
            }
        }
    }
}
