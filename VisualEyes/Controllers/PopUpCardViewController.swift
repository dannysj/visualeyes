//
//  PopUpCardViewController.swift
//  TestViewController
//
//  Created by Danny Chew on 7/29/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class PopUpCardViewController: UIViewController {
    private lazy var initialHeight: CGFloat =  {
        if self.modalPresentationStyle == .overFullScreen {
            return 300.0
        }
        
        return 100.0
    }()
    private var smallViewHeight: CGFloat = 6.0
    var delegate: DismissVCDelegate!
    private lazy var initialFrame: CGRect = {
        if self.modalPresentationStyle == .overFullScreen {
            let newFrame = CGRect(x: hiddenFrame.minX, y: self.view.frame.height - initialHeight, width: hiddenFrame.width, height: hiddenFrame.height)
            
            return newFrame
        } else {
            let newFrame = CGRect(x: hiddenFrame.minX, y: self.view.frame.height  - initialHeight, width: hiddenFrame.width, height: hiddenFrame.height)
            
            return newFrame
        }
       
    }()
    
    
    private lazy var hiddenFrame: CGRect = {
          if self.modalPresentationStyle == .overFullScreen {
            let r = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: initialHeight)
            return r
          } else {
            let r = CGRect(x: 10, y: UIScreen.main.bounds.height , width: UIScreen.main.bounds.width - 20, height: initialHeight)
            return r
        }
    }()
    private lazy var cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 10.0
        v.backgroundColor = UIColor.white
        v.frame = hiddenFrame
         v.addGestureRecognizer(panCardGR)
        return v
    }()
    
    private lazy var smallView: UIView = {
       let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 3.0
        v.addGestureRecognizer(panCardGR)
        v.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        return v
    }()
    
    private lazy var panCardGR: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer(target: self, action: #selector(moveCardView(panGR:)))
        return gr
    }()

    
    private var bottomConstraint: NSLayoutConstraint!
    private var cardHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // FIXME:
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        animateToCardView()
    }
    
    func setupPresentationStyle(style: UIModalPresentationStyle) {
        self.modalPresentationStyle = style
        if style == .overFullScreen {
            setupViews()
        }
        else {
            // just a normal pop up,
            setupNormalPopUp()
        }
        
    }
    
    
    func setupNormalPopUp() {
        // Add card View
        self.view.addSubview(cardView)
        self.view.addSubview(smallView)
        cardView.addBasicShadow()
        smallView.addBasicShadow()
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            cardView.heightAnchor.constraint(equalToConstant: initialHeight)
            ])
        
        bottomConstraint = cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        bottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            smallView.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: -10),
            smallView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            smallView.widthAnchor.constraint(equalToConstant: 60),
            smallView.heightAnchor.constraint(equalToConstant: smallViewHeight),
            
            ])
        self.smallView.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.initialFrame.minY - 16, width: 60, height: self.smallViewHeight)
        // add that thing
        self.view.addGestureRecognizer(panCardGR)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(animateLeaveCardView))
        self.view.addGestureRecognizer(tapGR)
    }
    
    func setupViews() {
        
        
        // Add card View
        self.view.addSubview(cardView)
        self.view.addSubview(smallView)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: initialHeight)
            ])
        
        bottomConstraint = cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        bottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            smallView.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: -10),
            smallView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            smallView.widthAnchor.constraint(equalToConstant: 60),
            smallView.heightAnchor.constraint(equalToConstant: smallViewHeight),
          
            ])
        self.smallView.frame = CGRect(x: self.view.frame.width / 2 - 30, y: self.initialFrame.minY - 16, width: 60, height: self.smallViewHeight)
        // add that thing
        self.view.addGestureRecognizer(panCardGR)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(animateLeaveCardView))
        self.view.addGestureRecognizer(tapGR)
        
    }
    
    func animateToCardView() {
        let movementHeight: CGFloat = 4.0
        var color = UIColor.black.withAlphaComponent(0.3)
        NSLayoutConstraint.deactivate([self.bottomConstraint])
        if modalPresentationStyle == .overFullScreen {
            self.bottomConstraint = self.cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.initialHeight - movementHeight)
        }
        else {
            self.bottomConstraint = self.cardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10 - movementHeight)
            color = UIColor.clear
        }
        self.bottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = color
            self.cardView.frame = CGRect(x: self.initialFrame.minX, y: self.initialFrame.minY - movementHeight, width: self.initialFrame.width, height: self.initialFrame.height + movementHeight)
            self.smallView.frame = CGRect(x: self.smallView.frame.minX, y: self.initialFrame.minY - movementHeight - 16, width: self.smallView.frame.width, height: self.smallViewHeight)
            self.view.layoutIfNeeded()
        }) { (bool) in
            if (bool) {
                NSLayoutConstraint.deactivate([self.bottomConstraint])
                if self.modalPresentationStyle == .overFullScreen {
                    self.bottomConstraint = self.cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.initialHeight )
                }
                else {
                    self.bottomConstraint = self.cardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10 )
                }
                
                self.bottomConstraint.isActive = true
                // after animation
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                  
                    self.cardView.frame = self.initialFrame
                    self.smallView.frame = CGRect(x: self.smallView.frame.minX, y: self.initialFrame.minY - 16, width: self.smallView.frame.width, height: self.smallViewHeight)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func moveCardView(panGR: UIPanGestureRecognizer) {
       
        if panGR.state == .changed {
            let translate = panGR.translation(in: self.view)
            print(translate)
            if translate.y > 0 {
                let f = self.initialFrame
                let newY = f.minY + translate.y
                self.cardView.frame = CGRect(x: f.minX, y: newY, width: f.width, height: f.height)
                self.smallView.frame = CGRect(x: self.smallView.frame.minX, y: newY - 16, width: self.smallView.frame.width, height: smallViewHeight)
            }
            else {
                // adding heights
                
                let f = self.initialFrame
               
                let newTY = abs(translate.y)
                let newY = max(f.minY + translate.y - 20 - smallViewHeight, 10)
                var newHeight = f.height
                if modalPresentationStyle == .overFullScreen {
                    newHeight += newTY
                }
                 print("OLD Y \(f.minY) and newY is \(newY) and new height \(newHeight)")
                self.smallView.frame = CGRect(x: self.smallView.frame.minX, y: newY, width: self.smallView.frame.width, height: smallViewHeight)
                self.cardView.frame = CGRect(x: f.minX, y: newY + 16, width: f.width, height: newHeight)
                print("Card view height \(cardView.frame.height)")
            }
            
        }
        
        if panGR.state == .ended {
            let translate =  panGR.translation(in: self.view)
            if translate.y > 0 {
                animateLeaveCardView()
                print("Leaving")
            }
            else {
                
                animateToCardView()
                print("Going back")
            }
        }
    }
    
    @objc func animateLeaveCardView() {
        NSLayoutConstraint.deactivate([self.bottomConstraint])
        self.bottomConstraint = self.cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 26)
        self.bottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = UIColor.clear
            self.cardView.frame = self.hiddenFrame
            self.smallView.frame = CGRect(x: self.smallView.frame.minX, y: self.hiddenFrame.minY - 16, width: self.smallView.frame.width, height: self.smallViewHeight)
            self.view.layoutIfNeeded()
        }) {
            (bool) in
            self.delegate.dismissNotificationController()
        //    self.dismiss(animated: false, completion: nil)
        }
    }
    
    
}

extension PopUpCardViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (self.modalPresentationStyle == .overFullScreen) {
            return UIStatusBarStyle.lightContent
        }
        return UIStatusBarStyle.default
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}
