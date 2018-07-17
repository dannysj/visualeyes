//
//  CGMutablePath+addArrowLine.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/28/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import CoreGraphics

extension CGMutablePath {
    func addArrowLine(from: CGPoint, to: CGPoint, spacing: CGFloat) {
        
        let headLength = spacing / 3
        let headWidth = spacing / 2.5
        let length = hypot(to.x - from.x, to.y - from.y)
        let tailLength = length - headLength - spacing
        
        if length.isNaN {
            fatalError()
        }
        
        let points: [CGPoint] = [
            //.
            CGPoint(x: spacing,y: 0),
            // _
            CGPoint(x: tailLength,y: 0),
            // |
            CGPoint(x: tailLength,y: headWidth / 2),
            // \
            CGPoint(x: length - spacing,y:  0),
            // /
            CGPoint(x: tailLength,y: -headWidth / 2),
            // |
            CGPoint(x: tailLength,y: 0),
            
            ]
        
        let cosine = (to.x - from.x) / length
        let sine = (to.y - from.y) / length
        
        if cosine.isNaN {
            fatalError()
        }
        
        if sine.isNaN {
            fatalError()
        }
        
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: from.x, ty: from.y)
        
        addLines(between: points, transform: transform)
        
    }
    
    func addLineWithSpacing(from: CGPoint, to: CGPoint, spacing: CGFloat) {
        
        let length = hypot(to.x - from.x, to.y - from.y)
        let tailLength = length - spacing
        

        let points: [CGPoint] = [
            //.
            CGPoint(x: spacing,y: 0),
            // _
            CGPoint(x: tailLength,y: 0),

            
            ]

        let cosine = (to.x - from.x) / length
        let sine = (to.y - from.y) / length
        
        if cosine.isNaN {
            fatalError()
        }
        
        if sine.isNaN {
            fatalError()
        }
        
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: from.x, ty: from.y)
        
         addLines(between: points, transform: transform)
        
    }
}
