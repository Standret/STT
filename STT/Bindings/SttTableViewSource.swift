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

open class SttTableViewSource<TPresenter: SttViewInjector>: SttBaseTableViewSource<TPresenter> {
        
    private var endScrollCallBack: (() -> Void)?
    public var callBackEndPixel: Int = 150
    
    private var countData = 0
    public var numberOfItems: Int {
        get { return countData }
    }
    
    private var collection: SttObservableCollection<TPresenter>!
    
    private var disposeBag: DisposeBag!
    
    public convenience init(
        tableView: UITableView,
        cellIdentifiers: [SttIdentifiers],
        collection: SttObservableCollection<TPresenter>) {
        
        self.init(tableView: tableView, cellIdentifiers: cellIdentifiers)
        updateSource(collection: collection)
    }
    
    open func updateSource(collection: SttObservableCollection<TPresenter>) {
        
        self.collection = collection
        self.countData = collection.count
        self.tableView.reloadData()
        
        self.disposeBag = DisposeBag()
        
        collection.observableObject.subscribe(onNext: { [weak self] (indexes, type) in
            if self?.maxAnimationCount ?? 0 < indexes.count || type == .reload {
                self?.countData = collection.count
                self?.tableView.reloadData()
            }
            else {
                self?.tableView.performBatchUpdates({ [weak self] in
                    switch type {
                    case .delete:
                        self?.tableView.deleteRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                   with: self!.useAnimation ? .left : .none)
                        self?.countData = collection.count
                    case .insert:
                        self?.tableView.insertRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                   with: self!.useAnimation ? .automatic : .none)
                        self?.countData = collection.count
                    case .update:
                        self?.tableView.reloadRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                   with: self!.useAnimation ? .fade : .none)
                    default: break
                    }
                }, completion: nil)
            }
        }).disposed(by: disposeBag)
    }
    
    override open func presenter(at indexPath: IndexPath) -> TPresenter {
        return collection[indexPath.row]
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countData
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: indexPath))! as! SttTableViewCell<TPresenter>
        cell.presenter = presenter(at: indexPath)
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView(tableView, didSelectRowAt: indexPath, with: collection[indexPath.row])
    }
}
