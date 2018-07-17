//
//  Theme.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/26/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    static func barColor() -> UIColor {
        return UIColor(hex: 0x853E8C)
    }
    
    static func barSecondaryColor() -> UIColor {
        return UIColor(hex: 0x631E7C)
    }
    
    
    static func scoreFont() ->UIFont {
        return UIFont(name: "Menlo-Regular", size: 25)!
    }
    
    static func codeFont() ->UIFont {
        return UIFont(name: "Menlo-Regular", size: 13)!
    }

    static func codeLargerFont() ->UIFont {
        return UIFont(name: "Menlo-Regular", size: 17)!
    }

    static func codeTitleFont() ->UIFont {
        return UIFont(name: "Menlo-Regular", size: 20)!
    }
    
    static func lineColor() -> UIColor {
        return UIColor.white
    }
    
    static func backgroundColor() -> UIColor {
        return UIColor(hex: 0x17264B)
    }
    
    // MARK: - font
    
    static func textColor() -> UIColor {
        return UIColor.FlatColor.Blue.midnightBlue
    }
    
    static func preferredFontWithMidSize() ->UIFont {
        return UIFont(name: "Avenir-Medium", size: 15)!
    }
    static func preferredFontWithTitleSize() ->UIFont {
        return UIFont(name: "Avenir-Medium", size: 18)!
    }
    
    static func preferredFontNameLabel() ->UIFont {
        return UIFont(name: "Avenir-Medium", size: 24)!
    }
    
    static func preferredTextTitleFont() -> UIFont {
        return UIFont(name: "Avenir-Heavy", size: 15 )!
    }
    static func preferredFontForSectionHeader() -> UIFont {
        return UIFont(name: "Avenir-Heavy", size: 24)!
    }
    
    static func preferredFontWithSmallSize() ->UIFont {
        return UIFont(name: "Avenir-Medium", size: 12)!
    }
    
    static func preferredFontWithSmallTitleSize() ->UIFont {
        return UIFont(name: "Avenir-Heavy", size: 12)!
    }
    
    static func preferredProfileImageWidth() -> CGFloat {
        return UIScreen.main.bounds.height / 4.0
    }
    
    static func SmallMediumProfileImageWidth() -> CGFloat {
        return UIScreen.main.bounds.width / 4.0
    }
}
