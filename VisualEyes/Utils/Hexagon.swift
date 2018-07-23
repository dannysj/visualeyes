//
//  Hexagon.swift
//  Skilled
//
//  Created by Danny Chew on 5/29/17.
//  Copyright © 2017 Danny Chew. All rights reserved.
//

import UIKit

enum HexagonType {
    case Normal
    case isRequired
    case Obtained
    case Summary
    case Empty
}

class Hexagon: UIView {
    var textLabel: UILabel!
    
    var number: Int = 1 {
        didSet {
            textLabel.text = "+\(number)"
        }
    }
    
    var type: HexagonType = .Normal
    var cornerRadius: CGFloat = 0
    var color: UIColor! = UIColor.FlatColor.Orange.golden
    var text: String! = "" {
        didSet {
            textLabel.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel = UILabel()
        self.backgroundColor = UIColor.clear
    }
    
    convenience init(type: HexagonType, badgeSize: CGFloat = 0, cornerRadius: CGFloat = 5.0) {
      
        self.init(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))

        self.type = type
        self.cornerRadius = cornerRadius
        //adding textLabel
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textLabel)
        textLabel.adjustsFontSizeToFitWidth = true
        
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
            ])
        // textLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
        textLabel.textAlignment = .center
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func draw(_ rect: CGRect) {
      
        
        // Drawing code
       
        let path = UIBezierPath(polygonIn: rect, sides: 6, lineWidth: 4.0, cornerRadius: cornerRadius)
        
        if (rect.width < 30.0) {
            path.lineWidth = 0
        }
        else {
            path.lineWidth = rect.width / 25
        }
        
        switch type {
        case .isRequired:
            path.setLineDash([bounds.width / 8, bounds.width / 6], count: 2, phase: 0.0)
            UIColor.gray.setStroke()
            color = color.withAlphaComponent(0.5)
            break
        
        case .Obtained:
            path.setLineDash([bounds.width / 8, bounds.width / 6], count: 2, phase: 0.0)
            UIColor.darkGray.setStroke()
            break
            
        case .Normal:
            UIColor.white.setStroke()
            break
            
        case .Summary:
            UIColor.white.setStroke()
            color = UIColor.FlatColor.White.clouds
            textLabel.textColor = UIColor.FlatColor.Blue.midnightBlue
            break
            
        case .Empty:
            color = UIColor.clear
            path.setLineDash([bounds.width / 8, bounds.width / 6], count: 2, phase: 0.0)
            UIColor.lightGray.setStroke()
            break
        }
        
        color.setFill()
        path.stroke()
        path.fill()
      //  self.transform =  CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        

    }
    
  
}
