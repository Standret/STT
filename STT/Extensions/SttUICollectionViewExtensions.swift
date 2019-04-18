//
//  SttUICollectionViewExtensions.swift
//  STT
//
//  Created by Alex Balan on 2/26/19.
//  Copyright © 2019 Alex Balan <balan.work.2016@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import UIKit

public extension UICollectionView {
    
    /**
     Adjusting vertical layout grid to the certian quantity of columns.
     Developer should determine quantity of columns in one row and set the padding between them.
     
     Width of every element will be calculated in accordance with 'columnsQuantity' and 'itemsPadding' parameters.
     Padding between lines can be set with 'lineSpacing' parametr, by default is 1
     
     - REMARK:
     It's recommended to use this function after all bounds of the view were set, for example in ViewDidLayoutSubviews method.
     
     - Parameters:
     - columnsQuantity: number of columns in one row
     - heigh: height of cell
     - itemsPadding: padding between cells in one row
     - lineSpacing: padding between rows
     
     - Returns: Void
     */
    func adjustVerticalLayoutGrid(columnsQuantity: Int, height: CGFloat, itemsPadding: CGFloat = 0, lineSpacing: CGFloat = 1, insets: UIEdgeInsets? = nil) {
        guard height > 0 else { return }
        guard let itemWidth = calculateItemWidth(columnsQuantity: columnsQuantity, itemsPadding: itemsPadding, sectionInset: insets) else { return }
        let itemSize: CGSize = CGSize(width: itemWidth, height: height)
        
        setFlowLayoutValues(itemSize: itemSize, lineSpacing: lineSpacing, interitemSpacing: 0)
    }
    
    /**
     The same as top function, but with aspectRatio instead of fixed height
     Height is calculated in aspect ratio to width, by default is 1, so elements will be sqaure.
     */
    func adjustVerticalLayoutGrid(columnsQuantity: Int, itemsPadding: CGFloat = 0, heightAspectRatio: CGFloat = 1, lineSpacing: CGFloat = 1, insets: UIEdgeInsets? = nil) {
        guard heightAspectRatio > 0 else { return }
        guard let itemWidth = calculateItemWidth(columnsQuantity: columnsQuantity, itemsPadding: itemsPadding, sectionInset: insets) else { return }
        let itemHeight: CGFloat = itemWidth * heightAspectRatio
        let itemSize: CGSize = CGSize(width: itemWidth, height: itemHeight)
        
        setFlowLayoutValues(itemSize: itemSize, lineSpacing: lineSpacing, interitemSpacing: 0)
    }
    
    /**
     Sets the flowLayout itemSize
     */
    func setItemSize(size: CGSize) {
        setFlowLayoutValues(itemSize: size)
    }
    
    private func calculateItemWidth(columnsQuantity: Int, itemsPadding: CGFloat, sectionInset: UIEdgeInsets? = nil) -> CGFloat? {
        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return nil }
        guard flowLayout.scrollDirection == .vertical else { return nil }
        guard columnsQuantity > 0 && itemsPadding >= 0 else { return nil }

        let sectionInset: UIEdgeInsets = sectionInset ?? flowLayout.sectionInset

        let insetsSize: CGFloat = sectionInset.left + sectionInset.right
        let contentWidth = self.bounds.size.width - insetsSize
        let itemWidth: CGFloat = contentWidth / CGFloat(columnsQuantity) - itemsPadding
        
        return itemWidth
    }
    
    private func setFlowLayoutValues(itemSize: CGSize, lineSpacing: CGFloat? = nil, interitemSpacing: CGFloat? = nil) {
        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.itemSize = itemSize
        if let _lineSpacing = lineSpacing {
            flowLayout.minimumLineSpacing = _lineSpacing
        }
        if let _interitemSpacing = interitemSpacing {
            flowLayout.minimumInteritemSpacing = _interitemSpacing
        }
    }
    
}
