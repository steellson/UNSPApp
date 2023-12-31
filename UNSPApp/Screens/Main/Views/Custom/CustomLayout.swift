//
//  CustomLayout.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 14.11.2023.
//

import Foundation
import UIKit

//MARK: - Delegate protocol

protocol CustomLayoutDelegate: AnyObject {
    func collectionView(_
                        collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat
}

//MARK: - Impl

final class CustomLayout: UICollectionViewLayout {
    
    weak var delegate: CustomLayoutDelegate?
    
    //MARK: Variables
    
    var contentHeight: CGFloat = 0
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 0
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    //MARK: Prepare
    
    override func prepare() {
        restoreAttributesCache()
        
        guard let collectionView = collectionView else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        guard collectionView.numberOfSections != 0 else { return }
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForImageAtIndexPath: indexPath) ?? .zero
            
            let height = cellPadding * 2 + photoHeight
            
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    
    //MARK: Offset
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let collectionView = self.collectionView {
            let currentContentOffset = collectionView.contentOffset
                if currentContentOffset.y < proposedContentOffset.y {
                    return currentContentOffset
                }
        }
        return proposedContentOffset    
    }
    
    
    //MARK: Layout Attributes For Elements
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    
    //MARK: Layout Attributes For Item
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}


//MARK: - Restore cache

extension CustomLayout {
    
    func restoreAttributesCache() {
        self.cache = []
    }
}
