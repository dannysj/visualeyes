//
//  String+HeightExtension.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/31/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func heightForString(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.height)
    }
}
