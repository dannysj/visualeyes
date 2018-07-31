//
//  Building.swift
//  test3dmap
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import SceneKit
class Building: SCNNode {
    var baseShapeCoordinates: [Coordinate] = []
    var baseShapeOutline: UIBezierPath! {
        didSet {
            updateGeometry()
        }
    }
    var autoLighting: Bool = true
    
    private lazy var shape: SCNShape = {
        let s = SCNShape(path: baseShapeOutline, extrusionDepth: 40)
        s.chamferRadius = 3.0
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.FlatColor.White.darkLightGray
        if autoLighting {
            material.lightingModel = .physicallyBased
        }
        else {
            material.lightingModel = .phong
        }
        s.firstMaterial = material
        
        // SCN Level Of Detail
       // s.levelsOfDetail = [SCNLevelOfDetail(geometry: s, worldSpaceDistance: 3)]
        return s
    } ()
    
    override init() {
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(coordinates: [Coordinate], autoLighting: Bool = true) {
        self.init()
        self.baseShapeCoordinates = coordinates
        self.autoLighting = autoLighting
        drawBezier()
    }
    
    func updateGeometry() {
        self.geometry = shape
        self.eulerAngles.x = Float.pi / 2
       
        print("New building created")
    }
    
    func drawBezier() {
        
        if let first = baseShapeCoordinates.first {
            let path = UIBezierPath()
            let firstPoint = first.cgPoint()
            //FIXME: COunter to skip first
            var counter = 0
            path.move(to: CGPoint(x:0,y:0))
            //path.move(to: firstPoint)
            for i in baseShapeCoordinates {
                if counter == 0 {
                    counter += 1
                    continue
                }
                let pointToAdd = i.cgPoint() - firstPoint
               path.addLine(to: pointToAdd)
               // path.addLine(to: i.cgPoint())
            }
            path.close()
            baseShapeOutline = path
        }
     
    }
    

}
