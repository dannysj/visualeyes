//
//  NestedHeaderCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/24/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

// FIXME: UICollectionViewCell
class NestedHeaderCell: UIView {
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Theme.preferredFontWithTitleSize()
        l.textColor = Theme.textColor()
        return l
    }()
  
    private var title: String = "" {
        didSet {
            setupViews()
        }
    }
    
    func setupViews() {
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
            ])
        
        label.text = title
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    /*
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if self.subviews.contains(self.contentView) {
            for subView in self.contentView.subviews {
                subView.removeFromSuperview()
            }
        }
        setupViews()
    }*/
}
