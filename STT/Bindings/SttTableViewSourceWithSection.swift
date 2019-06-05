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

open class SttTableViewSourceWithSection<TCell: SttViewInjector, TSection: SttViewInjector>: SttBaseTableViewSource<TCell> {
    
    private var collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>!
    
    private var disposable: DisposeBag!
    
    public convenience init(
        tableView: UITableView,
        cellIdentifiers: [SttIdentifiers],
        collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>) {
        
        self.init(tableView: tableView, cellIdentifiers: cellIdentifiers)
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
    
    override open func presenter(at indexPath: IndexPath) -> TCell {
        return collection[indexPath.section].0[indexPath.row]
    }
    open func sectionPresenter(at section: Int) -> TSection {
        return collection[section].1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection == nil ? 0 : collection[section].0.count
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return collection == nil ? 0 : collection.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: indexPath))! as! SttTableViewCell<TCell>
        cell.presenter = collection[indexPath.section].0[indexPath.row]
        return cell
    }
    
    private var subCollectionDisposeBag: DisposeBag!
    private func subsribeOnChange() {
        
        subCollectionDisposeBag = DisposeBag()
        for index in 0..<collection.count {
            collection[index].0.observableObject.subscribe(onNext: { [weak self] (indexes, type) in
                if self?.maxAnimationCount ?? 0 < indexes.count {
                    self?.tableView.reloadData()
                }
                else {
                    switch type {
                    case .reload:
                        self?.tableView.reloadData()
                    case .delete:
                        self?.tableView.deleteRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                   with: self!.useAnimation ? .left : .none)
                    case .insert:
                        self?.tableView.insertRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                   with: self!.useAnimation ? .middle : .none)
                    case .update:
                        self?.tableView.reloadRows(at: indexes.map({ IndexPath(row: $0, section: 0) }),
                                                   with: self!.useAnimation ? .fade : .none)
                    }
                }
            }).disposed(by: subCollectionDisposeBag)
        }
        
        tableView.reloadData()
    }
}
