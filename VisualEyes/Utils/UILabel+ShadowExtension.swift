//
//  UILabel+ShadowExtension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/25/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
}
