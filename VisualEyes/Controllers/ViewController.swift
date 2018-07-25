//
//  ViewController.swift
//  Secrets
//
//  Created by Danny Chew on 7/3/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import ARKit
import Lottie
import SwiftyJSON

class DiscoverLensViewController: UIViewController {
    

    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    private var currPlaneId: Int = 0
    private lazy var connection: Connection = {
        let c = Connection()
        return c
    }()
    lazy var sceneView: ARSCNView = {
        let v = ARSCNView()
        v.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        v.session.run(configuration)
        v.delegate = self
        v.autoenablesDefaultLighting = true
        return v
    }()
    
    private lazy var configuration: ARWorldTrackingConfiguration = {
        let r = ARWorldTrackingConfiguration()
        r.planeDetection = [.horizontal, .vertical]
        //FIXME: r.detectionImages = // your images here
        return r;
    }()
    
    var selected: SCNNode? = nil
    var nodes_s: [SCNNode] = []
    // also y offset?
    let cubeHeight:CGFloat = 0.05
    var stopTrack: Bool = false {
        didSet {
            if stopTrack {
                stopIntro()
            }
        }
    }
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    let availableObjects: [VirtualObject] = VirtualObject.availableObjects
    // found surface
    var startAR: Bool = false
    var foundMural: Bool = true {
        didSet {
            if !foundMural {
                beginIntro()
            }
        }
    }
    var menuOpened: Bool = false
    var mapLoading: Bool = false {
        didSet {
            mapLoadingAnimate()
        }
    }
    var mapButtonTapped: Bool = false {
        didSet {
            if mapButtonTapped {
                 showMapInstructions()
            }
            else {
                stopIntro()
            }
           
        }
    }
    
    // For Map:
    private var mapBase: BaseMap!
    var mapImage: UIImage! {
        didSet {
            mapLoading = false
        }
    }
    var buildings_coordinates: [BuildingCoordinates] = []
    
