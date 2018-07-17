//
//  BotFadeTransition.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/31/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit


class BotFadeTransition: NSObject {
    var transitionView: UIView!
    //init color
    var color: UIColor = Theme.backgroundColor()
    var duration: TimeInterval = 0.4
    var delay: TimeInterval = 2
    lazy var bot: HexagonBot = {
        let b = HexagonBot()
        b.bounds = CGRect(x: 0, y: 0, width: 40, height: 50)
        //b.translatesAutoresizingMaskIntoConstraints = false
      
        return b
    }()
}

extension BotFadeTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let cView = transitionContext.containerView
        
        if let presentView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            presentView.alpha = 0
            let fromVC = transitionContext.viewController(forKey: .from)
 
            transitionView = UIView()
            transitionView.frame = presentView.frame
            cView.addSubview(transitionView)
            transitionView.alpha = 0
            iniTransitionView()
            
            // presenting view
            presentView.alpha = 0
            cView.addSubview(presentView)
            
            UIView.animate(withDuration: duration, animations: {
                self.transitionView.alpha = 1
                
                
            }) { (bool) in
                fromVC?.view.alpha = 0
                transitionContext.completeTransition(bool)
                fromVC?.view.removeFromSuperview()
                UIView.animate(withDuration: self.duration, delay: self.delay, options: [], animations: {
                    presentView.alpha = 1
                    self.transitionView.alpha = 0
                }, completion: { (bool) in
                    self.transitionView.removeFromSuperview()
                    transitionContext.completeTransition(bool)
                })
            }
            
            
        }
        
    }
    
    func iniTransitionView() {
        print("Called")
        transitionView.addSubview(bot)
        transitionView.backgroundColor = Theme.backgroundColor()
        bot.center = transitionView.center
        let centerY: CGFloat = bot.center.y - 100
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: [.repeat, .curveEaseInOut, .autoreverse], animations: {
            self.bot.center = CGPoint(x: self.bot.center.x, y: centerY)
        }) { (_) in
            
        }

    }
    
    
}
