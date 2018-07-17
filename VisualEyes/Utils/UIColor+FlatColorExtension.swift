//
//  UIColor+FlatColorExtension.swift
//  GoalTest
//
//  Created by Danny Chew on 4/1/17.
//  Copyright © 2017 Danny Chew. All rights reserved.
//

import Foundation
import UIKit

// MARK: Extension for more colors

//Color Pallete: White
//               Turquoise : rgb(70, 221, 180)  - emerald 46, 204, 113	- rgb(22, 160, 133)
//               Light Pink : rgb(250, 171, 172)
//               Portage : rgb(121, 136, 232)
//               Alice Blue : rgb(243, 244, 245)
//               Chardonnay : rgb(255, 190, 107)
//               Midnight Blue: rgb(44, 62, 80)
//               Orange: rgb(255, 193, 7)

extension UIColor {
    
    //convenience init for taking 0 ~ 255 values
    convenience init(red: Int, green: Int, blue: Int) {
        
            assert(red >= 0 && red <= 255, "Invalid red component")
            assert(green >= 0 && green <= 255, "Invalid green component")
            assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
            self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    //convenience init for reading hex color
    
    convenience init(hex:Int) {
        //format: 0x rr gg bb
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    
    //MARK : Structure for some FlatColor
    
    struct FlatColor {
        struct Red {
            static let lightPink = UIColor(hex: 0xFAABAC)
            static let alizarinCrimson = UIColor(hex: 0xE32636)
            static let monza = UIColor(hex: 0xC30017)
            static let brightCoral = UIColor(hex: 0xF53240)
            static let grapeFruit = UIColor(hex: 0xED5565)
            static let grapeFruitDark = UIColor(hex: 0xDA4453)
        }
        struct Green {
            static let mountainMeadow = UIColor(hex: 0x16A085)
            static let turquoise = UIColor(hex: 0x46ddb4)
            static let shamrock = UIColor(hex: 0x2ECC71)
            static let emerald = UIColor(hex: 0x3FC380)
            static let aquamarine = UIColor(hex: 0x02C8A7)
            static let mintLight = UIColor(hex: 0x48CFAD)
            static let mintDark = UIColor(hex: 0x37BC9B)
        }
        
        struct Blue {
            static let portage = UIColor(hex: 0x7988e8)
            static let aliceBlue = UIColor(hex: 0xf3f4f5)
            static let midnightBlue = UIColor(hex: 0x2c3e50)
            static let riptide = UIColor(hex: 0x80E8B9)
            static let sky = UIColor(hex: 0x7CDBD5)
            static let aqua = UIColor(hex: 0x4fC1e9)
            static let darkerAqua = UIColor(hex: 0x3BAFDA)
            static let blueJeans = UIColor(hex: 0x5D9CEC)
            static let darkerBlueJeans = UIColor(hex: 0x4A89DC)
        }
        struct Orange {
            static let chardonnay = UIColor(hex: 0xffbe6b)
            static let vividYellow = UIColor(hex: 0xffc107)
            static let capeHoney = UIColor(hex: 0xFCE7A7)
            static let golden = UIColor(hex: 0xF9BE02)
        }
        struct Purple {
            static let lightWiseria = UIColor(hex: 0xB48FD9)
            static let amethyst = UIColor(hex: 0x9966cc)
            static let lavanderLight = UIColor(hex: 0xAC92EC)
            static let lavanderDark = UIColor(hex: 0x967ADC)
        }
        
        struct Yellow {
            static let sunflowerLight = UIColor(hex: 0xFFCE54)
            static let sunflowerDark = UIColor(hex: 0xF6BB42)
        }
        
        struct White {
            static let clouds = UIColor(hex: 0xecf0f1)
            static let lightGray = UIColor(hex: 0xf5f7fa)
            static let darkLightGray = UIColor(hex: 0xE6e9ed)
            static let mediumGray = UIColor(hex: 0xCCD1D9)
            static let darkMediumGray = UIColor(hex: 0xAAB2Bd)
        }
    }
}

