//
//  BookletHeaderViewCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/23/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import SceneKit

class BookletHeaderViewCell: UICollectionViewCell {
    // 3d Map
    
    var buildings_coordinates: [BuildingCoordinates] = []
    var random_coordinates: [Coordinate] = []
    var mapImage: UIImage! {
        didSet {
            addMap(position: SCNVector3(0,15,0))
        }
    }
    lazy var sceneView: SCNView = {
        let v:SCNView = SCNView()
        
        v.allowsCameraControl = true

        
        return v
    }  ()
    
    lazy var label: UILabel = {
       let l = UILabel()
        l.textAlignment = .center
        l.font = Theme.preferredFontWithTitleSize()
        l.textColor = Theme.textColor()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    var camera: SCNNode!
    // FIXME: Cache
    private var mapBase: BaseMap!
    
    func setupViews() {
        //self.contentView.backgroundColor = UIColor.FlatColor.Red.lightPink
        self.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        label.text = "Some random place"
        
        buildScene()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if self.subviews.contains(self.contentView) {
            for subView in self.contentView.subviews {
                subView.removeFromSuperview()
            }
        }
        setupViews()
    }
}

// For SceneKit
extension BookletHeaderViewCell {
    func buildScene() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.label.topAnchor),
            ])
        
        
 
        
        sceneSetup()
        
    }
    
    func sceneSetup() {
        // 1
        let scene = SCNScene()
        
        // 2
       
        
        // 3
        sceneView.scene = scene
    
        sceneView.backgroundColor = UIColor.white
        
    }
    
    func addMap(position: SCNVector3) {
        mapBase = BaseMap(image: mapImage, length: 480 * 0.95, width: 720 * 0.94,  buildingCoordinates: buildings_coordinates, numPoints: 0, dependsOnLighting: false)
        //mapBase.scale = SCNVector3(0.0025, 0.0025, 0.0025)
        mapBase.position = SCNVector3(position.x, position.y , position.z)
        
        sceneView.scene?.rootNode.addChildNode(mapBase)
        print("setting")
        
        // then adjust camera
        let camera = SCNCamera()
        camera.zFar = 10000
        self.camera = SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: 0, y: 600, z: 90)
        let constraint = SCNLookAtConstraint(target: mapBase)
        constraint.isGimbalLockEnabled = true
        self.camera.constraints = [constraint]
        sceneView.scene?.rootNode.addChildNode(self.camera)
            sceneView.pointOfView = self.camera
    }
    
}

extension BookletHeaderViewCell: UpdateBaseMapDelegate {
    func updateRandomPoints(points: [Coordinate]) {
        random_coordinates = []
        random_coordinates.append(contentsOf: points)
    }
    
    func updateMapImage(data: Data) {
        mapImage = UIImage(data: data)
    }
    
    func updateBuildings(buildings: [BuildingCoordinates]) {
        buildings_coordinates = []
        buildings_coordinates.append(contentsOf: buildings)
    }
    
    
}
