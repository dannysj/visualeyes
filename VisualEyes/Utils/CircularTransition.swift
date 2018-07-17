//
//  CircularTransition.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/31/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

enum CircularTransitionMode {
    case present
    case dismiss
    case pop
}

class CircularTransition: NSObject {
    var circle: UIView!
    //init color
    var color: UIColor = UIColor.white
    var startPoint: CGPoint = .zero {
        didSet {
            circle.center = startPoint
        }
    }
    var mode: CircularTransitionMode = .present
    var duration: TimeInterval = 0.4
}

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let cView = transitionContext.containerView
        if mode == .present {
            if let presentView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                presentView.alpha = 0
                let presentViewCenter = presentView.center
                let presentViewSize = presentView.frame.size
                
                circle = UIView()
                // circle's frame
                let xLength = fmax(startPoint.x, presentViewSize.width - startPoint.x)
                let yLength = fmax(startPoint.y, presentViewSize.width - startPoint.y)
                
                let offset = sqrt(pow(xLength, 2) + pow(yLength, yLength)) * 2
                let size = CGSize(width: offset, height: offset)
                
                circle.frame = CGRect(origin: .zero, size: size)
                
                circle.backgroundColor = color
                circle.layer.cornerRadius = size.height / 2.0
                circle.center = startPoint
                circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                cView.addSubview(circle)
                
                // presenting view
                presentView.center = startPoint
                presentView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                cView.addSubview(presentView)
                
                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = .identity
                    presentView.transform = .identity
                    presentView.alpha = 1
                    presentView.center = presentViewCenter
                }) { (bool) in
                    transitionContext.completeTransition(bool)
                }
                
                
            }
        } else {
            let key: UITransitionContextViewKey = (mode == .pop) ? .to : .from
            if let returnView = transitionContext.view(forKey: key) {
                
                let returnViewCenter = returnView.center
                let returnViewSize = returnView.frame.size
                
                circle = UIView()
                // circle's frame
                let xLength = fmax(startPoint.x, returnViewSize.width - startPoint.x)
                let yLength = fmax(startPoint.y, returnViewSize.width - startPoint.y)
                
                let offset = sqrt(pow(xLength, 2) + pow(yLength, yLength)) * 2
                let size = CGSize(width: offset, height: offset)
                
                circle.frame = CGRect(origin: .zero, size: size)
                
                circle.layer.cornerRadius = size.height / 2.0
                circle.center = startPoint
                
                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = .identity
                    returnView.transform = .identity
                    returnView.alpha = 0
                    returnView.center = self.startPoint
                    
                    if self.mode == .pop {     
                        cView.insertSubview(returnView, belowSubview: returnView)
                        cView.insertSubview( self.circle, belowSubview: returnView)
                    }
                    
                }) { (bool) in
                    returnView.center = returnViewCenter
                    returnView.removeFromSuperview()
                    
                    self.circle.removeFromSuperview()
                    transitionContext.completeTransition(bool)
                }

            }
        }
    }
    
    
}
