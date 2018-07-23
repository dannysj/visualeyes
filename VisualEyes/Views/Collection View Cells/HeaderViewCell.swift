//
//  HeaderViewCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/22/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
class HeaderViewCell: UICollectionViewCell {

    func setupViews() {
        self.contentView.backgroundColor = UIColor.FlatColor.Red.lightPink
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if self.subviews.contains(self.contentView) {
            for subView in self.contentView.subviews {
                subView.removeFromSuperview()
            }
        }
        setupViews()
    }
}
