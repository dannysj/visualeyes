//
//  CGFloat+RadToDeg.swift
//  Secrets
//
//  Created by Danny Chew on 8/1/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}
extension Double {
    var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
    var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
}
