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
import Photos

class DiscoverLensViewController: UIViewController {
    var updateQueue: DispatchQueue = DispatchQueue(label: "com.dancent.load-object.serialSceneKitQueue")
    var messageViewController: MessageViewController!
    var popUpViewController: PopUpCardViewController!
    let buttonLength: CGFloat = 75.0
    let recordButtonLength: CGFloat = 100.0
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    private var currPlaneId: Int = 0
    lazy var connection: Connection = {
        let c = Connection()
        return c
    }()
    
    var currentInterest: [VirtualObject] = []
    lazy var sceneView: ARSCNView = {
        let v = ARSCNView()
      //  v.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        //v.session.run(configuration)
        v.delegate = self
        v.autoenablesDefaultLighting = true
      //     v.showsStatistics = true
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
    private var startTime: DispatchTime!
    private var arrayOfImages: [UIImage] = []
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
    
    var badge: Badge = {
        let b = Badge(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        b.translatesAutoresizingMaskIntoConstraints = false
        
        return b
    }()
    
    var badgeCenterXConstraint: NSLayoutConstraint!
    var navigationOnHold: Bool = false {
        didSet {
            if navigationOnHold {
                
            } else {
                
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
        return v;
    }()
    
    private lazy var aniView: LOTAnimationView = {
        let v = LOTAnimationView(name: "find_object")
        v.loopAnimation = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var loadingView: LOTAnimationView = {
        let m = LOTAnimationView(name: "loading")
        m.translatesAutoresizingMaskIntoConstraints = false
        m.loopAnimation = true
        m.autoReverseAnimation = false
        return m;
    }()
    
    private lazy var mapView: LOTAnimationView = {
        let m = LOTAnimationView(name: "location")
        m.translatesAutoresizingMaskIntoConstraints = false
        m.loopAnimation = false
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
        NSLayoutConstraint.centerWithHeightAndWidth(child: mapView, parent: m, height: 60, width: 90)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tappedMap))
        m.addGestureRecognizer(tapGR)
        return m
    }()
    
    private lazy var recordButtonAnimation: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: recordButtonLength, height: recordButtonLength))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        v.layer.cornerRadius = 50
        v.addBasicShadow()
        v.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: v.frame.insetBy(dx: 5, dy: 5), cornerRadius: 45).cgPath
        circle.position = CGPoint(x: v.frame.midX - 45, y: v.frame.midY - 45)
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = Theme.backgroundColor().cgColor
        circle.lineWidth = 5.0
        
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.duration = 2.0
        drawAnimation.isRemovedOnCompletion = false
        drawAnimation.fromValue = 0
        drawAnimation.toValue = 1
        
        circle.add(drawAnimation, forKey: "DrawCircleAnimation")
        v.layer.addSublayer(circle)
        
