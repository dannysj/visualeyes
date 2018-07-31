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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        // Test perforamnce:
        let networkQueue = DispatchQueue(label: "secretqueu", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem)
        //      DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
        networkQueue.async { [weak self] () -> Void in
            
            guard let strongSelf = self else {return}
            strongSelf.connection.createSendLocationPostRequest(x: Float(locValue.longitude), y: Float(locValue.latitude), handler: strongSelf.handleBuildingCoordinates, pointHandler: strongSelf.handleRandomCoordinates, innerHandler: strongSelf.analyzeImageData)
   
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
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
                    loadObjects(x: x, y: y, obj:obj_id)
                }
            }
        } else {
            // FIXME:
        }
    }
}
