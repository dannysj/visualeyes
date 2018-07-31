//
//  ViewController+Dismiss.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/31/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
extension DiscoverLensViewController: DismissVCDelegate {
    func dismissNotificationController() {
        print("Dismiss is called, \(self.children.count)")
        for v in self.children {
            v.view.removeFromSuperview()
            v.removeFromParent()
            
            
        }
    }

}
