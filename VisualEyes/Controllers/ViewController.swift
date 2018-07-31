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
import CoreLocation

class DiscoverLensViewController: UIViewController {
    
     var messageViewController: MessageViewController!
     var popUpViewController: PopUpCardViewController!
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    private var currPlaneId: Int = 0
     lazy var connection: Connection = {
        let c = Connection()
        return c
    }()
    lazy var sceneView: ARSCNView = {
        let v = ARSCNView()
        v.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        //v.session.run(configuration)
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
    var addedVirtualObject: [VirtualObject] = []
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
    private var locationManager: CLLocationManager = CLLocationManager()
    private var mapBase: BaseMap!
    var mapImage: UIImage! {
        didSet {
            mapLoading = false
        }
    }
    var buildings_coordinates: [BuildingCoordinates] = []
    var random_coordinates: [Coordinate] = []
    
    // for intro UI
    private lazy var introView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0
        return v;
    }()
    
    private lazy var aniView: LOTAnimationView = {
        let v = LOTAnimationView(name: "find_object")
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
        m.loopAnimation = true
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
        m.layer.cornerRadius = 25
        m.addSubview(mapView)
        NSLayoutConstraint.centerWithHeightAndWidth(child: mapView, parent: m, height: 40, width: 40)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tappedMap))
        m.addGestureRecognizer(tapGR)
        return m
    }()
    
    private lazy var popUpMessageView: CardView = {
        let width = self.view.frame.width * 0.5
        let v = CardView(frame: CGRect(x: self.view.frame.width / 2.0 - width / 2.0, y: self.view.frame.height, width: width, height: 200))
        v.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: -10),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor)
            ])
        
        label.textAlignment = .center
        label.font = Theme.preferredFontWithMidSize()
        label.textColor = Theme.textColor()
        label.text = "Some random text goes to here"
        label.numberOfLines = 0
        return v
    }()
    private var popUpMessageYConstraint: NSLayoutConstraint!
    
    // MARK: VC's Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
  
        mapLoading = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
           // locationManager.startUpdatingLocation()
        }
        
        getUserLocation()
    }
    
    func getUserLocation() {
        locationManager.requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupARView()
        resetTracking()
        beginIntro()
        setupMapButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.pause()
        
    }
    
    func setupMapButton() {
        self.view.addSubview(mapButton)
        
        NSLayoutConstraint.activate([
            mapButton.widthAnchor.constraint(equalToConstant: 50),
            mapButton.heightAnchor.constraint(equalToConstant: 50),
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
                    NSLayoutConstraint.centerWithHeightAndWidth(child: self.loadingView, parent: self.mapButton, height: 60, width: 80)
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
            label.topAnchor.constraint(equalTo: aniView.bottomAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: introView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: introView.trailingAnchor)
            ])
        
        label.textAlignment = .center
        label.font = Theme.preferredFontWithMidSize()
        label.textColor = UIColor.white
        label.textDropShadow()
        label.text = "Scan around with your phone"
    }
    
    func configureLightning() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func addPopUpMessage() {
        self.view.addSubview(popUpMessageView)
        
        NSLayoutConstraint.activate([
            popUpMessageView.widthAnchor.constraint(equalToConstant: popUpMessageView.frame.width),
            popUpMessageView.heightAnchor.constraint(equalToConstant: popUpMessageView.frame.height),
            popUpMessageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        
        
        let oldFrame = popUpMessageView.frame
        let newFrame = CGRect(x: oldFrame.minX, y: (self.view.frame.height / 2.0) - (oldFrame.height / 2.0), width: oldFrame.width, height: oldFrame.height)
        popUpMessageYConstraint = popUpMessageView.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -oldFrame.height / 2.0)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.popUpMessageView.frame = newFrame
            self.popUpMessageYConstraint.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
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
        label.textDropShadow()
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
    
    
    func handleBuildingCoordinates(bc: [BuildingCoordinates]) {
        buildings_coordinates = []
        buildings_coordinates.append(contentsOf: bc)
        
    }
    
    func handleRandomCoordinates(bc: [Coordinate]) {
        random_coordinates = []
        random_coordinates.append(contentsOf: bc)
        
    }
    
    func addMap(position: SCNVector3) {
        mapBase = BaseMap(image: mapImage, length: 480 * 0.95, width: 720 * 0.94, buildingCoordinates: buildings_coordinates, numPoints: 7, randomPoints: random_coordinates)
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
                let r2 = sceneView.hitTest(location, options: [.boundingBoxOnly: true])
                for r in r2 {
                    let n = r.node
                        if n == mapBase {
                            continue
                        }
                    
                }
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
          let hitScnResult = sceneView.hitTest(tapLocation, options: nil)
        let hitResult = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if let object = sceneView.virtualObject(at: tapLocation) {
            print("Found virtual object")
            
            let ranNum = random(min: 0, max: 2)
            if ranNum == 1 {
                addPopUpMessage()
            }
            else {
                present(VoteViewController(), animated: true, completion: nil)
            }
            
            return
        }
        
        
        if let hitScn = hitScnResult.first {
            print("Scene kit test")
            var found = false
            // check whether if it is virtual object
      
          
                if let map = mapBase {
                    if map == hitScn.node {
                        print("You're hitting my map")
                    }
                    for n in map.items {
                        if n == hitScn.node {
                            print("Found ya, you're tapping one of the node")
                            found = true
                            present(EventBookletViewController(), animated: true, completion: nil)
                            return
                        }
                    }
                }
            

        }
        
        
        // found a plane, and we tapped on the plane
        if let hit = hitResult.first {
            print("Found plane")
            if mapButtonTapped {
                guard let _ = mapImage else {return}
                guard mapBase == nil else {return}
                guard !mapLoading && mapButtonTapped else {return}
                print("Addeing ")
                let translation = hit.worldTransform.translation
                let x = translation.x
                let y = translation.y
                let z = translation.z
                addMap(position: SCNVector3(x,y,z))
                mapButtonTapped = false
            }
        }
        
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        enhanceCamera()
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