        return v
    }()

    var lastLocation: CLLocation? = nil {
        didSet {
            if navigatingItem != nil {
                navigationOnHold = false
                getNavigationUI()
            }
        }
    }
    var testLocation: CLLocation = CLLocation(latitude: 43.07301, longitude: -89.3884421)
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
        // initLocationManager()
    }
    
    func initLocationManager() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingHeading()
            //locationManager.startUpdatingLocation()
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
       // setupMapButton()
         
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
        
        self.view.bringSubview(toFront: cameraButton)
    }
    
    func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:  return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }
    
    func mapLoadingAnimate() {
        DispatchQueue.main.async {
            if self.mapLoading {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.mapView.alpha = 0
                }) { (_) in
                    self.mapButton.addSubview(self.loadingView)
                    NSLayoutConstraint.centerWithHeightAndWidth(child: self.loadingView, parent: self.mapButton, height: 80, width: 80)
                    self.loadingView.play()
                }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.loadingView.alpha = 0
                    self.mapView.alpha = 1
                }) { (_) in
                    self.loadingView.stop()
                    self.loadingView.removeFromSuperview()
                    self.mapView.play(fromProgress: 0.0, toProgress: 0.5, withCompletion: nil)
                }
                
            }
        }

    }
    
    lazy var cameraButton: ButtonView = {
        let v = ButtonView(frame: CGRect(x: 0, y: 0, width: buttonLength, height: buttonLength))
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(cameraButtonTapped))
        v.addGestureRecognizer(tapGR)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(cameraButtonPanned))
        v.addGestureRecognizer(panGR)
        return v
    }()
    
    
    
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
       
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        
        // menu
        
        self.view.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: buttonLength),
            cameraButton.heightAnchor.constraint(equalToConstant: buttonLength),
            cameraButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
            ])
        
        
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
        addFullNotificationView()
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
        mapBase = BaseMap(image: mapImage, length: 480 * 0.95, width: 720 * 0.94, buildingCoordinates: buildings_coordinates, numPoints: 7, randomPoints: random_coordinates, dependsOnLighting: false)
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
            print("infiite")
            if let _ = sceneView.virtualObject(at: location) { continue }
            let hitResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
            var overlapped: Bool = false
            if let hit = hitResult.first {
                
                let r2 = sceneView.hitTest(location, options: [.boundingBoxOnly: true])
                for r in r2 {
                    let n = r.node
                        if n == mapBase {
                            overlapped = true
                            break
                        }
                    
                    
                    
                
                }
                
                guard !overlapped else {continue}
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
        if let obj = sceneView.virtualObject(at: tapLocation) {
            print("Found virtual object")
            
            if currentInterest.contains(obj) {
                print("Found lalala object")
                addFullNotificationView()
               // startNavigation(item: obj)
                return
            }
            
            let ranNum = random(min: 0, max: 2)
            if ranNum == 1 {
                addPopUpMessage()
            }
            else {
                present(VoteViewController(), animated: true, completion: nil)
            }
            
            return
        }
        
      
          let hitScnResult = sceneView.hitTest(tapLocation, options: nil)
        let hitResult = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

        
        
        if let hitScn = hitScnResult.first {
            print("Scene kit test")
         
            // check whether if it is virtual object
      
          
                if let map = mapBase {
                    if map == hitScn.node {
                        print("You're hitting my map")
                    }
                    for n in map.items {
                        if n == hitScn.node {
                            print("Found ya, you're tapping one of the node")
                          
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
                
                guard mapBase == nil else {return}
                
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
    
    private lazy var exitNavigationButton: UIView = {
        let frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        let v = UIView(frame: frame)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        v.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        v.layer.cornerRadius = 30.0
        
        let closeView = CustomDrawView(type: .cross, lineColor: UIColor.FlatColor.White.darkLightGray, frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        closeView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(closeView)
        NSLayoutConstraint.activate([
            closeView.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            closeView.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            closeView.widthAnchor.constraint(equalToConstant:  frame.width - 10),
            closeView.heightAnchor.constraint(equalToConstant: frame.height - 10)
            ])
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(exitNavigation))
        v.addGestureRecognizer(tapGR)
        
        return v
    }()
    
    @objc func exitNavigation() {
        if let n = navigatingItem {
            n.removeFromParentNode()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.exitNavigationButton.alpha = 0
            }) { (_) in
                self.exitNavigationButton.removeFromSuperview()
                self.dismissNavigationUI()
            }
        }
    
        
    }
    
    func exitNavigationButtonRevealed() {
        self.view.addSubview(exitNavigationButton)
        
        NSLayoutConstraint.activate([
            exitNavigationButton.widthAnchor.constraint(equalToConstant:  exitNavigationButton.frame.width ),
            exitNavigationButton.heightAnchor.constraint(equalToConstant: exitNavigationButton.frame.height),
            exitNavigationButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            exitNavigationButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
            ])
        
        dismissNavigationUI()
    }
    
    var navigatingItem: VirtualObject? = nil
    
    func startNavigation(item: VirtualObject) {
        print("Starting navigation")
        if let obj = navigatingItem {
            // reset
            obj.removeFromParentNode()
            
        }
        //getting camera
        item.scale = SCNVector3(0.02, 0.02, 0.02)
        navigatingItem = item
        item.position = SCNVector3(0,-0.55,-1)
        if let pov = sceneView.pointOfView {
            print("Added cccc")
            pov.addChildNode(item)
            getNavigationUI()
            exitNavigationButtonRevealed()
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
    
    // To create plane
    
    func createPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let scenePlaneGeometry = ARSCNPlaneGeometry(device: metalDevice!)
        scenePlaneGeometry?.update(from: planeAnchor.geometry)
        let planeNode = SCNNode(geometry: scenePlaneGeometry)
        planeNode.name = "\(currPlaneId)"
        planeNode.opacity = 0.25
        if planeAnchor.alignment == .horizontal {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        } else {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        }
        
        currPlaneId += 1
      
        return planeNode
    }
    
    private lazy var surpriseAniView: LOTAnimationView = {
        let m = LOTAnimationView(name: "eye_blinking")
        m.translatesAutoresizingMaskIntoConstraints = false
        m.loopAnimation = true
        m.autoReverseAnimation = false
        return m;
    }()
    
    private lazy var hiddenGemView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        v.layer.cornerRadius = 45
        v.alpha = 0
        
        v.addSubview(surpriseAniView)
        NSLayoutConstraint.activate([
            surpriseAniView.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
            surpriseAniView.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -10),
            surpriseAniView.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 10),
            surpriseAniView.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -10)
            
            ])
        
        v.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        return v
    }()
    
    private var hiddenGemCenterX: NSLayoutConstraint!
    private var hiddenGemCenterY: NSLayoutConstraint!
    func addPopUpHiddenGem(pos: CGPoint) {
        self.view.addSubview(hiddenGemView)
        
        NSLayoutConstraint.activate([
            hiddenGemView.widthAnchor.constraint(equalToConstant: 90),
            hiddenGemView.heightAnchor.constraint(equalToConstant: 90),
            
            
            ])
        hiddenGemView.frame = CGRect(x: self.view.frame.width / 2 - 90 / 2, y: self.view.frame.height / 2 - 90 / 2, width: 90, height: 90)
        
        hiddenGemCenterX = hiddenGemView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        hiddenGemCenterX.isActive = true
        hiddenGemCenterY = hiddenGemView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        hiddenGemCenterY.isActive = true
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.hiddenGemView.alpha = 1
            self.hiddenGemView.transform =  CGAffineTransform(scaleX: 1.11, y: 1.11)
            self.surpriseAniView.play()
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.hiddenGemView.transform =  CGAffineTransform.identity
            }) { _ in
                self.movePopUpHiddenGem(pos: pos)
            }
        }
    }
    
    func projectSCNPoint(scnPoint: SCNVector3) {
        let pp = self.sceneView.projectPoint(scnPoint)
        let point = CGPoint(x: CGFloat(pp.x), y: CGFloat(pp.y))
        self.addPopUpHiddenGem(pos: point)
    }
    
    func movePopUpHiddenGem(pos: CGPoint) {
        NSLayoutConstraint.deactivate([self.hiddenGemCenterX, self.hiddenGemCenterY])
        self.hiddenGemCenterX = self.hiddenGemView.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: pos.x)
        self.hiddenGemCenterY = self.hiddenGemView.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: pos.y)
        self.hiddenGemCenterX.isActive = true
        self.hiddenGemCenterY.isActive = true
        let frame = self.hiddenGemView.frame
        UIView.animate(withDuration: 0.8, delay: 1.5, options: .curveEaseInOut, animations: {
            self.hiddenGemView.frame = CGRect(x: pos.x, y: pos.y, width: frame.width, height: frame.height)
            self.hiddenGemView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
                self.hiddenGemView.alpha = 0
            }, completion: { (_) in
                NSLayoutConstraint.deactivate([self.hiddenGemCenterX, self.hiddenGemCenterY])
                self.hiddenGemView.removeFromSuperview()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @objc func cameraButtonTapped() {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(v)
        self.view.bringSubview(toFront: cameraButton)
        self.view.bringSubview(toFront: mapButton)
        let bunchOfConstraints: [NSLayoutConstraint] = [
            v.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            v.topAnchor.constraint(equalTo: self.view.topAnchor),
            v.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(bunchOfConstraints)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            v.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                v.backgroundColor = UIColor.clear
            }) { _ in
                let uiImage = self.sceneView.snapshot()
                
                UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                NSLayoutConstraint.deactivate(bunchOfConstraints)
                v.removeFromSuperview()
            }
        }
        
    }
    
    @objc func cameraButtonPanned(panGR: UIPanGestureRecognizer) {
        let state = panGR.state
        if state == .began {
            
            arrayOfImages = []
            self.view.addSubview(recordButtonAnimation)
            self.view.bringSubview(toFront: cameraButton)
            NSLayoutConstraint.activate([
                recordButtonAnimation.widthAnchor.constraint(equalToConstant: recordButtonLength),
                recordButtonAnimation.heightAnchor.constraint(equalToConstant: recordButtonLength),
                recordButtonAnimation.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor),
                recordButtonAnimation.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor)
                ])
            
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.recordButtonAnimation.transform = CGAffineTransform.identity
                self.startTime = DispatchTime.now()
            }, completion: nil)
        }
        if state == .changed {
              let uiImage = self.sceneView.snapshot()
                arrayOfImages.append(uiImage)
            print("Added image")
            let timeNow = DispatchTime.now()
            let nanoInSeconds = timeNow.uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoInSeconds) / 1000000000
            
            if timeInterval >= 2.0 {
                panGR.isEnabled = false
            }
        }
        if state == .ended || state == .cancelled {
            endRecording()
             panGR.isEnabled = true
        }
    }
    
    func endRecording () {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.recordButtonAnimation.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.recordButtonAnimation.removeFromSuperview()
            
            // then
            let testArray = self.arrayOfImages.reversed()
            
            self.arrayOfImages.append(contentsOf: testArray)
            let duplArray = self.arrayOfImages
            self.arrayOfImages.append(contentsOf: duplArray)
            print("Attempting")
            // creating video buffer
            let settings = ImagesToVideoUtils.videoSettings(codec: AVVideoCodecH264, width: 720, height: 1280)
            let test = ImagesToVideoUtils(videoSettings: settings)
            test.createMovieFrom(images: self.arrayOfImages, withCompletion: { (url) in
                //start
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { saved, error in
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                        print("Saving")
                        // After uploading we fetch the PHAsset for most recent video and then get its current location url
                        
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let newObj = avurlAsset as! AVURLAsset
                            print(newObj.url)
                            print("Test")
                            // This is the URL we need now to access the video from gallery directly.
                        })
                    }
                    else {
                        print(error)
                    }
                }
                
                //end
            })
        }
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
