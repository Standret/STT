//
//  SttViewPage.swift
//  STT
//
//  Created by Standret on 12.06.18.
//  Copyright © 2019 Peter Standret <pstandret@gmail.com>
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

public protocol SttViewPagerDelegate {
    func pageChanged(selectedIndex: Int, oldIndex: Int)
}

@IBDesignable
public class SttViewPager: UIView, UIScrollViewDelegate {
    public weak var parent: UIViewController!
    
    public var selectedItem: Int = 0
    public var heightTabBar: CGFloat!
    
    private var views = [(String, UIViewController)]()
    public var segmentControl: UISegmentedControl!
    private var scrollView: UIScrollView!
    private var activeUnderline: UIView!
    private var underline: UIView!
    
    public var activeColor: UIColor = .white
    public var inactiveColor: UIColor = .lightGray
    public var underlineColor: UIColor = .white
    
    public var activeFont: UIFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
    public var inactiveFont: UIFont = UIFont(name: "HelveticaNeue", size: 14)!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        segmentControl = UISegmentedControl()
        scrollView = UIScrollView()
        underline = UIView()
        activeUnderline = UIView()
        
        segmentControl.addTarget(self, action: #selector(onValueChanged(_:)), for: .valueChanged)
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        addSubview(segmentControl)
        addSubview(scrollView)
        addSubview(underline)
        addSubview(activeUnderline)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        segmentControl.frame = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 44)
        segmentControl.selectedSegmentIndex = selectedItem
        segmentControl.removeBorders()
        
        scrollView.backgroundColor = UIColor.yellow
        scrollView.isUserInteractionEnabled = true
        scrollView.frame = CGRect(x: rect.minY, y: rect.minY + segmentControl.frame.height + 1, width: rect.width, height: rect.height - segmentControl.frame.height)
        
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: inactiveColor,
                                               NSAttributedString.Key.font: inactiveFont], for: .normal)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: activeColor,
                                               NSAttributedString.Key.font: activeFont], for: .selected)
        
        print(segmentControl.frame.height)
        activeUnderline.frame = CGRect(x: 0, y: 43, width: rect.width / CGFloat(views.count), height: 2)
        activeUnderline.backgroundColor = underlineColor
        
        underline.frame = CGRect(x: rect.minX, y: segmentControl.frame.height, width: rect.width, height: 1)
        underline.backgroundColor = backgroundColor
        
        insertInScrollView()
        redrawUnserline()
    }
    
    public func addItem(view: UIViewController, title: String) {
        views.append((title, view))
    }
    
    private var isInitialize = false
    private func insertInScrollView() {
        if isInitialize {
            return
        }
        
        isInitialize = true
        scrollView.contentSize = CGSize(width: CGFloat(views.count) * scrollView.frame.width, height: scrollView.frame.height)
        print(scrollView.contentSize)
        
        var index = 0
        for item in views {
            item.1.view.frame = CGRect(x: CGFloat(index) * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            item.1.willMove(toParent: parent)
            parent.addChild(item.1)
            item.1.didMove(toParent: parent)
            scrollView.addSubview(item.1.view)
            segmentControl.insertSegment(withTitle: item.0, at: index, animated: true)
            index += 1
        }
        segmentControl.selectedSegmentIndex = 0
    }

    
    private func redrawUnserline() {
        let normPosition = scrollView.contentOffset.x / CGFloat(views.count)
        activeUnderline.frame = CGRect(x: normPosition, y: 43, width: activeUnderline.frame.width, height: activeUnderline.frame.height)
    }
    
    @objc private func onValueChanged(_ sender: Any) {
        let position = scrollView.frame.width * CGFloat(segmentControl.selectedSegmentIndex)
        scrollView.setContentOffset(CGPoint(x: position, y: 0), animated: true)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        if page != segmentControl.selectedSegmentIndex {
            segmentControl.selectedSegmentIndex = page
            selectedItem = page
            // call about change view
        }
        redrawUnserline()
    }
}
