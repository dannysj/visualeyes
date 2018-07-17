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

class ViewController: UIViewController {
    
    // For google API
    var googleAPIKey = "AIzaSyAe5sbhtyMIhTnrFCf-s2BR-_VWr1KVUn8"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    let session = URLSession.shared
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    private var currPlaneId: Int = 0
    
    private lazy var sceneView: ARSCNView = {
        let v = ARSCNView()
        v.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        v.session.run(configuration)
        v.delegate = self
        
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
    let CollisionCategoryCube: Int = 1
    
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
    
    private lazy var infoView: InfoView = {
        let v = InfoView()
        v.translatesAutoresizingMaskIntoConstraints = false
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tappedClose))
        v.addGestureRecognizer(tapGR)
        return v;
    }()
    
    // MARK: VC's Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupARView()
        setupIntroView()
        beginIntro()
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
            aniView.heightAnchor.constraint(equalToConstant: 250),
            aniView.widthAnchor.constraint(equalToConstant: 250)
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
        label.text = "Focus on a mural to begin"
    }
    
    func configureLightning() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    // MARK - Begin functions
    
    func beginIntro() {
        UIView.animate(withDuration: 0.3, animations: {
            self.introView.alpha = 1
        }) { (bool) in
            if (bool) {
                self.aniView.play()
            }
        }
    }
    
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
    
    // stop intro
    func stopIntro() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.introView.alpha = 0
            }) { (bool) in
                if (bool) {
                    self.aniView.stop()
                }
            }
        }
        
        
        //  FIXME: Remove
    }
    
    // Analyze functions
    
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
    
    // MARK: Gestures
    
    @objc func handleTap(tapGR: UITapGestureRecognizer) {
        
        guard stopTrack else { return }
        
        
        let tapLocation = tapGR.location(in: sceneView)
        let hitResult = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        // found a plane, and we tapped on the plane
        if let hit = hitResult.first {
            
            let attempResult = sceneView.hitTest(tapLocation)
            
            if let hitNode = attempResult.first?.node {
                if let index = nodes_s.firstIndex(of: hitNode), index > -1 {
                    selected = hitNode
                    
                }
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
            }
            
            
            
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
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        } else {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        }
        
        currPlaneId += 1
        return planeNode
    }
    
}

extension ViewController: ARSCNViewDelegate {
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
        print("Updating plane anchor")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
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


// MARK: For Sending request

/// Networking

extension ViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "WEB_DETECTION",
                        "maxResults": 10
                    ],
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            // FIXME:
            self.analyzeResults(data)
        }
        
        task.resume()
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
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
