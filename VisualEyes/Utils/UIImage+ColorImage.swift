//
//  UIImage+ColorImage.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/23/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

extension UIImage {
    static func imageWithSize(size : CGSize, color : UIColor = UIColor.white) -> UIImage? {
        var image:UIImage? = nil
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.addRect(CGRect(origin: CGPoint.zero, size: size));
            context.drawPath(using: .fill)
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext()
        return image
    }
}
