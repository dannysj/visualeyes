//
//  PollView.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import UIKit

class PollView: UIView {
    private var question: String!
    private var selection: [String] = []
    private var handler:((String)->())? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: UI
    private var height: CGFloat = 0.0
    private var width: CGFloat = 0.0
    
    private lazy var questionHexagon: Hexagon = {
        let h = Hexagon(type: .Normal, badgeSize: min(height, width) * 0.5, cornerRadius: 5)
        h.translatesAutoresizingMaskIntoConstraints = false
        h.text = question
        return h
    }()
    
    private lazy var option1Hexagon: Hexagon = {
        let h = Hexagon(type: .Normal, badgeSize: min(height, width) * 0.2, cornerRadius: 5)
        h.translatesAutoresizingMaskIntoConstraints = false
        h.text = selection[0]
        return h
    }()
    
    private lazy var option2Hexagon: Hexagon = {
        let h = Hexagon(type: .Normal, badgeSize: min(height, width) * 0.2, cornerRadius: 5)
        h.translatesAutoresizingMaskIntoConstraints = false
        h.text =  selection[1]
        return h
    }()
    
    
    convenience init(question: String, selection: [String], frame: CGRect = CGRect(), handler: @escaping (String)->()) {
        self.init(frame: frame)
        self.question = question
        self.selection = selection
        self.handler = handler
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    func updateUI() {
        self.height = self.frame.height
        self.width = self.frame.width
        
        self.addSubview(questionHexagon)
        
        NSLayoutConstraint.activate([
            questionHexagon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            questionHexagon.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        
        questionHexagon.backgroundColor = UIColor.FlatColor.Blue.aliceBlue
        option1Hexagon.backgroundColor = UIColor.FlatColor.Green.mintLight
        option2Hexagon.backgroundColor = UIColor.FlatColor.Red.grapeFruit
        
        self.addSubview(option1Hexagon)
        self.addSubview(option2Hexagon)
        NSLayoutConstraint.activate([
            option1Hexagon.trailingAnchor.constraint(equalTo: questionHexagon.centerXAnchor, constant: (width * 0.5 / 4)),
            option1Hexagon.bottomAnchor.constraint(equalTo: questionHexagon.centerYAnchor),
             option2Hexagon.leadingAnchor.constraint(equalTo: questionHexagon.centerXAnchor, constant: (width * 0.5 / 4)),
             option2Hexagon.topAnchor.constraint(equalTo: questionHexagon.centerYAnchor)
            ])
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(answerSelected(tapGR:)))
        option1Hexagon.addGestureRecognizer(tapGR)
        option2Hexagon.addGestureRecognizer(tapGR)
    }
    
    @objc func answerSelected(tapGR: UITapGestureRecognizer) {
        let loc = tapGR.location(in: self)
        if let subview = self.hitTest(loc, with: nil) {
         
            if subview == option1Hexagon {
                print("Option 1 selected")
                if let completion = handler {
                     completion(selection[0])
                }
               
            }
            if subview == option2Hexagon {
                print("Option 2 selected")
                if let completion = handler {
                    completion(selection[1])
                }
                 
            }
            
        }
        
    }
}
