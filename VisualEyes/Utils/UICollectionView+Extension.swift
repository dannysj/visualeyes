//
//  UICollectionView+Extension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/24/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
extension UICollectionView {
    func enableVerticalScrollingOnly() {
        self.isScrollEnabled = true
        self.alwaysBounceHorizontal = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    func enableHorizontalScrollingOnly() {
        self.isScrollEnabled = true
        self.alwaysBounceVertical = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
}
