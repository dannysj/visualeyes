//
//  Badge.swift
//  VisualEyes
//
//  Created by Danny Chew on 8/1/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class Badge: UIView {
    private var distance: Double = 0.0 {
        didSet {
            label.text = String(format: "%.2fm", distance)
        }
    }
    private var hexagonLength: CGFloat = 30.0
    private lazy var hexagonView: Hexagon = {
        let v = Hexagon(type: .Normal, badgeSize: hexagonLength, cornerRadius: 5.0)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addBasicShadow()
        v.alpha = 0.7
        return v
        
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    private lazy var label: UILabel = {
       let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = Theme.preferredFontWithMidSize()
        l.textColor = UIColor.white
        l.addBasicShadow()
        
        return l
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBadge(distance: Double) {
        
        setupView()
        updateDistance(distance: distance)
    }
    
    func setupView() {
        self.addSubview(hexagonView)
        NSLayoutConstraint.activate([
            hexagonView.topAnchor.constraint(equalTo: self.topAnchor),
            hexagonView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hexagonView.widthAnchor.constraint(equalToConstant: hexagonLength),
            hexagonView.heightAnchor.constraint(equalToConstant: hexagonLength)
            ])
        
        
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: hexagonView.bottomAnchor, constant: 5)
            ])
        
    }
    func updateDistance(distance: Double) {
        self.distance = distance
    }
    

}
