//
//  Votebar.swift
//  VoteBarTest
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class Votebar: UIView {
    var voted: Bool = false {
        didSet {
            updateStatus()
        }
    }
    var selection: [String] = []
    var statistic: [Double] = []
    var votedResultReveal: Bool = false
    // FOR UI Purpose
    var color: [UIColor] = []
    var progressBarHeight: CGFloat = 15.0
    var progressBarMaxWidth: CGFloat = 0.0
    var pad: CGFloat = 0.0
    private lazy var hiddenProgressBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = color[2]
        v.layer.cornerRadius = progressBarHeight / 3
        return v
    }()
    
    private lazy var leftProgressBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = color[0]
   //     v.bounds = CGRect(x: 0, y: 0, width: progressBarMaxWidth / 2, height: progressBarHeight)
       
        v.alpha = 0
        return v
    }()
    
    private lazy var rightProgressBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = color[1]
//v.bounds = CGRect(x: 0, y: 0, width: progressBarMaxWidth / 2, height: progressBarHeight)
        
        v.alpha = 0
        return v
    }()
    
    //Labels
    private lazy var labelForHidden: UILabel = {
       let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Theme.preferredFontWithMidSize()
        l.text = "Voting Result will be revealed after voting."
        l.textAlignment = .center
        
        return l
    }()
    
    private lazy var labelForOption1: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Theme.preferredFontWithMidSize()
        l.alpha = 0
        l.textAlignment = .left
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var labelForOption2: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Theme.preferredFontWithMidSize()
        l.alpha = 0
        l.textAlignment = .right
        l.numberOfLines = 0
        return l
    }()
    
    var option1WidthConstraint: NSLayoutConstraint!
    var option2WidthConstraint: NSLayoutConstraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, selection: [String], color:[UIColor], voted: Bool) {
        self.init(frame: frame)
        self.selection = selection
        self.voted = voted
        self.color = color
        self.progressBarMaxWidth = frame.width * 0.9
       self.pad = (frame.width - progressBarMaxWidth) / 2.0
        if voted {
            
            revealProgressBar()
        }
        else {
            revealHiddenProgressBar()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         print("Subviews called")
    }
    
    func updateVoteStatus(voted: Bool, statistic: [Double]) {
        self.statistic = statistic
        self.voted = voted
    }
    
    func updateStatus() {
        guard voted else {return}
        revealProgressBar()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
          self.hiddenProgressBar.alpha = 0
          self.labelForHidden.alpha = 0
          self.leftProgressBar.alpha = 1
          self.rightProgressBar.alpha = 1
            // for nslc
             self.layoutIfNeeded()
        }) { (_) in
            self.hiddenProgressBar.removeFromSuperview()
            self.labelForHidden.removeFromSuperview()
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.labelForOption2.alpha = 1
                self.labelForOption1.alpha = 1
            }, completion: nil)
            
        }
    }
    
    func revealHiddenProgressBar() {
        hiddenProgressBar.bounds = CGRect(x: 0, y: 0, width: progressBarMaxWidth, height: progressBarHeight)
        self.addSubview(hiddenProgressBar)
        NSLayoutConstraint.activate([
           hiddenProgressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
           hiddenProgressBar.centerXAnchor.constraint(equalTo: self.centerXAnchor),
           hiddenProgressBar.widthAnchor.constraint(equalToConstant: progressBarMaxWidth),
           hiddenProgressBar.heightAnchor.constraint(equalToConstant: progressBarHeight),
        ])
        
        self.addSubview(labelForHidden)
        NSLayoutConstraint.activate([
            labelForHidden.leadingAnchor.constraint(equalTo: hiddenProgressBar.leadingAnchor),
            labelForHidden.trailingAnchor.constraint(equalTo: hiddenProgressBar.trailingAnchor),
            labelForHidden.topAnchor.constraint(equalTo: hiddenProgressBar.bottomAnchor, constant: 15)
            
            ])
        
        
    }
    
    func revealProgressBar() {
        //FIXME:
        guard !votedResultReveal else {return}
        leftProgressBar.frame = CGRect(x: pad, y: 15, width: CGFloat(statistic[0]) * progressBarMaxWidth, height: progressBarHeight)
         leftProgressBar.roundCorners([.topLeft, .bottomLeft], radius: progressBarHeight / 4)
        rightProgressBar.frame = CGRect(x: pad + CGFloat(statistic[0]) * progressBarMaxWidth, y: 15, width: CGFloat(statistic[1]) * progressBarMaxWidth, height: progressBarHeight)
        rightProgressBar.roundCorners([.topRight, .bottomRight], radius:progressBarHeight / 4)
        self.addSubview(leftProgressBar)
        self.addSubview(rightProgressBar)
       
        print("pad \(pad)")
        NSLayoutConstraint.activate([
            leftProgressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            leftProgressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: pad),
            leftProgressBar.heightAnchor.constraint(equalToConstant: progressBarHeight),
            
            rightProgressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            rightProgressBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -pad),
            rightProgressBar.heightAnchor.constraint(equalToConstant: progressBarHeight),
            
            
            ])
        
        option1WidthConstraint = leftProgressBar.widthAnchor.constraint(equalToConstant:  CGFloat(statistic[0]) * progressBarMaxWidth)
        option2WidthConstraint = rightProgressBar.widthAnchor.constraint(equalToConstant:  CGFloat(statistic[1]) * progressBarMaxWidth)
        
        option1WidthConstraint.isActive = true
        option2WidthConstraint.isActive = true
        
        self.addSubview(labelForOption1)
        self.addSubview(labelForOption2)
        
        NSLayoutConstraint.activate([
            labelForOption1.topAnchor.constraint(equalTo: leftProgressBar.bottomAnchor, constant: 15),
            labelForOption2.topAnchor.constraint(equalTo: rightProgressBar.bottomAnchor, constant: 15),
            labelForOption1.leadingAnchor.constraint(equalTo: leftProgressBar.leadingAnchor),
            labelForOption2.trailingAnchor.constraint(equalTo: rightProgressBar.trailingAnchor)
            
            ])
        
        let attributedText = NSMutableAttributedString(string: "\(statistic[0] * 100)%", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithTitleSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.Blue.midnightBlue
            ])
        
        let secondAttributedText = NSAttributedString(string: "\n\(selection[0])", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithMidSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.White.darkMediumGray
            ])
        attributedText.append(secondAttributedText)
        
        let attributedText2 = NSMutableAttributedString(string: "\(statistic[1] * 100)%", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithTitleSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.Blue.midnightBlue
            ])
        
        let secondAttributedText2 = NSAttributedString(string: "\n\(selection[1])", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithMidSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.White.darkMediumGray
            ])
        attributedText2.append(secondAttributedText2)
        
        labelForOption1.attributedText = attributedText
        labelForOption2.attributedText = attributedText2
        // done
        votedResultReveal = true
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
