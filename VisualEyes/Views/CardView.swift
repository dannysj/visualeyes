//
//  CardView.swift
//  Secrets
//
//  Created by Danny Chew on 7/5/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class CardView: UIView {
    let topLayerHeight: CGFloat = 30.0
    private lazy var topView : UIView = {
       let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        addBasicShadow()
        addTopDismissLayer()
    }
    
    var originalFrame: CGRect!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func addTopDismissLayer() {
    
        self.addSubview(topView)
        
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topView.topAnchor.constraint(equalTo: self.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: topLayerHeight)
            ])
        
        let dismissButtonView = UIView()
        dismissButtonView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dismissButtonView)
        
        NSLayoutConstraint.activate([
               dismissButtonView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
               dismissButtonView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 5),
               dismissButtonView.widthAnchor.constraint(equalToConstant: self.frame.width * 0.5),
               dismissButtonView.heightAnchor.constraint(equalToConstant: 8)
            ])
        
        dismissButtonView.backgroundColor = UIColor.FlatColor.White.darkLightGray
        dismissButtonView.layer.cornerRadius = (4)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(panDetected(panGR:)))
        topView.addGestureRecognizer(panGR)
        dismissButtonView.addGestureRecognizer(panGR)
    }
    
    @objc func panDetected(panGR: UIPanGestureRecognizer) {
        print("Pan detected")
        let translation = panGR.translation(in: self.topView )
        if panGR.state == .began {
            self.originalFrame = self.frame
        }
        self.frame = CGRect(x: originalFrame.minX, y: self.frame.minY + translation.y, width: originalFrame.width, height: originalFrame.height)
        if panGR.state == .ended {
            if translation.y >= 30.0 {
                let frame = CGRect(x: self.frame.minX, y: UIScreen.main.bounds.height, width: self.frame.width, height: self.frame.height)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.frame = frame
                }) { (_) in
                    self.removeFromSuperview()
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.frame = self.originalFrame
                })
            }
        }
        
    }
    
}
