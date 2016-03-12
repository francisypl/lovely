//
//  LeftAlignedFlowLayout.swift
//  lovely
//
//  Created by Max Hudson on 3/12/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.row >= 0 {
            
            let layoutAttribute = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes
            
            if indexPath.row == 0 {
                layoutAttribute?.frame.origin.x = 20
            }
            
            if layoutAttribute?.frame.origin.x == sectionInset.left {
                return layoutAttribute
            }
            
            let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
            guard let previousLayoutAttribute = self.layoutAttributesForItemAtIndexPath(previousIndexPath) else {
                return layoutAttribute
            }
            
            layoutAttribute?.frame.origin.x = previousLayoutAttribute.frame.maxX + self.minimumInteritemSpacing
            
            return layoutAttribute
        }
        
        return nil
    }
    
}