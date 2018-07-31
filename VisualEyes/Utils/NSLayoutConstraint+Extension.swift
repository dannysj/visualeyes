//
//  NSLayoutConstraint+Extension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/24/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
extension NSLayoutConstraint {
    static func activateAllConstraintsEqually(child: UIView, parent: UIView, constant: CGFloat = 0.0) {
        self.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: constant),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: constant),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -constant),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -constant)
            ])
    }
    static func activateAllConstraintsEquallyInCollectionView(child: UIView, parent: UIView, constant: CGFloat = 0.0) {
        self.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: constant),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: constant / 2.0),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -constant / 2.0),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -constant)
            ])
    }
    static func centerWithHeightAndWidth(child: UIView, parent: UIView, height: CGFloat, width: CGFloat) {
        self.activate([
            child.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            child.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            child.heightAnchor.constraint(equalToConstant: height),
            child.widthAnchor.constraint(equalToConstant: width)
            ])
    }
    
    static func activateConstraintForTitleAtCenterY(child: UIView, parent: UIView, constant: CGFloat = 0.0) {
        self.activate([
            child.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: constant),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -constant),
      
            ])
    }
    
    
}

