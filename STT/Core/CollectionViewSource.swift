//
//  CollectionViewSource.swift
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

open class CollectionViewSource<Presenter: PresenterType>: BaseCollectionViewSource<Presenter> {
    
    private var countData = 0
    public var numberOfItems: Int {
        get { return countData }
    }
    
    private var disposable: EventDisposable?
    private var endScrollCallBack: (() -> Void)?
    
    private var collection: ObservableCollection<Presenter>!
    private var lock = NSRecursiveLock()
    
    public convenience init(
        collectionView: UICollectionView,
        cellIdentifiers: [CellIdentifier],
        collection: ObservableCollection<Presenter>) {
        
        self.init(collectionView: collectionView, cellIdentifiers: cellIdentifiers, sectionIdentifier: [])
        updateSource(collection: collection)
    }
    
    ///
    /// Update collection for source
    ///
    public func updateSource(collection: ObservableCollection<Presenter>) {
        lock.lock()
        defer { lock.unlock() }
        
        self.collection = collection
        countData = collection.count
        collectionView.reloadData()
        
        disposable = collection.collectionChanges.subscribe({ [weak self] (indexes, type) in
            if type == .reload {
                self?.countData = collection.count
                self?.collectionView.reloadData()
            }
            self?.collectionView.performBatchUpdates({ [weak self] in
                switch type {
                case .delete:
                    self?.collectionView.deleteItems(at: indexes.map({ IndexPath(row: $0, section: 0) }))
                    self?.countData = collection.count
                case .insert:
                    self?.collectionView.insertItems(at: indexes.map({ IndexPath(row: $0, section: 0) }))
                    self?.countData = collection.count
                case .update:
                    self?.collectionView.reloadItems(at: indexes.map({ IndexPath(row: $0, section: 0) }))
                default: break
                }
            })
        })
    }
    
    override open func presenter(at indexPath: IndexPath) -> Presenter {
        return collection[indexPath.row]
    }
    
    // MARK: - UICollectionViewDataSource
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countData
    }
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: collectionViewReusableCell(at: indexPath),
            for: indexPath
            ) as! SttCollectionViewCell<Presenter>
        
        cell.presenter = presenter(at: indexPath)
        return cell
    }
}
