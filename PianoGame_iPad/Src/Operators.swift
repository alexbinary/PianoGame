
import CoreGraphics


func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
 
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}


func +=(lhs: inout CGPoint, rhs: CGPoint) {
 
    lhs.x += rhs.x
    lhs.y += rhs.y
}
