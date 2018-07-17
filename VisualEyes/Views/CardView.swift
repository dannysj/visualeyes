//
//  CardView.swift
//  Secrets
//
//  Created by Danny Chew on 7/5/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class CardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
