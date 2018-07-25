//
//  BaseMap.swift
//  test3dmap
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import SceneKit
class BaseMap: SCNNode {
    var mapImage: UIImage! {
        didSet {
            print("Called")
            displayMap()
        }
    }
    
    var length: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 30.0
    var buildings: [Building] = []
    var buildingCoordinates: [BuildingCoordinates] = []
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(image: UIImage, length: Float, width: Float, buildingCoordinates: [BuildingCoordinates]) {
        self.init()
        self.length = CGFloat(length)
        self.width = CGFloat(width)
        self.mapImage = image
        self.buildingCoordinates = buildingCoordinates
        if (buildingCoordinates.count == 0) {
            print("GG No building")
        }
        print("Called")
        displayMap()
        
        displayBuildings()
    }
    
    func displayMap() {
        let mapMaterial = SCNMaterial()
        mapMaterial.isDoubleSided = false
        mapMaterial.diffuse.contents = mapImage
       // let translation = SCNMatrix4MakeTranslation( 0, -1,0)
        //let rotation = SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1)
        //let transform = SCNMatrix4Mult(translation, rotation)
       // mapMaterial.diffuse.contentsTransform = transform
        //FIXME:
        let b = SCNBox(width: width, height: height, length:  length, chamferRadius: 10.0)
        b.firstMaterial = mapMaterial
        b.firstMaterial?.lightingModel = .physicallyBased
        self.geometry = b
        
        if (self.geometry == nil) {
            print("Nil geometry")
        }
        else {
            print("JHMM")
        }
        
    }
    
    // FIXME: X:
    func displayBuildings() {
        for i in buildingCoordinates {
            let b = Building(coordinates: i.coordinates)
            if let first = b.baseShapeCoordinates.first {
                b.position = SCNVector3(first.x - Float(width / 2.0) + 20, 30, first.y - Float(length / 2.0))
                self.addChildNode(b)
                
                buildings.append(b)
                print(b.position)
            }
          
        }
    }
    
    // FIXME:
    func displayRandomObjects() {
        
    }
    
}
