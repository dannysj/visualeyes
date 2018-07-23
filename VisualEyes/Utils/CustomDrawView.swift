//
//  CustomDrawView.swift
//  Skilled
//
//  Created by Danny Chew on 6/17/17.
//  Copyright © 2017 Danny Chew. All rights reserved.
//

import UIKit

enum CustomDrawing {
    case Worker
    case UpperCut
    case LowerCut
    case People
    case RightArrow
    case tick
    case cross
    case Uninitialized
    case upArrow
    case Heart
    case Back
    case Next
    case MiniMan
    case SearchHexagon
    case Search
    case Drawer
    case Recorder
    case Camera
    case Filter
    case Play
    case Pause
    case Circle
    case Star
    case Plus
    
//    case Hexagon use Hexagon.swift
}

class CustomDrawView: UIView {
    
    var type: CustomDrawing = .Uninitialized
    var lineColor: UIColor! = UIColor.FlatColor.White.darkMediumGray
    
    private let tableHeaderViewCutAway: CGFloat = 20.0
    private var height: CGFloat = 0
    private var width: CGFloat = 0
    
    var fillLayer: CAShapeLayer = CAShapeLayer()
    
    convenience init(type: CustomDrawing, lineColor: UIColor, frame: CGRect = CGRect.zero) {
        self.init(frame: frame)
        self.type = type
        self.lineColor = lineColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.height = frame.height
        self.width = frame.width
        self.backgroundColor = UIColor.clear
        
        print("\(self.height) && \(self.width)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        // Drawing code
        // c = 2r sin theta/2
        
        switch type {
        case .Worker:
            //draw a head
            let headWidth = self.width * 0.6
            let originX = self.bounds.width / 2 - headWidth / 2
            let originY = height * 0.2
            let path = UIBezierPath(ovalIn: CGRect(x: originX, y: originY, width: headWidth , height: headWidth))
            
            path.lineJoinStyle = .round
            lineColor.setStroke()
            path.stroke()
            UIColor.white.setFill()
            path.fill()
            
            //parametric equation
            // x = cx + r * cos(a)
            // y = cy + r * sin(a)
            var angle:CGFloat = CGFloat.pi / 2.5
            var x = (originX + headWidth / 2) + (headWidth / 2) * cos(angle)
            let y = (originY + headWidth / 2) + (headWidth / 2) * sin(angle)
            
            //draw rightSide
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 10, y: height))
            path.close()
            path.stroke()
                
            
            //draw leftSide
            angle = CGFloat.pi / 2 - angle
            angle = CGFloat.pi / 2 + angle
            x = (originX + headWidth / 2) + (headWidth / 2) * cos(angle)
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x - 10, y: height))
            path.stroke()
            
            
            //draw mouth
            let mouthWidth = headWidth * 0.7
            let startX = self.bounds.width / 2 - mouthWidth / 2
            let startY = originY + headWidth / 2
            let controlPointX = self.bounds.width / 2
            
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX + mouthWidth, y: startY))
            path.addArc(withCenter: CGPoint(x: controlPointX,y: startY), radius: mouthWidth / 2, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            path.close()
            
            path.stroke()
            
            
            //tie
            //upper diamond
            let startAngle:CGFloat = CGFloat.pi / 2.2
            let endAngle: CGFloat = (CGFloat.pi / 2) + (CGFloat.pi / 2 - startAngle)
            let tieStartX = (originX + headWidth / 2) + (headWidth / 2) * cos(startAngle)
            let tieStartY = (originY + headWidth / 2) + (headWidth / 2) * sin(startAngle)
            
            let tieEndX = (originX + headWidth / 2) + (headWidth / 2) * cos(endAngle)
            let tieEndY = (originY + headWidth / 2) + (headWidth / 2) * sin(endAngle)
            let tiePath = UIBezierPath()
            tiePath.move(to: CGPoint(x: tieStartX, y: tieStartY))
            tiePath.addArc(withCenter: CGPoint(x: self.bounds.width / 2,y: startY), radius: headWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            let bottomCircleCenter = (originY + headWidth / 2) + (headWidth / 2) * sin(CGFloat.pi / 2)
            tiePath.move(to: CGPoint(x: tieEndX, y: tieEndY))
            tiePath.addQuadCurve(to: CGPoint(x: tieStartX, y: tieStartY) , controlPoint: CGPoint(x: (tieStartX + tieEndX) / 2, y: bottomCircleCenter + 10))
            tiePath.close()
            
            lineColor.setStroke()
            lineColor.setFill()
            tiePath.stroke()
            tiePath.fill()
            
            let centerX = (tieStartX + tieEndX ) / 2
            
            tiePath.move(to: CGPoint(x: centerX , y: bottomCircleCenter))
            tiePath.addLine(to: CGPoint(x: centerX + 5, y: bottomCircleCenter + 13))
            tiePath.addLine(to: CGPoint(x: centerX, y: bottomCircleCenter + 18))
            tiePath.addLine(to: CGPoint(x: centerX - 5, y: bottomCircleCenter + 13))
            tiePath.addLine(to: CGPoint(x: centerX , y: bottomCircleCenter ))
            
            tiePath.stroke()
            tiePath.fill()
            
            break
            
        case .People:
            //draw a head
            let headWidth = self.width * 0.6
            let originX = self.bounds.width / 2 - headWidth / 2
            let originY = height * 0.2
            let path = UIBezierPath(ovalIn: CGRect(x: originX, y: originY, width: headWidth , height: headWidth))
            
            path.lineJoinStyle = .round
            lineColor.setStroke()
            path.stroke()
            UIColor.white.setFill()
            path.fill()
            
            //parametric equation
            // x = cx + r * cos(a)
            // y = cy + r * sin(a)
            var angle:CGFloat = CGFloat.pi / 3
            var x = (originX + headWidth / 2) + (headWidth / 2) * cos(angle)
            let y = (originY + headWidth / 2) + (headWidth / 2) * sin(angle)
            
            //FIXME:
            print("\(x) and \(y) is x and y, \(CGFloat.pi * 3 / 4) and \(headWidth / 2)")
            
            //draw rightSide
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 10, y: height))
            // path.close()
            path.stroke()
            
            
            //draw leftSide
            angle = CGFloat.pi * 2 / 3
            x = (originX + headWidth / 2) + (headWidth / 2) * cos(angle)
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x - 10, y: height))
            path.stroke()
            
            //draw mouth
            let mouthWidth = headWidth * 0.7
            let startX = self.bounds.width / 2 - mouthWidth / 2
            let startY = originY + headWidth / 2
            let controlPointX = self.bounds.width / 2
            
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX + mouthWidth, y: startY))
            path.addArc(withCenter: CGPoint(x: controlPointX,y: startY), radius: mouthWidth / 2, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            path.close()
            
            path.stroke()
            
            break
            
        case .UpperCut:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: tableHeaderViewCutAway))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.close()
            
            UIColor.clear.setStroke()
            path.stroke()
            
            break
            
        case .LowerCut:
            let path = UIBezierPath()
            let frameWidth = frame.width
            let frameHeight = frame.height
            path.move(to: CGPoint(x: 0, y: tableHeaderViewCutAway))
            path.addLine(to: CGPoint(x: frameWidth, y: 0))
            path.addLine(to: CGPoint(x: frameWidth, y: frameHeight))
            path.addLine(to: CGPoint(x: 0, y:  frameHeight))
            path.close()
            
            UIColor.clear.setStroke()
            path.stroke()
            
            //then, draw a divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: 0, y: tableHeaderViewCutAway))
            dividerPath.addLine(to: CGPoint(x: frameWidth, y: 2))
            dividerPath.close()
            
            
            lineColor.setStroke()
            dividerPath.lineWidth = 1.0
            dividerPath.lineJoinStyle = .round
            
            dividerPath.stroke()
            
            break
            
            
            
        case .RightArrow:
            let path = UIBezierPath()
            let frameWidth = frame.width
            let frameHeight = frame.height
            
            path.move(to: CGPoint(x: 8, y: frameHeight / 2))
            path.addLine(to: CGPoint(x: frameWidth - 8, y: frameHeight / 2))
            path.move(to: CGPoint(x: frameWidth / 2, y: 10))
            path.addLine(to: CGPoint(x: frameWidth - 8, y: frameHeight / 2))
            path.move(to: CGPoint(x: frameWidth / 2, y: frameHeight - 10))
            path.addLine(to: CGPoint(x: frameWidth - 8, y: frameHeight / 2))
            
            lineColor.setStroke()
            path.stroke()
            
            break
            
        case .tick:
            
            print("\(height), \(width) & \(frame)")
            let frameHeight = frame.height
            let frameWidth = frame.width
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 10, y: frameHeight / 2 ))
            path.addLine(to: CGPoint(x: frameWidth / 3, y: frameHeight * 3 / 4 ))
            path.addLine(to: CGPoint(x: frameWidth - 10 , y: frameHeight / 3))
            path.lineWidth = 2
            path.lineCapStyle = .round
            
            lineColor.setStroke()
            path.stroke()
            
            break
            
        case .cross:
            
            let path = UIBezierPath()
            let frameHeight = frame.height
            let frameWidth = frame.width
            path.move(to: CGPoint(x: 20, y: 20))
            path.addLine(to: CGPoint(x: frameWidth - 20, y: frameHeight - 20))
            path.move(to: CGPoint(x: 20, y: frameHeight - 20))
            path.addLine(to: CGPoint(x: frameWidth - 20, y: 20))
            path.lineWidth = 2
            path.lineCapStyle = .round
            
            lineColor.setStroke()
            path.stroke()
            
            break
            
        case .upArrow:
            let path = UIBezierPath()
            let frameHeight = frame.height
            let frameWidth = frame.width
            path.move(to: CGPoint(x: self.bounds.origin.x, y: self.bounds.midY))
            path.addLine(to: CGPoint(x: self.bounds.midX, y: self.bounds.origin.y + 3))
            path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.midY))
            
            path.lineWidth = 2
            path.lineCapStyle = .round
            
            lineColor.setStroke()
            path.stroke()
            break
            
        case .Heart:
            
            let heart = UIBezierPath(heartIn: self.bounds)
            lineColor.setStroke()
            heart.lineWidth = 1
            
            heart.lineCapStyle = .round
            heart.stroke()
            
            //set fill layer
            fillLayer.path = heart.cgPath
            
            break
            
        case .Back:
            let path = UIBezierPath()
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            path.move(to: CGPoint(x: self.bounds.midX, y: self.bounds.origin.y + 3))
            path.addLine(to: CGPoint(x: self.bounds.origin.x + 3, y: self.bounds.midY))
            path.addLine(to: CGPoint(x: self.bounds.midX, y: self.bounds.height - 3))
            
            path.lineWidth = 3
            path.lineCapStyle = .round
            
            
            lineColor.setStroke()
            path.stroke()
            break
            
        case .Next:
            let path = UIBezierPath()
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let offsetX = frameWidth / 5.0
            let offsetY = frameHeight / 5.0
            
            path.move(to: CGPoint(x: self.bounds.midX - offsetX / 1.5, y: self.bounds.origin.y + offsetY))
            path.addLine(to: CGPoint(x: self.bounds.width - offsetX - offsetX / 2.5, y: self.bounds.midY))
            path.addLine(to: CGPoint(x: self.bounds.midX - offsetX / 1.5, y: self.bounds.height - offsetY))
            
            path.lineWidth = 3
            path.lineCapStyle = .round
            
            
            lineColor.setStroke()
            path.stroke()
            break
            
        case .MiniMan:
            let path = UIBezierPath()
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let r = frameHeight / 4.5
            let space = frameHeight * 0.05
            let circleCenter: CGPoint = CGPoint(x: self.bounds.midX, y: space  + ( r / 2.0))
            path.move(to: circleCenter)
            path.addArc(withCenter: circleCenter, radius: r / 2.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            lineColor.setStroke()
            lineColor.setFill()
            path.stroke()
            path.fill()
            
            
            // then
            let avaialbleHeight = frameHeight - ((space * 2 ) + r)
            let rectSides: CGFloat = min(avaialbleHeight, frameWidth)
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            let rect = CGRect(x: self.bounds.midX - (frameWidth / 2.0), y: r + (space), width: frameWidth, height: avaialbleHeight)
            
            let bodyPath = UIBezierPath(polygonIn: rect, sides: 3, lineWidth: 1, borderWidth: 1, cornerRadius: rectSides / 3)
            
            bodyPath.stroke()
            bodyPath.fill()
            
            break
            
        case .Filter:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            
            let filterWidth = frameWidth / 2.0
            let filterHeight = frameHeight * 0.7
            let path = UIBezierPath()
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            let startPoint = CGPoint(x: self.bounds.midX - filterWidth / 2.0, y: self.bounds.midY - filterHeight / 2.0)
            let lineEndPoint = CGPoint(x: self.bounds.midX + filterWidth / 2.0, y: self.bounds.midY - filterHeight / 2.0)
            path.move(to: startPoint)
            path.addLine(to: lineEndPoint)
            
            //then
            let theta = CGFloat.pi / 3.0
            
            let leftX = filterWidth / 2.0 * 0.9
            let yPoint = filterHeight * 0.6
            
            path.addLine(to: CGPoint(x: lineEndPoint.x - leftX, y: lineEndPoint.y + yPoint))
            path.move(to: startPoint)
            path.addLine(to: CGPoint(x: startPoint.x + leftX, y: startPoint.y + yPoint))
            
            //then the lower filter part
            path.addLine(to: CGPoint(x: startPoint.x + leftX, y: startPoint.y + filterHeight))
            // /
            path.addLine(to: CGPoint(x: lineEndPoint.x - leftX, y: startPoint.y + (filterHeight * 0.8)))
             path.addLine(to: CGPoint(x: startPoint.x + leftX, y: startPoint.y + yPoint))
            
            lineColor.setStroke()
            lineColor.setFill()
            
            path.stroke()
            path.fill()
            
            break
            
        case .SearchHexagon:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let circleRadius = frameWidth * 0.7
            let path = UIBezierPath()
            let lineWidth: CGFloat = 2.0
            let circleCenter = CGPoint(x: self.bounds.midX ,y:  self.bounds.midY)
            
            path.addArc(withCenter: circleCenter, radius: circleRadius / 2.0 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            
            let r = circleRadius / 2.0
            let x = circleCenter.x + (r * sin(CGFloat.pi / 4))
            let y = circleCenter.y + (r * cos(CGFloat.pi / 4))
            
            
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: frameWidth - (frameWidth / 7), y: y + 5))
            
            path.lineWidth = lineWidth
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            lineColor.setStroke()
            path.stroke()
            
            //then, hexagon at center
            let availableWidth = circleRadius * 0.5
            let hexaRect = CGRect(x: circleCenter.x - availableWidth / 2.0, y: circleCenter.y - availableWidth / 2.0, width: availableWidth, height: availableWidth)
            let hexagonPath = UIBezierPath(polygonIn: hexaRect, sides: 6, lineWidth: 1, borderWidth: 1, cornerRadius: 0)

            lineColor.setFill()
            lineColor.setStroke()
            hexagonPath.stroke()
            hexagonPath.fill()
            
            break
            
        case .Search:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let circleRadius = frameWidth * 0.7
            let path = UIBezierPath()
            let lineWidth: CGFloat = 2.0
            let circleCenter = CGPoint(x: self.bounds.midX ,y:  self.bounds.midY)
            
            path.addArc(withCenter: circleCenter, radius: circleRadius / 2.0 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            
            let r = circleRadius / 2.0
            let x = circleCenter.x + (r * sin(CGFloat.pi / 4))
            let y = circleCenter.y + (r * cos(CGFloat.pi / 4))
            
            
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: frameWidth - (frameWidth / 8), y: y + (frameHeight / 7)))
            
            path.lineWidth = lineWidth
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            lineColor.setStroke()
            path.stroke()
            break
            
        case .Drawer:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let firstRect = CGRect(x: self.bounds.origin.x + 1, y: self.bounds.midY , width: frameWidth - 2, height: (frameHeight / 2.0) - 1)
            
            let path = UIBezierPath(roundedRect: firstRect, cornerRadius: frameHeight / 14.0)
            path.lineCapStyle  = .round
            path.lineJoinStyle = .round
            path.lineWidth = 2
            
            path.move(to: CGPoint(x: self.bounds.origin.x + 2, y: self.bounds.midY))
            path.addLine(to: CGPoint(x: self.bounds.origin.x + 6, y: self.bounds.origin.y + 5))
            path.addLine(to: CGPoint(x: self.bounds.width - 6, y: self.bounds.origin.y + 5))
            path.addLine(to: CGPoint(x: self.bounds.width - 2, y: self.bounds.midY))
            
            //then, draw the center line
            
            let lineWidth = frameWidth * 0.3
            let lineY = frameHeight * 3 / 4.0
            
            path.move(to: CGPoint(x: self.bounds.midX - lineWidth / 2.0  , y: lineY))
            path.addLine(to: CGPoint(x: self.bounds.midX + lineWidth / 2.0  , y: lineY))
            
            lineColor.setStroke()
            path.stroke()
            
            break
            
        case .Recorder:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let recordHeight = frameHeight * 0.6
            let recordBunWidth = frameWidth / 3.0
            
            let roundRect = CGRect(x: self.bounds.midX - recordBunWidth / 2.0, y: self.bounds.midY - recordHeight / 2.0, width: recordBunWidth, height: recordHeight)
            
            
            
            let roundRectPath = UIBezierPath(roundedRect: roundRect, cornerRadius: recordBunWidth / 2.0)
            roundRectPath.lineCapStyle = .round
            roundRectPath.lineJoinStyle = .round
            lineColor.setStroke()
            lineColor.setFill()
            roundRectPath.stroke()
            roundRectPath.fill()
            
            //then
        
            let path = UIBezierPath()
            let centerPoint = CGPoint(x: roundRect.midX, y: roundRect.midY + recordHeight * 0.1)
            let radius = recordBunWidth * 1.2
            path.addArc(withCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            
            let nextStartPoint = CGPoint(x: centerPoint.x, y: centerPoint.y + radius)
            path.move(to: nextStartPoint)
            path.addLine(to: CGPoint(x: nextStartPoint.x, y: nextStartPoint.y + frameHeight * 0.25))
            
            let newCenterPoint = CGPoint(x: nextStartPoint.x, y: nextStartPoint.y + frameHeight * 0.25)
            let bottomWidth = frameWidth / 2.5
            path.move(to: CGPoint(x: nextStartPoint.x - bottomWidth / 2.0, y: nextStartPoint.y))
            path.addLine(to: CGPoint(x: nextStartPoint.x + bottomWidth / 2.0, y: nextStartPoint.y))
            lineColor.setStroke()
      
            path.stroke()

            break
            
        case .Camera:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            //circle at center
            let circleRadius = frameHeight * 0.7
            let cameraPath = UIBezierPath(arcCenter: self.center, radius: circleRadius / 2.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            
            //then , bracket and sides
            let largerRadius = circleRadius * 1.2
            let cameraWidth = frameWidth * 0.85
            
            cameraPath.lineCapStyle = .round
            cameraPath.lineJoinStyle = .round
            
            let startPoint = CGPoint(x: self.bounds.midX - cameraWidth / 2.0, y: self.bounds.midY - largerRadius / 2.0)
            let eachLineWidth = cameraWidth / 7.0
            
            cameraPath.move(to: startPoint)
            cameraPath.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + largerRadius))
            cameraPath.addLine(to: CGPoint(x: startPoint.x + eachLineWidth, y: startPoint.y + largerRadius))
            cameraPath.move(to: startPoint)
            cameraPath.addLine(to: CGPoint(x: startPoint.x + eachLineWidth, y: startPoint.y))
            
            //right side
            let rightStartPoint = CGPoint(x: self.bounds.midX + cameraWidth / 2.0, y: self.bounds.midY - largerRadius / 2.0)
            cameraPath.move(to: rightStartPoint)
            cameraPath.addLine(to: CGPoint(x: rightStartPoint.x - eachLineWidth, y: rightStartPoint.y))
            cameraPath.move(to: rightStartPoint)
            cameraPath.addLine(to: CGPoint(x: rightStartPoint.x, y: rightStartPoint.y + largerRadius))
            cameraPath.addLine(to:  CGPoint(x: rightStartPoint.x - eachLineWidth, y: rightStartPoint.y + largerRadius))
            
            // shuttle button
            let shuttleButtonStartPoint = CGPoint(x: rightStartPoint.x - eachLineWidth, y: self.bounds.midY - largerRadius * 1.2)
            let shuttleButtonLength = cameraWidth / 5.0
            cameraPath.move(to: shuttleButtonStartPoint)
            cameraPath.addLine(to: CGPoint(x: shuttleButtonStartPoint.x - shuttleButtonLength, y: shuttleButtonStartPoint.y))
            
            lineColor.setStroke()
            cameraPath.stroke()
            
            break
            
        case .Circle:
            
            break
            
        case .Star:
            
            break
            
        case .Play:
            let frameHeight = frame.height
            let frameWidth = frame.width
            
            let insetRect = rect.insetBy(dx: frameWidth / 5.0, dy: frameHeight / 5.0)
            let path = UIBezierPath()
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            path.move(to: insetRect.origin)
            path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.midY))
            path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY))
            path.close()
            
            lineColor.setStroke()
            lineColor.setFill()
            
            path.stroke()
            path.fill()
            
            
            break
            
        case .Plus:
            
            let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
            
            
            let plusPath = UIBezierPath()
            plusPath.lineWidth = 2.0
            plusPath.lineCapStyle = .round
            
            plusPath.move(to: CGPoint(x: bounds.width / 2 - plusWidth / 2 + 0.5, y: bounds.height / 2 + 0.5))
            plusPath.addLine(to: CGPoint(x: bounds.width / 2 + plusWidth / 2 + 0.5 , y: bounds.height / 2 + 0.5))
            
            //vertical line
            plusPath.move(to: CGPoint(x: bounds.width / 2 + 0.5, y: bounds.height / 2 - plusWidth / 2 + 0.5))
            plusPath.addLine(to: CGPoint(x: bounds.width / 2 + 0.5, y: bounds.height / 2 + plusWidth / 2 + 0.5))
            
            lineColor.setStroke()
            
            plusPath.stroke()
            
            break
        default:
            fatalError("CustomDrawing is not initialized")
        }

        
    }
    
    // MARK: Animation Helper Method
    
    func circleAnimation() -> CAShapeLayer{
        
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: frame.height / 2, y: frame.width / 2), radius: frame.width / 2, startAngle: CGFloat( 3 * Double.pi / 2), endAngle: CGFloat( (3 * Double.pi / 2) + 2 * Double.pi), clockwise: true)
        
        let progressCircle = CAShapeLayer()
        progressCircle.path = arcPath.cgPath
        progressCircle.strokeColor = lineColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = 1
        progressCircle.lineCap = kCALineCapRound
    
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // MARK: edit the progress at here
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        progressCircle.add(animation, forKey: "progressCircle")
        return progressCircle
    }
    

    

}
