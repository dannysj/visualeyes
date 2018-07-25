//
//  ViewController+VirtualObjectExtension.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/25/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import ARKit

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
