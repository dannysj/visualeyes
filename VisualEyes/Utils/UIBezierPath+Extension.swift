//
//  UIBezierPath+Extension.swift
//  Crumbs
//
//  Created by Danny Chew on 7/31/17.
//  Copyright © 2017 Danny Chew. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    convenience init(heartIn rect: CGRect) {
        self.init()
        
        //Calculate Radius of Arcs using Pythagoras
        let sideOne = rect.width * 0.4
        let sideTwo = rect.height * 0.3
        let arcRadius = sqrt(sideOne*sideOne + sideTwo*sideTwo)/2
        
        //Left Hand Curve
        self.addArc(withCenter: CGPoint(x: rect.width * 0.3, y: rect.height * 0.35), radius: arcRadius, startAngle: 135.degreesToRadians, endAngle: 315.degreesToRadians, clockwise: true)
        
        //Top Centre Dip
        self.addLine(to: CGPoint(x: rect.width/2, y: rect.height * 0.2))
        
        //Right Hand Curve
        self.addArc(withCenter: CGPoint(x: rect.width * 0.7, y: rect.height * 0.35), radius: arcRadius, startAngle: 225.degreesToRadians, endAngle: 45.degreesToRadians, clockwise: true)
        
        //Right Bottom Line
        self.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95))
        
        //Left Bottom Line
        self.close()
    }
    
    /// Create UIBezierPath for regular polygon with rounded corners
    ///
    /// - parameter rect:            The CGRect of the square in which the path should be created.
    /// - parameter sides:           How many sides to the polygon (e.g. 6=hexagon; 8=octagon, etc.).
    /// - parameter lineWidth:       The width of the stroke around the polygon. The polygon will be inset such that the stroke stays within the above square. Default value 1.
    /// - parameter cornerRadius:    The radius to be applied when rounding the corners. Default value 0.
    
    convenience init(polygonIn rect: CGRect, sides: Int, lineWidth: CGFloat = 1, borderWidth: CGFloat = 5.0,cornerRadius: CGFloat = 0) {
        self.init()
        
        let theta = 2 * CGFloat.pi / CGFloat(sides)                        // how much to turn at every corner
        let offset = cornerRadius * tan(theta / 2)                  // offset from which to start rounding corners
        let squareWidth = min(rect.size.width, rect.size.height) - borderWidth
        // width of the square
        
        // calculate the length of the sides of the polygon
        
        var length = squareWidth - lineWidth
        if sides % 4 != 0 {                                         // if not dealing with polygon which will be square with all sides ...
            length = length * cos(theta / 2) + offset / 2           // ... offset it inside a circle inside the square
        }
        let sideLength = length * tan(theta / 2)
        
        // start drawing at `point` in lower right corner, but center it
        
        var point = CGPoint(x: rect.origin.x + rect.size.width / 2 + sideLength / 2 - offset, y: rect.origin.y + rect.size.height / 2 + length / 2)
        var angle = CGFloat.pi
        
        move(to: point)
        
        
        
        // draw the sides and rounded corners of the polygon
        
        for _ in 0 ..< sides {
            point = CGPoint(x: point.x + (sideLength - offset * 2) * cos(angle), y: point.y + (sideLength - offset * 2) * sin(angle))
            addLine(to: point)
            
            let center = CGPoint(x: point.x + cornerRadius * cos(angle + .pi / 2), y: point.y + cornerRadius * sin(angle + .pi / 2))
            addArc(withCenter: center, radius: cornerRadius, startAngle: angle - .pi / 2, endAngle: angle + theta - .pi / 2, clockwise: true)
            
            point = currentPoint
            angle += theta
        }
        
        
        close()
        
        self.lineWidth = lineWidth           // in case we're going to use CoreGraphics to stroke path, rather than CAShapeLayer
        lineJoinStyle = .round
        /*
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        if sides == 6 {
        
            self.apply(CGAffineTransform(translationX: center.x, y: center.y).inverted())
            self.apply(CGAffineTransform(rotationAngle: CGFloat.pi / 2.0))
            self.apply(CGAffineTransform(translationX: center.x, y: center.y))
        }*/
        
    }
    
    convenience init (starPathInRect rect: CGRect) {
        self.init()
        
        let starExtrusion: CGFloat = 30.0
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        let pointsOnStar = 5 + arc4random() % 10
        
        var angle:CGFloat = -CGFloat(CGFloat.pi / 2.0)
        let angleIncrement = CGFloat(CGFloat.pi  * 2.0 / CGFloat(pointsOnStar))
        let radius = rect.width / 2.0
        
        var firstPoint = true
        
        for _ in 1...pointsOnStar {
        
            let point = center.pointTo(angle: angle, radius: radius)
            let nextPoint = center.pointTo(angle: angle + angleIncrement, radius: radius)
            let midPoint = center.pointTo(angle: angle + angleIncrement / 2.0, radius: starExtrusion)
            
            if firstPoint {
                firstPoint = false
                move(to: point)
            }
            
            addLine(to: midPoint)
            addLine(to: nextPoint)
            
            angle += angleIncrement
        }
        
        close()
    }

}

extension CGPoint {
    func pointTo(angle: CGFloat , radius: CGFloat) -> CGPoint {
        let x = self.x + ( radius * cos(angle))
        let y = self.y + (radius * sin(angle))
        
        return CGPoint(x: x, y: y)
    }
}

// for degree to rad

extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}
