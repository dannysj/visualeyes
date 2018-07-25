//
//  NestedCollectionViewCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/24/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class NestedCollectionViewCell: UICollectionViewCell {
    var dataSourceDelegate: UICollectionViewDataSource?
    var layoutDelegate: UICollectionViewDelegate?
    var cellID = "NestedViewCell"
    var customLayoutDelegate: CustomLayoutDelegate!
    var headerTitle: String = ""
    private var headerFloatConstant: CGFloat = 0.0
    lazy var collectionView: UICollectionView = {
        let customLayout = CustomLayout()
        customLayout.isVertical = false
        customLayout.delegate = customLayoutDelegate
        let cv = UICollectionView(frame: .zero, collectionViewLayout: customLayout)
        //cv.alwaysBounceVertical = true
        cv.backgroundColor = UIColor.white
        cv.dataSource = dataSourceDelegate
        cv.delegate = layoutDelegate
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = false
        cv.contentInset = UIEdgeInsetsMake(0, 30, 0, 30)
        //cv.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        return cv
    }()
    
    private lazy var nestedTitle: NestedHeaderCell = {
       let n = NestedHeaderCell()
        n.translatesAutoresizingMaskIntoConstraints = false
        return n;
    }()
    
    func initializeNested(cellID: String = "NestedViewCell", dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate, customDelegate: CustomLayoutDelegate, headerTopConstant: CGFloat, headerTitle: String) {
        self.cellID = cellID
        self.dataSourceDelegate = dataSource
        self.layoutDelegate = delegate
        self.customLayoutDelegate = customDelegate
        self.headerFloatConstant = headerTopConstant
        self.headerTitle = headerTitle
        // init cv
        addCollectionView()
    }
    
    func addCollectionView() {
        self.contentView.addSubview(nestedTitle)
        NSLayoutConstraint.activate([
            nestedTitle.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            nestedTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            nestedTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            nestedTitle.heightAnchor.constraint(equalToConstant: headerFloatConstant)
            ])
        nestedTitle.setTitle(title: headerTitle)
        self.contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.nestedTitle.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
    }
    
    
    
    
}
extension NestedCollectionViewCell: UICollectionViewDelegate, CustomLayoutDelegate {
    func collectionView(collectionView: UICollectionView, totalHeightForCellAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    
}
