//
//  EventBookletViewController.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
import SwiftyJSON
import SceneKit

protocol UpdateBaseMapDelegate {
    func updateMapImage(data: Data)
    func updateBuildings(buildings: [BuildingCoordinates])
}

class EventBookletViewController: UIViewController {
    

    private lazy var connection: Connection = {
        let c = Connection()
        return c
    }()
    // Hot and now events
    private var trendEvents: [JSON] = [["name" : "Event Handler", "Date": "Jun 27, 3pm", "location": "Menlo Park"], ["name" : "My New Dog", "Date": "July 7, 1pm", "location": "My Park"],
        ["name" : "Event Handler", "Date": "Jun 27, 3pm", "location": "Menlo Park"]]
    
    // Event list
    private var eventList: [JSON] = [["name" : "Event Handler", "Date": "Jun 27, 3pm", "location": "Menlo Park"], ["name" : "My New Dog", "Date": "July 7, 1pm", "location": "My Park"],
                                       ["name" : "Event Handler", "Date": "Jun 27, 3pm", "location": "Menlo Park"]]
    
    private var mapLazyDelegate: UpdateBaseMapDelegate? {
        didSet {
            if let delegate = mapLazyDelegate {
                      connection.createGetBuildingRequest(pathComponent: "getMap", handler: delegate.updateBuildings, innerReqHandler: delegate.updateMapImage)
            }
  
        }
    }
    // Collection View stuff
    let cellID: String = "EventViewCell"
    let headerID: String = "EventHeaderCell"
    private lazy var collectionView: UICollectionView = {
        let layout = CustomLayout()
        layout.isVertical = true
        layout.delegate = self
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.alwaysBounceVertical = true
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = true
        cv.register(BookletHeaderViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension EventBookletViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! BookletHeaderViewCell
        
        header.setupViews()
        self.mapLazyDelegate = header
        return header
    }
    
    
}

extension EventBookletViewController: CustomLayoutDelegate {
    func collectionView(collectionView: UICollectionView, totalHeightForCellAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        // FIXME:
        return 600
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height / 2.5)
    }
    
    
}
