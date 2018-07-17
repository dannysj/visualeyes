//
//  SceneKit-Extentsion.swift
//  Test3DObjectEdit
//
//  Created by Danny Chew on 7/3/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import SceneKit

func round(val: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: round(val.x), y: round(val.y), z: round(val.z))
}


func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

func * (left: SCNVector3, right: SCNVector3) -> CGFloat {
    return CGFloat(left.x * right.x + left.y * right.y + left.z * right.z)
}


func * (left: SCNVector3, right: CGFloat) -> SCNVector3 {
    return SCNVector3(x: left.x * Float(right), y: left.y * Float(right), z: left.z * Float(right))
}

func * (left: CGFloat, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: Float(left) * right.x, y: Float(left) * right.y, z: Float(left) * right.z)
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
