//
//  UIViewControllerDExt.swift
//  STT
//
//  Created by Popel on 5/13/18.
//  Copyright © 2019 Andriy Popel <andriypopel@gmail.com>
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

public extension UITableView {
    
    public func ScrollTableToBottom(tableView: UITableView, animationDuration: TimeInterval, animate: Bool = true) {
        
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if rowCount == 0 { return }
        
        let indexPath = IndexPath(row: rowCount == 0 ? 0 : rowCount - 1, section: 0)
        
        var animated = animate
        var duration = animationDuration
        
        if tableView.contentSize.height - tableView.contentOffset.y - tableView.bounds.height > 2 * tableView.bounds.height {
            duration =    0
            animated = false
        }
        
        UIView.animate(withDuration: duration) {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    public func ScrollTableToTop(tableView: UITableView, animationDuration: TimeInterval, animate: Bool = true) {
        
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if rowCount == 0 { return }
        
        let indexPath = IndexPath(row: rowCount == 0 ? 0 : rowCount - 1, section: 0)
        
        UIView.animate(withDuration: animationDuration) {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animate)
        }
    }
}
