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
    func updateRandomPoints(points: [Coordinate])
}

class EventBookletViewController: UIViewController {
    

    private lazy var connection: Connection = {
        let c = Connection()
        return c
    }()
    // Hot and now events
    private var trendEvents: [JSON] = [["name" : "Event Handler", "date": "Jun 27, 3pm", "location": "Menlo Park"], ["name" : "My New Dog", "date": "July 7, 1pm", "location": "My Park"],
        ["name" : "Event Handler", "date": "Jun 27, 3pm", "location": "Menlo Park"]]
    
    // Event list
    private var eventList: [JSON] = [["name" : "Event List Handler", "date": "Jun 27, 3pm", "location": "Menlo Park"], ["name" : "My New Dog", "date": "July 7, 1pm", "location": "My Park"],
                                       ["name" : "Event Handler", "date": "Jun 27, 3pm", "location": "Menlo Park"]]
    private var titleList: [String] = ["Trending now", "Today's Events"]
    private var mapLazyDelegate: UpdateBaseMapDelegate? {
        didSet {
            if let delegate = mapLazyDelegate {
                      connection.createGetBuildingRequest(pathComponent: "getMap", handler: delegate.updateBuildings, pointHandler: delegate.updateRandomPoints, innerReqHandler: delegate.updateMapImage)
            }
  
        }
    }
    
    let trendingCellID: String = "TrendingCell"
    let eventListCellID: String = "EventListCell"
    let titleHeaderCell: String = "TitleForSectionHeader"
    var trendingCollectionView: UICollectionView!
    var eventListCollectionView: UICollectionView!
    
    private lazy var closeButton: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 20
        v.layer.shadowRadius = 2
        v.layer.shadowColor = UIColor.FlatColor.White.darkMediumGray.withAlphaComponent(0.5).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        let close = CustomDrawView(type: .cross, lineColor: Theme.textColor(), frame: frame)
        close.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(close)
        
        NSLayoutConstraint.activate([
            close.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            close.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            close.widthAnchor.constraint(equalToConstant:  frame.width),
            close.heightAnchor.constraint(equalToConstant: frame.height)
            ])
        
        v.addBasicShadow()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        v.addGestureRecognizer(tapGR)
        return v
    }()
    
    // Collection View stuff
    let cellID: String = "NestedViewCell"
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
        cv.register(NestedCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        cv.register(BookletHeaderViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    func setupUI() {
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        // close button
        self.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30)
            
            ])
        
        
        
        
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

extension EventBookletViewController {
    @objc func closeTapped() {
        print("Close tapped")
        dismiss(animated: true, completion: nil)
    }
    
}

extension EventBookletViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            
            return 2
        } else if collectionView == eventListCollectionView {
          
            return eventList.count
        }
        else if collectionView == trendingCollectionView {
            
            return trendEvents.count
        }
        // shouldnt be here
        print("Should't be here")
        return 0
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // own collectionView?
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NestedCollectionViewCell
            
            if indexPath.row == 0 {
                cell.initializeNested(cellID: trendingCellID, dataSource: self, delegate: self, customDelegate: self, headerTopConstant: 50, headerTitle: titleList[indexPath.row])
                cell.collectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: trendingCellID)
                //dummy
                cell.collectionView.register(BookletHeaderViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
                trendingCollectionView = cell.collectionView
   
            }
            else {
                cell.initializeNested(cellID: eventListCellID, dataSource: self, delegate: self,customDelegate: self, headerTopConstant: 50, headerTitle: titleList[indexPath.row])
                cell.collectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: eventListCellID)
                //dummy
                cell.collectionView.register(BookletHeaderViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
                eventListCollectionView = cell.collectionView

            }
            return cell
        }
        // or this is trending's cv
        else if collectionView == trendingCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: trendingCellID, for: indexPath) as! EventCollectionViewCell
                let item = trendEvents[indexPath.row]
                let image = UIImage.imageWithSize(size: CGSize(width: 200, height: 300), color: UIColor.randomColor())
                cell.initData(type: .Normal, title: item["name"].stringValue, location: item["location"].stringValue, time: item["date"].stringValue, image: image)
            
               return cell
        }
        else if collectionView == eventListCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: eventListCellID, for: indexPath) as! EventCollectionViewCell
                let item = eventList[indexPath.row]
                cell.initData(type: .Summary, title: item["name"].stringValue, location: item["location"].stringValue, time: item["date"].stringValue)
            
               return cell
        }
        
        // shouldn't be here
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
     
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == self.collectionView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! BookletHeaderViewCell
            
            header.setupViews()
            self.mapLazyDelegate = header
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! BookletHeaderViewCell
            return header
        }
        

    }
    
    
}

extension EventBookletViewController: CustomLayoutDelegate {
    func collectionView(collectionView: UICollectionView, totalHeightForCellAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        // FIXME:
        if collectionView == self.collectionView {
          return 250
        }
        // else, return width
        // because horizontal
        return 250
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == self.collectionView {
             return CGSize(width: self.view.frame.width, height: self.view.frame.height / 2.5)
        }
        // else, this is normal title
         return CGSize(width: 0, height: 0)
       
    }
    
    
}
