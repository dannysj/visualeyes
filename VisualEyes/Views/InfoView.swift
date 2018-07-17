//
//  InfoView.swift
//  Secrets
//
//  Created by Danny Chew on 7/5/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import Lottie

class InfoView: CardView {
    private var isLoading: Bool = true {
        didSet {
            if isLoading {
                
            }
            else {
               removeLoader()
            }
        }
    }
    
    private lazy var aniView: LOTAnimationView = {
        let v = LOTAnimationView(name: "load")
        v.loopAnimation = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var label: UILabel = {
       let l = UILabel()
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = Theme.textColor()
        l.font = Theme.preferredFontWithMidSize()
        l.alpha = 0
        
        return l
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initLoader()
    }
    
    
    func initLoader() {
        self.addSubview(aniView)
        
        NSLayoutConstraint.activate([
            aniView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            aniView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            aniView.widthAnchor.constraint(equalToConstant: 180),
            aniView.heightAnchor.constraint(equalToConstant: 100)
            ])
        
        aniView.play()
        
    }
    
    func removeLoader() {
        UIView.animate(withDuration: 0.3, animations: {
            self.aniView.alpha = 0
        }) { (_) in
            self.aniView.stop()
            self.aniView.removeFromSuperview()
        }
    }
    
    func updateContentsWithWord(text: String) {
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
            ])
        
        label.text = text
        isLoading = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.label.alpha = 1
        }) {
            _ in
            // Do something
        }
    }

}
