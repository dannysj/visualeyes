//
//  ViewController+Location.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/26/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

extension DiscoverLensViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        guard let nowLocation = lastLocation else { return }
     
        let latestBearing = nowLocation.bearingToLocationRadian(testLocation)
        
        func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
            let heading: CGFloat = {
                let originalHeading = latestBearing - newAngle.degreesToRadians
                switch UIDevice.current.orientation {
                case .faceDown: return -originalHeading
                default: return originalHeading
                }
            }()
            
            return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
        }
     
        guard navigatingItem != nil else {return}
        let angle = computeNewAngle(with: CGFloat(newHeading.trueHeading))
        print("Angle is obtained")
        UIView.animate(withDuration: 0.5) {
            self.cameraButton.rotate(radians: angle) // rotate the picture
        }
       
            updateBadgeLocation(angle: angle)
            print("Updating")
        
     
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        lastLocation = currentLocation // store this location somewhere
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
       // self.cameraButton.addSmallCompass()
      
        
     //   addBadge()
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        // Test perforamnce:
        let networkQueue = DispatchQueue(label: "secretqueu", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem)
        //      DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
        networkQueue.async { [weak self] () -> Void in
            
            guard let strongSelf = self else {return}
            strongSelf.connection.createSendLocationPostRequest(x: Float(locValue.longitude), y: Float(locValue.latitude), handler: strongSelf.handleBuildingCoordinates, pointHandler: strongSelf.handleRandomCoordinates, innerHandler: strongSelf.analyzeImageData)
   
        }
        
        
        
    }
    
    func getNavigationUI() {
        guard let currentLocation = lastLocation else {
            navigationOnHold = true
            return
            
        }
        //dismissNavigationUI()
         self.cameraButton.addSmallCompass()
        addBadge()
    }
    
    func dismissNavigationUI(){
        self.cameraButton.compassView.removeFromSuperview()
        self.badge.removeFromSuperview()
        
    }
    
    func addBadge() {
        print("Added badge")
         if let distanceInMeters = lastLocation?.distance(from: testLocation) {
            self.badge.alpha = 0
            self.view.addSubview(badge)
            print("Activating constraint")
            NSLayoutConstraint.activate([
                badge.widthAnchor.constraint(equalToConstant: 60),
                badge.heightAnchor.constraint(equalToConstant: 60),
                badge.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100)
                ])
            print("Checking constraint")
            self.badgeCenterXConstraint = self.badge.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
            self.badgeCenterXConstraint.isActive = true
        
            badge.setupBadge(distance: distanceInMeters)
           
         }else {
            print("Nil badge")
        }
    }
    
 
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func updateBadgeLocation(angle: CGFloat) {
        if let distanceInMeters = lastLocation?.distance(from: testLocation) {
            let y:CGFloat = self.view.frame.height - 100 - 30 - 30 - 30 - buttonLength
            let x = y * tan(angle)
            
            //move badge
            NSLayoutConstraint.deactivate([self.badgeCenterXConstraint])
            print("Before error")
            self.badgeCenterXConstraint = self.badge.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: x)
            
            self.badgeCenterXConstraint.isActive = true
            print("After error")
            UIView.animate(withDuration: 0.3, animations: {
                self.badge.frame = CGRect(x: x, y: 100, width: 60, height: 60)
                self.view.layoutIfNeeded()
            }) { (_) in
             
                self.badge.alpha = 1
            }
            // calculate
               badge.updateDistance(distance: distanceInMeters)
        }
     
    }
    
    func handleInformation(json: JSON) {
        guard json != [:] else {
            // FIXME: DO some handling
            return
            
        }
        if let title = json["name"].string, let description = json["description"].string, let artist_name = json["artist_name"].string {
            let controller = InfoViewController()
            controller.info = [title, artist_name, description]
            self.present(controller, animated: true, completion: nil)
        }
        
   
    }
    func handleInformation() {
        DispatchQueue.main.async {
            let controller = InfoViewController()
            controller.info = ["We Bare Bear", "Some Random Guy", "Insert text here"]
            self.present(controller, animated: true, completion: nil)
            
        }
   
        
        
    }
    
    // for recommendation
    func handleRecommendation(json: JSON) {
        guard json != [:] else {
            // FIXME: DO some handling
            return
            
        }
        if let array = json["recommendation"].array {
            for en in array {
                let x = en["x"].floatValue
                let y = en["y"].floatValue
                if let obj_id = en["obj_id"].string {
                    print("Found obj ID \(obj_id)")
                    //loadObjects(x: x, y: y, obj:obj_id)
                }
            }
        } else {
            // FIXME:
        }
    }
}
