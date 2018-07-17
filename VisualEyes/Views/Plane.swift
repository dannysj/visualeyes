//
//  Plane.swift
//  ARTest
//
//  Created by Danny Chew on 7/3/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    var anchor: ARPlaneAnchor!
    var isHiddenPlane: Bool!
    var planeHeight: CGFloat = 0.01
    var planeGeometry: SCNBox!
    var length: Float = 0
    var width: Float = 0
    
    init(withAnchor anchor: ARPlaneAnchor, isHidden: Bool) {
        super.init()
        self.anchor = anchor
        self.isHiddenPlane = isHidden
        self.length = anchor.extent.x
        self.width = anchor.extent.z
        
        configurePlane()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePlane() {
        self.planeGeometry = SCNBox(width: CGFloat(width), height: planeHeight, length: CGFloat(length), chamferRadius: 0)
        self.planeGeometry.firstMaterial?.diffuse.contents = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x,0,anchor.center.z)
        planeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
        // vertical?
        //planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
        self.addChildNode(planeNode)
        
    }
    
    func update(anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.length = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        if let node = self.childNodes.first {
            node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
            
        }
    }
}
