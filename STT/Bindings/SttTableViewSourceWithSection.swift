//
//  SttTableViewSourceWithSection.swift
//  STT
//
//  Created by Peter Standret on 3/8/19.
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

open class SttTableViewSourceWithSection<TCell: SttViewInjector, TSection: SttViewInjector>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    public var useAnimation: Bool = false
    public var maxAnimationCount = 1
    
    private var _tableView: UITableView
    
    private(set) var cellIdentifiers = [String]()
    
    private(set) var collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>!
    
    public var callBackEndPixel: Int = 150
    private var endScrollCallBack: (() -> Void)?
    
    private var disposable: DisposeBag!
    
    public init(tableView: UITableView, cellIdentifiers: [SttIdentifiers], collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>) {
        
        for item in cellIdentifiers {
            if !item.isRegistered {
                tableView.register(UINib(nibName: item.nibName ?? item.identifers, bundle: nil), forCellReuseIdentifier: item.identifers)
            }
        }
        
        _tableView = tableView
        self.cellIdentifiers.append(contentsOf: cellIdentifiers.map({ $0.identifers }))
        
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        updateSource(collection: collection)
    }
    
    open func updateSource(collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>) {
        self.collection = collection
        
        disposable = DisposeBag()
        subCollectionDisposeBag = DisposeBag()
        
        collection.observableObject.subscribe(onNext: { [weak self] _ in self?.subsribeOnChange() })
            .disposed(by: disposable)
        
        subsribeOnChange()
    }
    
    private var subCollectionDisposeBag: DisposeBag!
    private func subsribeOnChange() {
        
        subCollectionDisposeBag = DisposeBag()
        for index in 0..<collection.count {
            collection[index].0.observableObject.subscribe(onNext: { [weak self] (indexes, type) in
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
            }).disposed(by: subCollectionDisposeBag)
        }
        
        _tableView.reloadData()
    }
    
    public func addEndScrollHandler<T: UIViewController>(delegate: T, callback: @escaping (T) -> Void) {
        endScrollCallBack = { [weak delegate] in
            if let _delegate = delegate {
                callback(_delegate)
            }
        }
    }
    
    // MARK: - creation
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection == nil ? 0 : collection[section].0.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return collection == nil ? 0 : collection.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: indexPath))! as! SttTableViewCell<TCell>
        cell.presenter = collection[indexPath.section].0[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    /// Method which return cell identifier to create reusable cell
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return cellIdentifiers.first!
    }
    
    // MARK: - recognizer
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView(tableView, didSelectRowAt: indexPath, with: collection[indexPath.section].0[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, with presenter: TCell) { }
    
    private var inPosition: Bool = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
