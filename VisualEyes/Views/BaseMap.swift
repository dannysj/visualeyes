//
//  BaseMap.swift
//  test3dmap
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

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
    var random_coordinates: [Coordinate] = []
    var numPoint: Int = 0
    var randomObjects: [VirtualObject] = []
    var virtualObjectLoader: VirtualObjectLoader = VirtualObjectLoader()
    var items: [SCNNode] = []
    var dependsOnLighting: Bool = true
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(image: UIImage, length: Float, width: Float, buildingCoordinates: [BuildingCoordinates], numPoints: Int = 0, randomPoints: [Coordinate] = [], dependsOnLighting: Bool = true) {
        self.init()
        self.length = CGFloat(length)
        self.width = CGFloat(width)
        self.mapImage = image
        self.buildingCoordinates = buildingCoordinates
        self.random_coordinates = randomPoints
        self.numPoint = min(numPoints, randomPoints.count)
        self.dependsOnLighting = dependsOnLighting
        if (buildingCoordinates.count == 0) {
            print("GG No building")
        }
        print("Called")
        displayMap()
        
        displayBuildings()
        if (randomPoints.count == 0 || self.numPoint == 0) {
            print("GG No point")
            print(randomPoints.count)
            print(numPoints)
        }
        guard self.numPoint > 0 else { return }
        displayRandomObjects()
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
        if dependsOnLighting {
            b.firstMaterial?.lightingModel = .physicallyBased
        }
        
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
            let b = Building(coordinates: i.coordinates, autoLighting: dependsOnLighting)
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
        print("Calling random")
        for _ in 0 ..< numPoint {
           //let randomObject = VirtualObject.availableObjects[Int(arc4random_uniform(UInt32(VirtualObject.availableObjects.count - 1)))]
            
            let randomPoint = random_coordinates[Int(arc4random_uniform(UInt32(random_coordinates.count - 1)))]
            let position = SCNVector3(randomPoint.x - Float(width / 2.0) , 30, randomPoint.y - Float(length / 2.0))
           
            //if let node = SCNReferenceNode(url: randomObject.referenceURL) {
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.randomColor()
            material.lightingModel = .physicallyBased
            let geo = SCNSphere(radius: 20)
            geo.materials = [material]
            
            let node = SCNNode(geometry: geo)
          
                //randomObject.scale = SCNVector3(0.1, 0.1, 0.1)
                    node.position = position
                    self.addChildNode(node)
                    //randomObjects.append(randomObject)
                    self.items.append(node)
                    print("Random Object added at \(node.position)")
                
            //}
           

        }
    }
    
}
