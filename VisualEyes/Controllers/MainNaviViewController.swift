//
//  MainNaviViewController.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/24/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class MainNaviViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        hideBarsOnStart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // entry point
        let eVC = EventBookletViewController()
        present(eVC, animated: false) {
            // later
        }
    }
    
    func hideBarsOnStart() {
         self.isNavigationBarHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
