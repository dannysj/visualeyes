//
//  ViewController+Extension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/16/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import SceneKit
import ARKit

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
    
    func addObject(vector: SCNVector3, object: VirtualObject) {
        
        self.virtualObjectLoader.loadVirtualObject(object) { [unowned self] loadedObject in
            self.sceneView.prepare([object], completionHandler: { _ in
                DispatchQueue.main.async {
                    loadedObject.position = vector
                    self.sceneView.scene.rootNode.addChildNode(loadedObject)
                    
                }
                self.addedVirtualObject.append(loadedObject)
                print("Added one object, at position \(vector), count is \(self.addedVirtualObject.count)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    let pp = self.sceneView.projectPoint(loadedObject.position)
                    let point = CGPoint(x: CGFloat(pp.x), y: CGFloat(pp.y))
                    
                    self.addPopUpHiddenGem(pos: point )
                })
                
            })
        }
    }
    
    func loadInterests() {
        // retrieve location, objectfile, add
        for n in VirtualObject.interestPoints {
            let randomVector = self.randomPointsOnPlane()
            self.virtualObjectLoader.loadVirtualObject(n){ [unowned self] loadedInterest in
                self.sceneView.prepare([n], completionHandler: { _ in
                    DispatchQueue.main.async {
                        loadedInterest.position = randomVector
                        self.sceneView.scene.rootNode.addChildNode(loadedInterest)
                        
                    }
                    self.currentInterest.append(loadedInterest)
                    print("Added one interest, at position \(randomVector), count is \(self.currentInterest.count)")
                })
            
            }
        }
    }
    
    func movesRandomly() {
        // Takes in moving and stationary model
        // TODO:
    }
    
    func animate() {
        
    }
    
    
}

