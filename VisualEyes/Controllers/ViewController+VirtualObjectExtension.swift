//
//  ViewController+VirtualObjectExtension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/25/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import ARKit
extension DiscoverLensViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1: For Plane detection
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        /*
         // 2
         let width = CGFloat(planeAnchor.extent.x)
         let height = CGFloat(planeAnchor.extent.z)
         let plane = SCNPlane(width: width, height: height)
         
         // 3
         plane.materials.first?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
         
         // 4
         let planeNode = SCNNode(geometry: plane)
         
         // 5
         let x = CGFloat(planeAnchor.center.x)
         let y = CGFloat(planeAnchor.center.y)
         let z = CGFloat(planeAnchor.center.z)
         planeNode.position = SCNVector3(x,y,z)
         planeNode.eulerAngles.x = -.pi / 2
         
         // 6
         node.addChildNode(planeNode)
         
         // 7
         let plane = Plane(withAnchor: planeAnchor, isHidden: false)
         node.addChildNode(plane)
         
         if (planeAnchor.alignment == .vertical) {
         // 8 We send updates
         print("Vertical found")
         // stopTrack = true
         
         // if mural is found, don't have to send updates
         guard !foundMural else { return }
         
         let uiImage = sceneView.snapshot()
         
         UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
         
         let binaryImageData = base64EncodeImage(uiImage)
         createRequest(with: binaryImageData)
         }
         */
        // only care about detected planes (i.e. `ARPlaneAnchor`s)
        
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
        stopTrack = true
        
        if (planeAnchor.alignment == .vertical) {
         //   let uiImage = sceneView.snapshot()
            
         //   UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
          //  let binaryImageData = connection.base64EncodeImage(uiImage)
         //   connection.createRequest(with: binaryImageData, at: "information-analyze", location: "12,12,12", uid: 12, handler: handleInformation)
        }
        
        guard self.currentInterest.count == 0 else {return}
        self.loadInterests()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        /*guard let planeAnchor = anchor as?  ARPlaneAnchor,
         let planeNode = node.childNodes.first,
         let plane = planeNode.geometry as? SCNPlane
         else { return }
         
         // 2
         let width = CGFloat(planeAnchor.extent.x)
         let height = CGFloat(planeAnchor.extent.z)
         plane.width = width
         plane.height = height
         
         // 3
         let x = CGFloat(planeAnchor.center.x)
         let y = CGFloat(planeAnchor.center.y)
         let z = CGFloat(planeAnchor.center.z)
         planeNode.position = SCNVector3(x, y, z)
         
         /*
         平面尺寸可能会变大,或者把几个小平面合并为一个大平面.合并时,`ARSCNView`自动删除同一个平面上的相应节点,然后调用该方法来更新保留的另一个平面的尺寸.(经过测试,合并时,保留第一个检测到的平面和对应节点)
         */
         plane.width = CGFloat(planeAnchor.extent.x)
         plane.height = CGFloat(planeAnchor.extent.z)
         
         // if found mural, we stop sending updates
         guard !foundMural else { return }
         
         if (planeAnchor.alignment == .vertical) {
         // 8 We send updates
         print("Vertical updated")
         popUpInfo(text: "Trigger directly")
         //let binaryImageData = base64EncodeImage(pickedImage)
         //createRequest(with: binaryImageData)
         }*/
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //updateQueue.async {
            node.enumerateChildNodes { (childNode, _) in
                if let n = childNode as? VirtualObject {
                    if !self.addedVirtualObject.contains(n) {
                        n.removeFromParentNode()
                    }
                } else {
                    childNode.removeFromParentNode()
                }
                
          //  }
        }
  
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
        DispatchQueue.global(qos: .default).async {
            // assuming
            let ranNum = random(min: 0, max: 100) == 1
            if (ranNum) {
                print("Added some items")
                let vector = self.randomPointsOnPlane()
                self.addObject(vector: vector, object: VirtualObject.availableObjects[random(min: 0, max: self.availableObjects.count - 1)])
            }
        }
        
        
    }
    
    // MARK: - ARSessionObserver
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        print("Session失败: \(error.localizedDescription)")
        resetTracking()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        print("Session被打断")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        print("Session打断结束")
        resetTracking()
    }
}

extension ARSCNView {
    /// Hit tests against the `sceneView` to find an object at the provided point.
    func virtualObject(at point: CGPoint) -> VirtualObject? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.compactMap { result in
            return VirtualObject.existingObjectContainingNode(result.node)
            }.first
    }
}

/*
 balloonNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
 balloonNode.physicsBody?.isAffectedByGravity = false
 balloonNode.physicsBody?.damping = 0.0
 // Randomize direction for horizontal movement
 let negativeHorizontal = Int(arc4random_uniform(2)) == 0 ? -1 : 1
 let xCord = 10 + Float(arc4random_uniform(50))
 let yCord = 20 + Float(arc4random_uniform(100))
 balloonNode.physicsBody?.applyForce(SCNVector3(Float(negativeHorizontal)*xCord,yCord,0), asImpulse: false)
 
 */
