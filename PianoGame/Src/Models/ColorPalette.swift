
import SpriteKit


struct ColorPalette {

    
    #if os(macOS)
    let backgroundColor: NSColor
    let foregroundColor: NSColor
    let correctColor: NSColor
    let incorrectColor: NSColor
    #elseif os(iOS)
    let backgroundColor: UIColor
    let foregroundColor: UIColor
    let correctColor: UIColor
    let incorrectColor: UIColor
    #endif
}
