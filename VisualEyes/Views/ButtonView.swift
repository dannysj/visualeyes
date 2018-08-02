//
//  ButtonView.swift
//  VisualEyes
//
//  Created by Danny Chew on 8/1/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class ButtonView: UIView {
    lazy var compassView: CustomDrawView = {
        let rect =  CGRect(x: 0, y: 0, width: 30, height: 30)
        let v = CustomDrawView(type: .upArrow, lineColor: UIColor.white, frame: rect)
        v.translatesAutoresizingMaskIntoConstraints = false
    
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.width / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 5.0
        self.addBasicShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayDirectionButton() {
        addSmallCompass()
    }
    
    func addSmallCompass() {
        self.addSubview(compassView)
        self.sendSubview(toBack: compassView)
        NSLayoutConstraint.activate([
            compassView.widthAnchor.constraint(equalToConstant: 30),
            compassView.heightAnchor.constraint(equalToConstant: 30),
            compassView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            compassView.topAnchor.constraint(equalTo: self.topAnchor, constant: -30)
            ])
           
    }
}
