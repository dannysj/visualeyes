//
//  Connection.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/23/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation
import SwiftyJSON

class Connection {
    // For google API
    var googleAPIKey = "AIzaSyAe5sbhtyMIhTnrFCf-s2BR-_VWr1KVUn8"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    var curatorServerURL: URL {
        return URL(string: "https://curator-server.azurewebsites.net/")!
    }
    let session = URLSession.shared
    
    // functions
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    
    func createGetBuildingRequest(pathComponent: String, handler: @escaping ([BuildingCoordinates]) -> (), pointHandler: @escaping ([Coordinate]) -> (), innerReqHandler:@escaping (Data) -> ()) {
        print("Creating get request")
        var request = URLRequest(url: curatorServerURL.appendingPathComponent(pathComponent))
        request.httpMethod = "GET"
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, handler: handler, pointHandler: pointHandler, innerHandler: innerReqHandler) }
    }
    
    func analyzeBuildingResults(_ dataToParse: Data, handler: (([BuildingCoordinates]) -> ()), pointHandler: @escaping ([Coordinate]) -> (), imageHandler: @escaping (Data) -> ()) {
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
                
                let responses: JSON = json["buildings"]
                print("Buildings is below")
                let randomResponses: JSON = json["random_points"]
                
                // Get face annotations
                if let imageString = json["road"].rawString(){
                    print("Image name: \(imageString)")
                    self.createPostRequest(at: "getBaseMap", para: imageString, handler: imageHandler)
                    parseJSONtoBuildingCoordinates(json: responses, handler: handler)
                    parseJSONtoPoints(json: randomResponses, handler: pointHandler)
                    
                } else {
                    print("Bad string")
                }
                
            }
            
        } catch  {
            print("Analyze errror")
            
        }
        
    }
    
    func analyzeInfoResult(_ dataToParse: Data, handler: (JSON) -> ()) {
        var json:JSON = JSON.null
        do {
            try json = JSON(data: dataToParse)
            
            // TODO:
            print("Responses from info")
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                print( "Error code \(errorObj["code"]): \(errorObj["message"])")
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"]
                print("Image result response is below")
                print("Got a response from image classifier")
                print(responses)
                // check if it is empty
                
                if (errorObj.dictionaryValue != [:]) {
                    handler(responses)
                }
                else {
                    print("No responses. Check server.")
                }
                
            }
            
        } catch  {
            print("Analyze errror")
            
        }
    }
    
    func parseJSONtoPoints(json: JSON, handler: ([Coordinate]) -> ()) {
        var random_coordinates:[Coordinate] = []
        print(json)
        if let array = json.array {
            for c in array {
                if let coord = c.array {
                    random_coordinates.append(Coordinate(x: coord[0].float ?? 0, y: coord[1].float ?? 0))
                }
            }

        }
        handler(random_coordinates)
    }
    
    
    func parseJSONtoBuildingCoordinates(json: JSON, handler: ([BuildingCoordinates]) -> ()) {
        var buildings_coordinates:[BuildingCoordinates] = []
        for (_, description) in json {
            if let array = description.array {
                var coordinates:[Coordinate] = []
                for c in array {
                    if let coord = c.string {
                        let coordXY = coord.components(separatedBy: ",")
                        coordinates.append(Coordinate(x: Float(coordXY[0]) ?? 0, y: Float(coordXY[1]) ?? 0))
                    }
                }
                
                buildings_coordinates.append(BuildingCoordinates(coordinates: coordinates))
            }
            
        }
        
        handler(buildings_coordinates)
    }
    

    func createPostRequest(at: String, para: String, handler: @escaping (Data) -> ()) {
        var request = URLRequest(url: curatorServerURL.appendingPathComponent(at))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        let jsonRequest = [
            "name": para
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        //FIXME:
        DispatchQueue.global().async { self.runImageRequestOnBackgroundThread(request, completion: handler) }
    }
    
    func createSendLocationPostRequest(x: Float, y: Float, handler: @escaping (([BuildingCoordinates]) -> ()), pointHandler: @escaping ([Coordinate]) -> (),  innerHandler: @escaping ((Data) -> ())) {
        var request = URLRequest(url: curatorServerURL.appendingPathComponent("secret-location"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        let jsonRequest = [
            "requests": [
                "longitude": x,
                "latitude": y
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, handler: handler, pointHandler: pointHandler, innerHandler: innerHandler) }
    }
    
    func createRecommendationPostRequest(x: Float, y: Float, handler: @escaping ((JSON) -> ())) {
        var request = URLRequest(url: curatorServerURL.appendingPathComponent("secret-location"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        let jsonRequest = [
            "requests": [
                "longitude": x,
                "latitude": y
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, handler: handler) }
    }
    

    
    func runRequestOnBackgroundThread(_ request: URLRequest, handler: @escaping ([BuildingCoordinates]) -> (), pointHandler: @escaping ([Coordinate]) -> (), innerHandler: @escaping ((Data) -> ())) {
        // run the request
           let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            // FIXME:
            //self.analyzeResults(data)
            print("GOT RESULT")
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            self.analyzeBuildingResults(data, handler: handler, pointHandler: pointHandler, imageHandler: innerHandler)
        }
        
        task.resume()
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest, handler: @escaping ((JSON) -> ())) {
        // run the request
        // return
        /*
         id
         result:
         [
         (empty if no)
         "muralinfo"
         "name"
         "desc"
         "artist"
         "obj"
         
         ]
         */
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            print("GOT RESULT")
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            self.analyzeInfoResult(data, handler: handler)
        }
        
        task.resume()
    }
    
    
    func runImageRequestOnBackgroundThread(_ request: URLRequest, completion: @escaping (Data) -> ()) {
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            // FIXME:
            //self.analyzeResults(data)
            print("GOT RESULT")
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            completion(data)
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
    
    func createRequest(with imageBase64: String, at: String, location: String, uid: Int, handler: @escaping (JSON) -> ()) {
        var request = URLRequest(url: curatorServerURL.appendingPathComponent(at))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let jsonRequest = [
            "requests": [
                "image": imageBase64
                ,
                "uid": uid,
                "location": location,
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        print("Sending image data")
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, handler: handler) }
    }

    
    /* Google's:
     
     
     func createRequest(with imageBase64: String) {
     // Create our request URL
     
     var request = URLRequest(url: googleURL)
     request.httpMethod = "POST"
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
     
     // Build our API request
     //FIXME:
     /*
     Format of JSON:
     [
     "requests": [
     "id": ,
     
     
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
     */
     
     
     
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
     DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, handler: <#([Any]) -> ()#>) }
     }
     
     
     
     
     */
}
