//
//  TableViewSourceWithSection.swift
//  STT
//
//  Created by Peter Standret on 9/15/19.
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

open class TableViewSourceWithSection<CellPresenter: PresenterType, SectionPresenter: PresenterType>: BaseTableViewSource<CellPresenter> {
    
    public typealias CollectionType = ObservableCollection<SectionData<CellPresenter, SectionPresenter>>
    
    private var countData: [Int]!
    private var collection: CollectionType!
    
    private var disposable: EventDisposable?
    private var subCollectionDisposeBag = [EventDisposable]()
    
    private var lock = NSRecursiveLock()
    
    public convenience init(
        tableView: UITableView,
        cellIdentifiers: [CellIdentifier],
        collection: CollectionType
        ) {
        
        self.init(tableView: tableView, cellIdentifiers: cellIdentifiers)
        updateSource(collection: collection)
    }
    
    open func updateSource(collection: CollectionType) {
        lock.lock()
        defer { lock.unlock() }
        
        self.collection = collection

        subCollectionDisposeBag.removeAll()
        
        subscribeOnChanges()
    }
    
    override open func presenter(at indexPath: IndexPath) -> CellPresenter {
        return collection[indexPath.section].cells[indexPath.row]
    }
    open func sectionPresenter(at section: Int) -> SectionPresenter {
        return collection[section].section
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countData[section]
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return countData.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: indexPath))! as! SttTableViewCell<CellPresenter>
        cell.presenter = presenter(at: indexPath)
        return cell
    }
    
//    private func subsribeOnSectionChange(in sections: IndexSet? = nil) {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        let indexes = sections.flatMap { Array($0) } ?? Array(0..<collection.count)
//        // all table has been reloaded - remove previous subscribtions
//        if sections == nil {
//            subCollectionDisposeBag.removeAll()
//        }
//        
//        for index in indexes {
//            collection[index].cells.collectionChanges.subscribe { [weak self] changes in
//                guard let self = self else { return }
//                
//                // update count data
//                self.countData = self.collection.map({ $0.cells.count })
//                for change in changes {
//                    switch change {
//                    case .reload:
//                        self.tableView.reloadSections(IndexSet(integer: index), with: self.useAnimation ? .fade : .none)
//                    case .delete(let indexes):
//                        self.tableView.deleteRows(at: indexes.map({ .init(row: $0, section: index) }), with: self.useAnimation ? .left : .none)
//                    case .insert(let indexes):
//                        self.tableView.insertRows(at: indexes.map({ .init(row: $0, section: index) }), with: self.useAnimation ? .middle : .none)
//                    case .update(let indexes):
//                        self.tableView.reloadRows(at: indexes.map({ .init(row: $0, section: index) }), with: self.useAnimation ? .fade : .none)
//                    }
//                }
//            }
//            .add(to: &subCollectionDisposeBag)
//        }
//    }
    
    func subscribeOnChanges() {
        lock.lock()
        defer { lock.unlock() }
        
        countData = collection.map({ $0.cells.count })
        disposable = collection.collectionChanges.subscribe { [weak self] transaction in
            guard let self = self else { return }
            print("\(transaction.changes) - \(self.useAnimation)")
            self.tableView.performBatchUpdates {
                for change in transaction.changes {
                    switch change {
                    case .reload:
                        self.tableView.reloadData()
                    case .updateSections(let indexes):
                        self.tableView.reloadSections(IndexSet(indexes), with: self.useAnimation ? .fade : .none)
                    case .deleteSections(let indexes):
                        self.tableView.deleteSections(IndexSet(indexes), with: self.useAnimation ? .fade : .none)
                    case .insertSections(let indexes):
                        self.tableView.insertSections(IndexSet(indexes), with: self.useAnimation ? .fade : .none)
                    case .update(let indexes):
                        self.tableView.reloadRows(at: indexes, with: self.useAnimation ? .fade : .none)
                    case .delete(let indexes):
                        self.tableView.deleteRows(at: indexes, with: self.useAnimation ? .fade : .none)
                    case .insert(let indexes):
                        self.tableView.insertRows(at: indexes, with: self.useAnimation ? .fade : .none)
                    }
                }
                self.countData = self.collection.map({ $0.cells.count })
            } completion: { success in
                transaction.completion(success)
            }
        }
    }
}
