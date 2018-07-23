//
//  UIImage+Base64.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/20/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import UIKit
//
// Convert String to base64
//
func convertImageToBase64(image: UIImage) -> String {
    let imageData = UIImagePNGRepresentation(image)!
    return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
}

//
// Convert base64 to String
//
func convertBase64ToImage(imageString: String) -> UIImage? {
    let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
    return UIImage(data: imageData)
}

func convertBase64ToImage(imageData: Data) -> UIImage? {
    return UIImage(data: imageData)
}
