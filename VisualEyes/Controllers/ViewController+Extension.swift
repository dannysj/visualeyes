//
//  ViewController+Extension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/16/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation

extension DiscoverLensViewController {
    
    // MARK: For AR
    func enhanceCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid pointOfView From the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    func savePosition() {
        // id, 
    }
    
    func loadObjects() {
        // retrieve location, objectfile, add
    }
    
    func movesRandomly() {
        // Takes in moving and stationary model
        // TODO:
    }
    
    func animate() {
        
    }
    
    
}