    // for intro UI
    private lazy var introView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0
        return v;
    }()
    
    private lazy var aniView: LOTAnimationView = {
        let v = LOTAnimationView(name: "phoneScan")
        v.loopAnimation = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var menuView: LOTAnimationView = {
        let m = LOTAnimationView(name: "menu")
        m.translatesAutoresizingMaskIntoConstraints = false
        
        m.autoReverseAnimation = false
        return m;
    }()
    
    private lazy var loadingView: LOTAnimationView = {
        let m = LOTAnimationView(name: "loading_animation")
        m.translatesAutoresizingMaskIntoConstraints = false
        
        m.autoReverseAnimation = false
        return m;
    }()
    
    private lazy var mapView: LOTAnimationView = {
        let m = LOTAnimationView(name: "bouncy_mapmaker")
        m.translatesAutoresizingMaskIntoConstraints = false
        m.loopAnimation = true
        m.autoReverseAnimation = false
        return m;
    }()
    
    private lazy var infoView: InfoView = {
        let v = InfoView()
        v.translatesAutoresizingMaskIntoConstraints = false
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tappedClose))
        v.addGestureRecognizer(tapGR)
        return v;
    }()
    
    private lazy var mapButton: UIView = {
       let m = UIView()
       m.translatesAutoresizingMaskIntoConstraints = false
        m.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        m.addBasicShadow()
        m.layer.cornerRadius = 20
        m.addSubview(mapView)
        NSLayoutConstraint.centerWithHeightAndWidth(child: mapView, parent: m, height: 30, width: 30)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tappedMap))
        m.addGestureRecognizer(tapGR)
        return m
    }()
    
    // MARK: VC's Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        connection.createGetBuildingRequest(pathComponent: "getMap", handler: handleBuildingCoordinates, innerReqHandler: analyzeImageData)
        mapLoading = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupARView()
        beginIntro()
        setupMapButton()
    }
    
    func setupMapButton() {
        self.view.addSubview(mapButton)
        
        NSLayoutConstraint.activate([
            mapButton.widthAnchor.constraint(equalToConstant: 40),
            mapButton.heightAnchor.constraint(equalToConstant: 40),
            mapButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            mapButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
            ])
    }
    
    func mapLoadingAnimate() {
        DispatchQueue.main.async {
            if self.mapLoading {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.mapView.alpha = 0
                }) { (_) in
                    self.mapButton.addSubview(self.loadingView)
                    NSLayoutConstraint.centerWithHeightAndWidth(child: self.loadingView, parent: self.mapButton, height: 30, width: 30)
                    self.loadingView.play()
                }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.loadingView.alpha = 0
                    self.mapView.alpha = 1
                }) { (_) in
                    self.loadingView.stop()
                    self.loadingView.removeFromSuperview()
                    self.mapView.play()
                }
                
            }
        }

    }
    
    func setupARView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGR:)))
        sceneView.addGestureRecognizer(tapGR)
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGR:)))
        sceneView.addGestureRecognizer(panGR)
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        
        // menu
        
        self.view.addSubview(menuView)
        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
            menuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            menuView.heightAnchor.constraint(equalToConstant: 30),
            menuView.widthAnchor.constraint(equalToConstant: 30)
            ])
        let tapGRMenu = UITapGestureRecognizer(target: self, action: #selector(menuAnimation))
        menuView.addGestureRecognizer(tapGRMenu)
    }
    
    func setupIntroView() {
        self.view.addSubview(introView)
        
        NSLayoutConstraint.activate([
            introView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            introView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            introView.heightAnchor.constraint(equalToConstant: 300),
            introView.widthAnchor.constraint(equalToConstant: 300)
            ])
        
        introView.addSubview(aniView)
        
        NSLayoutConstraint.activate([
            aniView.centerXAnchor.constraint(equalTo: introView.centerXAnchor),
            aniView.centerYAnchor.constraint(equalTo: introView.centerYAnchor, constant: -25),
            aniView.heightAnchor.constraint(equalToConstant: 180),
            aniView.widthAnchor.constraint(equalToConstant: 180)
            ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        introView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: aniView.bottomAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: introView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: introView.trailingAnchor)
            ])
        
        label.textAlignment = .center
        label.font = Theme.preferredFontWithMidSize()
        label.textColor = UIColor.white
        label.text = "Building AR World"
    }
    
    func configureLightning() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    // MARK - Begin functions
    
    func beginIntro() {
        setupIntroView()
        UIView.animate(withDuration: 0.3, animations: {
            self.introView.alpha = 1
        }) { (bool) in
            if (bool) {
                self.aniView.play()
            }
        }
    }

    
    // FIXME: Menu ANimation
    @objc func menuAnimation() {
        
        if !menuOpened {
            menuView.play(fromProgress: 0.2, toProgress: 0.5, withCompletion: nil)
            menuOpened = true
        }
        else {
            menuView.play(fromProgress: 0.5, toProgress: 1, withCompletion: nil)
            menuOpened = false
        }
        
    }
    
    func showMapInstructions() {
        introView.alpha = 0
        self.view.addSubview(introView)
        
        NSLayoutConstraint.activate([
            introView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            introView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 90),
            introView.widthAnchor.constraint(equalToConstant: 300)
            ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        introView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: introView.topAnchor),
            label.leadingAnchor.constraint(equalTo: introView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: introView.trailingAnchor)
            ])
        
        label.textAlignment = .center
        label.font = Theme.preferredFontWithMidSize()
        label.textColor = UIColor.white
        label.text = "Tap to place map"
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.introView.alpha = 1
        }, completion: nil)
    }
    
    // stop intro
    func stopIntro() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.introView.alpha = 0
            }) { (bool) in
                if (bool) {
                    self.aniView.stop()
                    for v in self.introView.subviews {
                        v.removeFromSuperview()
                    }
                    self.introView.removeFromSuperview()
                }
                
            }
        }
        
        
        //  FIXME: Remove
    }
    // MARK: ANalyze results
    
    func analyzeImageData(data: Data) {
        mapImage = UIImage(data: data)
    }
    
    func analyzeResults(_ dataToParse: Data) {
        // update UI mou
        var json:JSON = JSON.null
        do {
            try json = JSON(data: dataToParse)
            
            // TODO:
            
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                print( "Error code \(errorObj["code"]): \(errorObj["message"])")
            } else {
                // Parse the response
                
                let responses: JSON = json["responses"][0]
                print("Response is below")
                print(responses)
                // Get face annotations
                let webEntities = responses["webDetection"]["webEntities"]
                print(webEntities)
                // TODO:
                foundMural = true
                let muralName = webEntities[0]["description"]
                DispatchQueue.main.async {
                    
                    self.popUpInfo(text: "This mural is \(muralName)")
                }
                
                
                
            }
            
        } catch  {
            print("Analyze errror")
            
        }
        
    }
    
    func handleBuildingCoordinates(bc: [BuildingCoordinates]) {
        buildings_coordinates = []
        buildings_coordinates.append(contentsOf: bc)
        
    }
    
    func addMap(position: SCNVector3) {
        mapBase = BaseMap(image: mapImage, length: 480 * 0.95, width: 720 * 0.94, buildingCoordinates: buildings_coordinates)
         mapBase.scale = SCNVector3(0.0025, 0.0025, 0.0025)
        mapBase.position = SCNVector3(position.x, position.y , position.z)
        //let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        //constraint.isGimbalLockEnabled = true
       // mapBase.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(mapBase)
        print("setting")
       
    }
    
    // MARK: Pop Up Items
    
    func popUpInfo(text: String) {
        
        self.view.addSubview(self.infoView)
        
        NSLayoutConstraint.activate([
            self.infoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15),
            self.infoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor
                , constant: 15),
            self.infoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.infoView.heightAnchor.constraint(equalToConstant: 400)
            ])
        
        // TODO: Fetching and show loading
        self.infoView.updateContentsWithWord(text: text)
        // then, completion
        
        
    }
    
    @objc func tappedClose() {
        infoView.removeFromSuperview()
        resetTracking()
    }
    
    @objc func tappedMap() {
        guard !mapLoading else { return }
        mapButtonTapped = !mapButtonTapped
    }
    
    
    func randomPointsOnPlane() -> SCNVector3 {
        var location = CGPoint.randomPointFromScreen()
        var testVector = SCNVector3()
        while true {
            let hitResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
            
            if let hit = hitResult.first {
                let translation = hit.worldTransform.translation
                let x = translation.x
                let y = translation.y
                let z = translation.z
                
                testVector = SCNVector3(x, y, z)
                break
            }
            
            // if no,
            location = CGPoint.randomPointFromScreen()
        }
        return testVector
    }
    
    // MARK: Gestures
    
    @objc func handleTap(tapGR: UITapGestureRecognizer) {
        
        guard stopTrack else { return }
        print("Tapped")
        
        let tapLocation = tapGR.location(in: sceneView)
        let hitResult = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        // found a plane, and we tapped on the plane
        if let hit = hitResult.first {
            print("Found plane")
            guard let _ = mapImage else {return}
            guard mapBase == nil else {return}
            guard !mapLoading && mapButtonTapped else {return}
                print("Addeing ")
                let translation = hit.worldTransform.translation
                let x = translation.x
                let y = translation.y
                let z = translation.z
                addMap(position: SCNVector3(x,y,z))
            
            
     /*       let attempResult = sceneView.hitTest(tapLocation)
            
            if let hitNode = attempResult.first?.node {
               /* if let index = nodes_s.firstIndex(of: hitNode), index > -1 {
                    selected = hitNode
                    
                }*/
            }
            
            if let s = selected  {
                let height = 28
                s.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.3 * CGFloat(height % 10), green: 0.09*CGFloat(height%30), blue: 1-0.8 * CGFloat(height % 10), alpha: 1)
            }
            else {
                // add new object, not selecting
                
                // check if there's node in the position
                
                let translation = hit.worldTransform.translation
                let x = translation.x
                let y = translation.y
                let z = translation.z
                let height = 24
                let boxGeometry = SCNBox(width: cubeHeight, height: cubeHeight, length: cubeHeight, chamferRadius: 0.01)
                let boxNode = SCNNode(geometry: boxGeometry)
                boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.1 * CGFloat(height % 10), green: 0.03*CGFloat(height%30), blue: 1-0.1 * CGFloat(height % 10), alpha: 1)
                boxNode.position = SCNVector3(x,y+Float(cubeHeight/2.0),z)
                
                
                // physic enging
                boxNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
                boxNode.physicsBody?.categoryBitMask = CollisionCategoryCube
                boxNode.physicsBody?.isAffectedByGravity = false
                
                sceneView.scene.rootNode.addChildNode(boxNode)
                
                nodes_s.append(boxNode)
 
            }*/
            
            
            
        }
        
        
        
        
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        foundMural = false
        stopTrack = false
    }
    private func stopTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .init(rawValue: 0)
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
    }
    
    // MARK: - Dragging nodes
    @objc func didPan(panGR: UIPanGestureRecognizer) {
        let position = panGR.location(in: sceneView)
        
        let translation = panGR.translation(in: sceneView)
        
        let state = panGR.state
        
        if (state == .failed || state == .cancelled) {
            return
        }
        print("still called")
        var length = CGFloat()
        var x = Float()
        if (state == .began) {
            print("Begin")
            
        }
        else if let s = selected {
            // get current x and z
            // determin x z translation
            // drag together and do
            if let (min,max) = s.geometry?.boundingBox {
                length = CGFloat(max.x - min.x)
                x = max.x
                print(length)
            }
            
            let estimateNum = Int(ceil((Float(translation.x) - x) / Float(length * 50)))
            let copy = s.geometry?.copy() as! SCNGeometry
            print("\(translation)")
            //print(estimateNum)
            //for i in 0..<estimateNum {
            //    print("In loop")
            //    let bn = SCNNode(geometry: copy)
            //    bn.position.z += Float(i+1) * Float(length)
            //    bn.position.y = Float(length / 2.0)
            //   sceneView.scene.rootNode.addChildNode(bn)
            //1    }
        }
        
        if (state == .ended) {
            selected = nil
        }
    }
    
    // To create plane
    
    func createPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let scenePlaneGeometry = ARSCNPlaneGeometry(device: metalDevice!)
        scenePlaneGeometry?.update(from: planeAnchor.geometry)
        let planeNode = SCNNode(geometry: scenePlaneGeometry)
        planeNode.name = "\(currPlaneId)"
        planeNode.opacity = 0.25
        if planeAnchor.alignment == .horizontal {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.FlatColor.Blue.blueJeans
        } else {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.FlatColor.Red.lightPink
        }
        
        currPlaneId += 1
      
        return planeNode
    }
    
}

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
        
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
        
        // assuming
        let ranNum = random(min: 0, max: 100)
        if (ranNum == 1) {
            print("Added some items")
            let vector = randomPointsOnPlane()
            let object = availableObjects[random(min: 0, max: availableObjects.count - 1)]
            virtualObjectLoader.loadVirtualObject(object) { [unowned self] loadedObject in
                self.sceneView.prepare([object], completionHandler: { _ in
                    DispatchQueue.main.async {
                        loadedObject.position = vector
                        self.sceneView.scene.rootNode.addChildNode(loadedObject)
                        
                    }
                    print("Added one object, at position \(vector)")
                })
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

// MARK: For comparing nil objects

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
