//
//  ViewController+Extension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/16/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import SceneKit

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
    
    func addObject(vector: SCNVector3) {
        let object = self.availableObjects[random(min: 0, max: self.availableObjects.count - 1)]
        self.virtualObjectLoader.loadVirtualObject(object) { [unowned self] loadedObject in
            self.sceneView.prepare([object], completionHandler: { _ in
                DispatchQueue.main.async {
                    loadedObject.position = vector
                    self.sceneView.scene.rootNode.addChildNode(loadedObject)
                    
                }
                self.addedVirtualObject.append(loadedObject)
                print("Added one object, at position \(vector), count is \(self.addedVirtualObject.count)")
            })
        }
    }
    
    func loadObjects(x: Float, y: Float, obj: String) {
        // retrieve location, objectfile, add
        
    }
    
    func movesRandomly() {
        // Takes in moving and stationary model
        // TODO:
    }
    
    func animate() {
        
    }
    
    
}

