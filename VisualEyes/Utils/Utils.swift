//
//  Utils.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/27/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Queue<T> {
    private var array: [T]
    
    public init() {
        array = []
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        }
        else {
            return array.removeFirst()
        }
    }
    
    public func peek() -> T? {
        return array.first
    }
}

public struct Stack<T> {
    private var array: [T]
    
    public init() {
        array = []
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func put(_ element: T) {
        array.append(element)
    }
    public mutating func pop() -> T? {
        if isEmpty {
            return nil
        }
        else {
            return array.removeLast()
        }
    }
    
    public func peek() -> T? {
        return array.last
    }
    
    public func reverse() -> [T] {
        return array.reversed()
    }
}

public func random(min: Int, max: Int) -> Int {
    assert(min < max)
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}


extension Sequence where Iterator.Element == CGPoint {
    internal var boundingRect: CGRect? {
        let xValues = map({ $0.x })
        let yValues = map({ $0.y })
        guard let minX = xValues.min(),
            let minY = yValues.min(),
            let maxX = xValues.max(),
            let maxY = yValues.max() else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

fileprivate var jiggle: CGFloat {
    return (CGFloat(arc4random()) - CGFloat(UInt32.max / 2)) * 1e-6
}

extension CGPoint {
    internal var jiggled: CGPoint {
        var point = self
        if point.x == 0 { point.x = jiggle }
        if point.y == 0 { point.y = jiggle }
        return point
    }
    
    internal var magnitude: CGFloat {
        return sqrt(x * x + y * y)
    }
}

