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
     
     - Important:
     If need to create square you should not pass any value to height
     
     - REMARK:
     It's recommended to use this function after all bounds of the view were set, for example in ViewDidLayoutSubviews method.
     
     - Parameters:
     - columnsQuantity: number of columns in one row
     - heigh: height of cell
     - itemsPadding: padding between cells in one row
     - lineSpacing: padding between rows
     
     - Returns: Void
     */
    func adjustVerticalLayoutGrid(columnsQuantity: Int, height: CGFloat? = nil, itemsPadding: CGFloat = 0, lineSpacing: CGFloat = 1) {

        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        if flowLayout.scrollDirection == .vertical {
            if columnsQuantity > 0 && itemsPadding >= 0 {
                
                let insetsSize: CGFloat = flowLayout.sectionInset.left + flowLayout.sectionInset.right
                
                let contentWidth = self.bounds.size.width - insetsSize
                let itemWidth: CGFloat = contentWidth / CGFloat(columnsQuantity) - itemsPadding
                
                let itemSize: CGSize = CGSize(width: itemWidth, height: height ?? itemWidth)
                flowLayout.itemSize = itemSize
                
                flowLayout.minimumLineSpacing = lineSpacing
                flowLayout.minimumInteritemSpacing = 0
            }
        }
    }
    
    func setItemSize(size: CGSize) {
        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = size
    }
}

