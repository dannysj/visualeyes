//
//  MessageViewController.swift
//  testErrorVC
//
//  Created by Danny Chew on 7/30/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import Lottie

enum MessageLottieFileName {
    case Camera
    case NoConnection
    case Notification
    case Location
    case NotFound
}

protocol DismissVCDelegate {
    func dismissNotificationController()
}

class MessageViewController: UIViewController {
    private var messageType: MessageLottieFileName!
    private var lottieHeight: CGFloat = 300.0
    private var lottieWidth: CGFloat = 300.0
    private var buttonLength: CGFloat = 120.0
    private var buttonHeight: CGFloat = 40.0
    var delegate: DismissVCDelegate!
    private lazy var lottieName: String = {
        switch messageType {
        case .Camera?:
            
            return "camera"
            
        case .NoConnection?:
            lottieHeight = 200
            lottieWidth = 200
           
            return "no_connection"
        case .Location?:
            lottieHeight = 200
            lottieWidth = 200
            return "round"
        case .Notification?:
            return "notification"
        case .NotFound?:
            lottieWidth = 170
            return "not_found"
        default:
            return ""
        }
    }()
    private lazy var lottieView: LOTAnimationView = {
        let m = LOTAnimationView(name: lottieName)
        m.translatesAutoresizingMaskIntoConstraints = false
        m.loopAnimation = true
        m.autoReverseAnimation = false
        return m;
    }()
    private var titleText: String = "Test Error"
    private var secondaryText: String = "Test Lorem Ipsum bla bla balb labab"
    private lazy var cardView: UIView = {
       let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        v.backgroundColor = UIColor.white
        return v
    }()
    
    private lazy var initialHeight: CGFloat = {
       return self.view.frame.height * 0.7
        
    }()
    
    private var primaryColor: UIColor = UIColor.FlatColor.Green.mintDark
    private var secondaryColor: UIColor = UIColor.gray
    
    private lazy var initialFrame: CGRect = {
        if self.modalPresentationStyle == .overFullScreen {
            let newFrame = CGRect(x: hiddenFrame.minX, y: self.view.frame.height - initialHeight - 30, width: hiddenFrame.width, height: hiddenFrame.height)
            
            return newFrame
        } else {
            let newFrame = CGRect(x: hiddenFrame.minX, y: self.view.frame.height  - initialHeight - 30, width: hiddenFrame.width, height: hiddenFrame.height)
            
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
     private var bottomConstraint: NSLayoutConstraint!
    private lazy var primaryButton: UIView = {
       let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        v.backgroundColor = primaryColor
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(primaryTapped))
        v.addGestureRecognizer(tapGR)
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(l)
        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 15),
            l.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -15),
            l.centerYAnchor.constraint(equalTo: v.centerYAnchor)
            ])
        
        l.font = Theme.preferredFontWithMidSize()
        l.textColor = UIColor.white
        l.textAlignment = .center
        l.text = "Got it!"
        
        return v
    }()
    
    private lazy var secondaryButton: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        v.backgroundColor = secondaryColor
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(secondaryTapped))
        v.addGestureRecognizer(tapGR)
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(l)
        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 15),
            l.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -15),
            l.centerYAnchor.constraint(equalTo: v.centerYAnchor)
            ])
        l.textAlignment = .center
        l.font = Theme.preferredFontWithMidSize()
        l.textColor = UIColor.white
        l.text = "Don't care"
        
        
        return v
    }()
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .left
        return l
    }()
    
    func initMessageType(type: MessageLottieFileName, titleText: String, secondaryText:String) {
        self.messageType = type
        self.titleText = titleText
        self.secondaryText = secondaryText
        setupView()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateToCardView()
        self.lottieView.play()
    }
    
    func setupView() {
        self.view.addSubview(cardView)
       
       // cardView.addBasicShadow()
       
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            cardView.heightAnchor.constraint(equalToConstant: initialHeight)
            ])
        
        bottomConstraint = cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        bottomConstraint.isActive = true
        
        cardView.addSubview(lottieView)
        NSLayoutConstraint.activate([
            lottieView.widthAnchor.constraint(equalToConstant: lottieWidth),
            lottieView.heightAnchor.constraint(equalToConstant: lottieHeight),
            lottieView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -lottieHeight / 3)
            ])
        
        cardView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cardView.leadingAnchor,constant: 30),
            label.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30),
            label.topAnchor.constraint(equalTo: lottieView.bottomAnchor, constant: 30)
            ])
        let attributedText = NSMutableAttributedString(string: "\(titleText)\n", attributes: [
            NSAttributedString.Key.font: Theme.preferredFontWithTitleSize(),
            NSAttributedString.Key.foregroundColor: UIColor.FlatColor.Blue.midnightBlue
            ])
        
        let secondAttributedText = NSAttributedString(string: "\(secondaryText)\n", attributes: [
            NSAttributedString.Key.font: Theme.preferredFontWithMidSize(),
            NSAttributedString.Key.foregroundColor: UIColor.FlatColor.Blue.midnightBlue
            ])
        attributedText.append(secondAttributedText)
        
        label.attributedText = attributedText
        
        cardView.addSubview(primaryButton)
        NSLayoutConstraint.activate([
            primaryButton.leadingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: 15),
            primaryButton.widthAnchor.constraint(equalToConstant: buttonLength),
            primaryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            primaryButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -15)
            ])
        cardView.addSubview(secondaryButton)
        NSLayoutConstraint.activate([
            secondaryButton.trailingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: -15),
            secondaryButton.widthAnchor.constraint(equalToConstant: buttonLength),
            secondaryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            secondaryButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -15)
            ])
        
    }
    
    // For Animation
    func animateToCardView() {
        let movementHeight: CGFloat = 4.0
        var color = UIColor.black.withAlphaComponent(0.3)
        NSLayoutConstraint.deactivate([self.bottomConstraint])
        if modalPresentationStyle == .overFullScreen {
            self.bottomConstraint = self.cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.initialHeight - 30 - movementHeight)
        }
        else {
            self.bottomConstraint = self.cardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10 - movementHeight - 30)
            color = UIColor.clear
        }
        self.bottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = color
            self.cardView.frame = CGRect(x: self.initialFrame.minX, y: self.initialFrame.minY - movementHeight, width: self.initialFrame.width, height: self.initialFrame.height + movementHeight)
           
            self.view.layoutIfNeeded()
        }) { (bool) in
            if (bool) {
                NSLayoutConstraint.deactivate([self.bottomConstraint])
                if self.modalPresentationStyle == .overFullScreen {
                    self.bottomConstraint = self.cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.initialHeight - 30 )
                }
                else {
                    self.bottomConstraint = self.cardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10 - 30)
                }
                
                self.bottomConstraint.isActive = true
                // after animation
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.cardView.frame = self.initialFrame
              
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
   
    
    @objc func animateLeaveCardView() {
        NSLayoutConstraint.deactivate([self.bottomConstraint])
        self.bottomConstraint = self.cardView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 26)
        self.bottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = UIColor.clear
            self.cardView.frame = self.hiddenFrame
           
            self.view.layoutIfNeeded()
        }) {
            (bool) in
            self.lottieView.pause()
            print("Attempt to call dismiss")
            self.lottieView.removeFromSuperview()
            self.cardView.removeFromSuperview()
            self.delegate.dismissNotificationController()
            
        }
    }
    
    // MARK: For gesture recognizers
    @objc func primaryTapped() {
        animateLeaveCardView()
    }
    
    @objc func secondaryTapped() {
        
    }

}
