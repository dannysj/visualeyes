//
//  InfoViewController.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/26/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    var info: [String] = ["Test Mural", "12", "Some random text"]
    // Collection View stuff
    var headerHeight: CGFloat = 240.0
    let cellID: String = "InfoViewCell"
    let headerID: String = "HeaderInfoCell"
    var statusBarShouldBeHidden: Bool = false
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
          cv.register(InfoCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        cv.register(HeaderViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        
        // FIXME:
      
        
        return cv
    }()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupScene()
    }
    

    func setupScene() {
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
    
    
    

}

extension InfoViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    @objc func closeTapped() {
        print("Close tapped")
        dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! HeaderViewCell
        
        header.setupViews()
        header.contentView.backgroundColor = UIColor.randomColor()
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! InfoCollectionViewCell
        let content = info[indexPath.item]
        switch indexPath.item {
        case 0:
            cell.updateCellWithTitle(name: content)
        case 1:
            cell.updateCellWithAuthor(author: content)
        case 2:
            cell.updateCellWithDescription(desc: content)
        case 3:
            cell.updateCellWithSuggestion(suggestion: [])
        default:
            fatalError("Out of bound")
        }
        
        return cell
    }
    
}

extension InfoViewController: CustomLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: headerHeight)
    }
    
    func collectionView(collectionView: UICollectionView, totalHeightForCellAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 60
        case 1:
            return 90
        case 2:
            return 300
        case 3:
            return 300
        default:
            fatalError("Out of bound")
        }
        
        
    }
    
    // MARK: Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = self.collectionView.contentOffset.y
        
        
        
        if y < headerHeight - 65 {
            if let naviC = self.navigationController {
                if !naviC.navigationBar.isHidden {
                    
                    self.navigationController?.navigationBar.alpha = 0.0
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
                
                
                
            }
        }
        else if y > headerHeight - 65{
            if y < headerHeight {
                if !statusBarShouldBeHidden {
                    statusBarShouldBeHidden = true
                    UIView.animate(withDuration: 0.25) {
                        self.setNeedsStatusBarAppearanceUpdate()
                    }
                }
                
                if let naviC = self.navigationController {
                    if !(naviC.navigationBar.isHidden) {
                        self.navigationController?.navigationBar.alpha = 0.0
                        self.navigationController?.setNavigationBarHidden(false, animated: false)
                    }
                }
                print("hi")
                print(self.collectionView.contentOffset.y)
                print(headerHeight)
                let x = y - headerHeight + 65
                print(x)
                self.navigationController?.navigationBar.alpha = x / 65.0
            }
            else if y > headerHeight {
                statusBarShouldBeHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
    
}
