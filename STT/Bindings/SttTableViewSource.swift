//
//  SttTableViewSource.swift
//  STT
//
//  Created by Standret on 19.05.18.
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
import RxSwift

open class SttTableViewSource<T: SttViewInjector>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var _tableView: UITableView
    
    private var endScrollCallBack: (() -> Void)?
    
    public var callBackEndPixel: Int = 150
    
    private var _cellIdentifiers = [String]()
    public var cellIdentifiers: [String] { return _cellIdentifiers }
    
    public var useAnimation: Bool = false
    public var maxAnimationCount = 1
    
    private var _collection: SttObservableCollection<T>!
    public var collection: SttObservableCollection<T> { return _collection }
    
    private var disposeBag: DisposeBag!
    
    public init(tableView: UITableView, cellIdentifiers: [SttIdentifiers], collection: SttObservableCollection<T>) {
        
        for item in cellIdentifiers {
            if !item.isRegistered {
                tableView.register(UINib(nibName: item.nibName ?? item.identifers, bundle: nil), forCellReuseIdentifier: item.identifers)
            }
        }
        
        _tableView = tableView
        _cellIdentifiers.append(contentsOf: cellIdentifiers.map({ $0.identifers }))
        
        super.init()
        tableView.dataSource = self
        updateSource(collection: collection)
        tableView.delegate = self
    }
    
    open func updateSource(collection: SttObservableCollection<T>) {
        _collection = collection
        _tableView.reloadData()
        
        disposeBag = DisposeBag()
        _collection.observableObject.subscribe(onNext: { [weak self] (indexes, type) in
            if self?.maxAnimationCount ?? 0 < indexes.count {
                self?._tableView.reloadData()
            }
            else {
                switch type {
                case .reload:
                    self?._tableView.reloadData()
                case .delete:
                    self?._tableView.deleteRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                with: self!.useAnimation ? .left : .none)
                case .insert:
                    self?._tableView.insertRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                with: self!.useAnimation ? .middle : .none)
                case .update:
                    self?._tableView.reloadRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                with: self!.useAnimation ? .fade : .none)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    public func addEndScrollHandler<T: UIViewController>(delegate: T, callback: @escaping (T) -> Void) {
        endScrollCallBack = { [weak delegate] in
            if let _delegate = delegate {
                callback(_delegate)
            }
        }
    }
    
    // MARK: -- todo: write init for [cellIdentifiers]
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _collection == nil ? 0 : _collection.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: indexPath))! as! SttTableViewCell<T>
        cell.presenter = _collection[indexPath.row]
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView(tableView, didSelectRowAt: indexPath, with: collection[indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with presenter: T) { }
    
    /// Method which return cell identifier to create reusable cell
    open func cellIdentifier(for indexPath: IndexPath) -> String {
        return cellIdentifiers.first!
    }
    
    private var inPosition: Bool = false
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.y
        let width = scrollView.contentSize.height - scrollView.bounds.height - CGFloat(callBackEndPixel)
        
        if (scrollView.contentSize.height > scrollView.bounds.height) {
            if (x > width) {
                if (!inPosition) {
                    endScrollCallBack?()
                }
                inPosition = true
            }
            else {
                inPosition = false
            }
        }
    }
}
