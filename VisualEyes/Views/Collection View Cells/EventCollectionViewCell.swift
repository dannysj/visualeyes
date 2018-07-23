//
//  EventCollectionViewCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/23/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
enum EventType {
    case Summary
    case Normal
    
}
class EventCollectionViewCell: UICollectionViewCell {
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
