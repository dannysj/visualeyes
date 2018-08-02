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
        popUpViewController.view.removeFromSuperview()
        
       // self.navigationController?.popViewController(animated: false)
        popUpViewController.removeFromParentViewController()
    }

}
