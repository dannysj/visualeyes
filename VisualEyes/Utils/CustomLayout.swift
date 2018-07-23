//
//  CustomLayout.swift
//  Crumbs
//
//  Created by Danny Chew on 8/3/17.
//  Copyright © 2017 Danny Chew. All rights reserved.
//

import UIKit

protocol CustomLayoutDelegate {
    func collectionView(collectionView: UICollectionView, totalHeightForCellAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
}

class CustomLayout: UICollectionViewLayout {
    var delegate: CustomLayoutDelegate!
    
    var numberOfSections = 1
    var cellPadding: CGFloat = 0
    var isVertical = true
    var animate:Bool = false
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat = 0.0
    var contentSize: CGSize = CGSize(width: 0, height: 0)
    
    override func prepare() {
        
        if isVertical {
            contentHeight = 0.0
            let insets = collectionView!.contentInset
            contentWidth = collectionView!.bounds.width - (insets.left + insets.right)
        } else {
            contentWidth = 0.0
            let insets = collectionView!.contentInset
            contentHeight = collectionView!.bounds.height - (insets.top + insets.bottom)
        }
        
        if cache.isEmpty {
            if isVertical{
                //calculate column
                
                let columnWidth = contentWidth / CGFloat(numberOfSections)
                var xOffset = [CGFloat]()
                for column in 0..<numberOfSections {
                    xOffset.append(CGFloat(column) * columnWidth)
                }
                
                //FIXME: Only for first header
                let size = delegate.collectionView(collectionView!, layout: self, referenceSizeForHeaderInSection: 0)
                
                var column = 0
                var yOffset = [CGFloat](repeating: size.height, count: numberOfSections)
                
                // then,
                for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                    let indexPath = IndexPath(item: item, section: 0)
                    
                    //frame calculation
                    let width = columnWidth - cellPadding * 2
                    
                    //customHeight
                    let totalHeight = delegate.collectionView(collectionView: collectionView!, totalHeightForCellAtIndexPath: indexPath, withWidth: width)
                    
                    let height = cellPadding + totalHeight + cellPadding
                    
                    let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    //store in attributes
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    // for next contentHeight
                    contentHeight = max(contentHeight, frame.maxY)
     
                    yOffset[column] += height
                    
                    
                    column = column >= (numberOfSections - 1) ? 0 : (column + 1)
                }
           
            }
            // else if its horizontal
            else {
                //calculate row
                let rowWidth = contentHeight / CGFloat(numberOfSections)
                var yOffset = [CGFloat]()
                for row in 0..<numberOfSections {
                    yOffset.append(CGFloat(row) * rowWidth)
                }
                
                var row = 0
                var xOffset = [CGFloat](repeating: 0, count: numberOfSections)
                
                // then,
                for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                    let indexPath = IndexPath(item: item, section: 0)
                    
                    //frame calculation
                    let height = rowWidth - cellPadding * 2
                    
                    //customWidth
                    let totalWidth = delegate.collectionView(collectionView: collectionView!, totalHeightForCellAtIndexPath: indexPath, withWidth: height)
                    
                    let width = cellPadding + totalWidth + cellPadding
                    
                    let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: rowWidth)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    //store in attributes
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    // for next contentWidth
                    contentWidth = max(contentWidth, frame.maxX)
                    xOffset[row] += width
                    
                    row = row >= (numberOfSections - 1) ? 0 : (row + 1)
                }
                
            }
            contentSize = CGSize(width: contentWidth, height: contentHeight)
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
       
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        let sectionCount: Int = (collectionView!.dataSource?.numberOfSections!(in: collectionView!))!
        
        for i in 0..<sectionCount{
            
            layoutAttributes.append(self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: i))!)
            for attr in cache {
                if attr.frame.intersects(rect) {
                    layoutAttributes.append(attr)
                }
            }
        }
        return layoutAttributes
    }
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        let size = delegate.collectionView(collectionView!, layout: self, referenceSizeForHeaderInSection: indexPath.section)
        attributes.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        if newBounds.height != oldBounds.height && isVertical {
            return true
        }
        else if newBounds.width != oldBounds.width && !isVertical {
            return true
        }
        return false
    }
}
