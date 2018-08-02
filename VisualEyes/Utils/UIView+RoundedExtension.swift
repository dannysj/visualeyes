//
//  UIView+RoundedExtension.swift
//  VoteBarTest
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addBasicShadow(color: UIColor = UIColor.black) {
        self.layer.shadowColor = color.withAlphaComponent(0.5).cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.masksToBounds = false
    }
    
    
    /**
     Rotate a view by specified degrees
     
     - parameter angle: angle in degrees
     */
    func rotate(radians: CGFloat) {
        let rotation = CGAffineTransform(rotationAngle: radians)
        self.transform = rotation
    }

    
}
