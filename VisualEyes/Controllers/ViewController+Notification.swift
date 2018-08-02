//
//  ViewController+Notification.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/29/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
extension DiscoverLensViewController {
    func addNotificationView() {
        popUpViewController = PopUpCardViewController()
        popUpViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - 150, width: UIScreen.main.bounds.width, height: 150)
        popUpViewController.view.bounds = CGRect(x: 0, y: 0, width: popUpViewController.view.frame.width, height: popUpViewController.view.frame.height)
        popUpViewController.delegate = self
        popUpViewController.view.clipsToBounds = true
        popUpViewController.viewWillLayoutSubviews()
        self.view.addSubview(popUpViewController.view)
        
        
        NSLayoutConstraint.activate([
            popUpViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            popUpViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            popUpViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            popUpViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
            ])
        
        
        // FIXME:
        popUpViewController.setupPresentationStyle(style: .overCurrentContext)
        self.addChildViewController(popUpViewController)
        //self.present(vc, animated: false, completion: nil)
    }
    
    func addFullNotificationView() {
        if popUpViewController != nil && popUpViewController.isBeingPresented {
            popUpViewController.dismiss(animated: false, completion: nil)
            
            print("Dismiss the lousy")
        }
        popUpViewController = PopUpCardViewController()
        popUpViewController.view.frame = self.view.frame
        popUpViewController.view.bounds = CGRect(x: 0, y: 0, width: popUpViewController.view.frame.width, height: popUpViewController.view.frame.height)
        popUpViewController.delegate = self
        popUpViewController.view.clipsToBounds = true
        popUpViewController.viewWillLayoutSubviews()
        self.view.addSubview(popUpViewController.view)
        
        
        NSLayoutConstraint.activate([
            popUpViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            popUpViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            popUpViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
           popUpViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        popUpViewController.setupPresentationStyle(style: .overFullScreen)
      
        self.addChildViewController(popUpViewController)
      
        //self.present(popUpViewController, animated: false, completion: nil)
    }
    
    func addAlertView(type: MessageLottieFileName, titleText: String, secondaryText: String) {
        messageViewController = MessageViewController()
        messageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.height)
        messageViewController.view.bounds = CGRect(x: 0, y: 0, width: messageViewController.view.frame.width, height: messageViewController.view.frame.height)
        messageViewController.delegate = self
        messageViewController.view.clipsToBounds = true
        messageViewController.viewWillLayoutSubviews()
        self.view.addSubview(messageViewController.view)
        
        
        NSLayoutConstraint.activate([
           messageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
           messageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
           messageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
           messageViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 450)
            ])
        
        
        messageViewController.modalPresentationStyle = .overFullScreen
        //FIXME: What error
       // messageViewController.initMessageType(type: .Camera, titleText: "We need your camera permission!", secondaryText: "So that we can track the objects around you :)")
        messageViewController.initMessageType(type: type, titleText: titleText, secondaryText: secondaryText)
        self.addChildViewController(messageViewController)
        //self.present(vc, animated: false, completion: nil)
    }
    
}
