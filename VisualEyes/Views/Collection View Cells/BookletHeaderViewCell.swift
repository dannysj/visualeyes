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
    var mapImage: UIImage!
    lazy var sceneView: SCNView = {
        let v:SCNView = SCNView()
        
        v.allowsCameraControl = true
        v.showsStatistics = true
        
        return v
    }  ()
    
    var camera: SCNNode!
    // FIXME: Cache
    private var mapBase: BaseMap!
    
    func setupViews() {
        self.contentView.backgroundColor = UIColor.FlatColor.Red.lightPink
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
            sceneView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            ])
        
        
        let camera = SCNCamera()
        camera.zFar = 30000
        self.camera = SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: 0, y: 500, z: 0)
        let constraint = SCNLookAtConstraint(target: mapBase)
        constraint.isGimbalLockEnabled = true
        self.camera.constraints = [constraint]
        
        sceneSetup()
    }
    
    func sceneSetup() {
        // 1
        let scene = SCNScene()
        
        // 2
        scene.rootNode.addChildNode(self.camera)
        
        // 3
        sceneView.scene = scene
        sceneView.pointOfView = self.camera
        sceneView.backgroundColor = UIColor.white
        
    }
    
    func addMap(position: SCNVector3) {
        mapBase = BaseMap(image: mapImage, length: 480 * 0.95, width: 720 * 0.94, buildingCoordinates: buildings_coordinates)
        mapBase.scale = SCNVector3(0.0025, 0.0025, 0.0025)
        mapBase.position = SCNVector3(position.x, position.y , position.z)
        
        sceneView.scene?.rootNode.addChildNode(mapBase)
        print("setting")
        
    }
    
}

extension BookletHeaderViewCell: UpdateBaseMapDelegate {
    func updateMapImage(data: Data) {
        mapImage = UIImage(data: data)
    }
    
    func updateBuildings(buildings: [BuildingCoordinates]) {
        buildings_coordinates = []
        buildings_coordinates.append(contentsOf: buildings)
    }
    
    
}
