//
//  CollectionViewWithSectionSource.swift
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

open class CollectionViewWithSectionSource<CellPresenter: PresenterType, SectionPresenter: PresenterType>: BaseCollectionViewSource<CellPresenter> {
    
    public typealias CollectionType = ObservableCollection<SectionData<CellPresenter, SectionPresenter>>
    
    private var countData: [Int]!
    private var collection: CollectionType!
    
    private var disposable: EventDisposable?
    
    private var lock = NSRecursiveLock()

    public convenience init (
        collectionView: UICollectionView,
        cellIdentifiers: [CellIdentifier],
        sectionIdentifier: [String],
        collection: CollectionType
        ) {
        
        self.init(collectionView: collectionView, cellIdentifiers: cellIdentifiers, sectionIdentifier: sectionIdentifier)
        updateSource(collection: collection)
    }
    
    open func updateSource(collection: CollectionType) {
        lock.lock()
        defer { lock.unlock() }
        
        self.collection = collection
                        
        subsribeOnChanges()
    }
    
    override open func presenter(at indexPath: IndexPath) -> CellPresenter {
        return collection[indexPath.section].cells[indexPath.row]
    }
    open func sectionPresenter(at section: Int) -> SectionPresenter {
        return collection[section].section
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countData[section]
    }
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return countData.count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: collectionViewReusableSection(at: indexPath),
            for: indexPath
            ) as! SttCollectionReusableView<SectionPresenter>
        
        view.presenter = sectionPresenter(at: indexPath.section)
        return view
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: collectionViewReusableCell(at: indexPath),
            for: indexPath
            ) as! SttCollectionViewCell<CellPresenter>
        
        cell.presenter = presenter(at: indexPath)
        return cell
    }
    
    private func subsribeOnChanges() {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        collection.collectionChanges.subscribe({ [weak self] changes in
//            fatalError("To be implemented and tested")
//            for change in changes {
//                switch change {
//                case .reload:
//                    self?.countData = self?.collection.map({ $0.cells.count })
//                    self?.collectionView.reloadSections(IndexSet(arrayLiteral: index))
//                case .delete(let indexes):
//                    self?.collectionView.deleteItems(at: indexes)
//                    self?.countData = self?.collection.map({ $0.cells.count })
//                case .insert(let indexes):
//                    self?.collectionView.insertItems(at: indexes)
//                    self?.countData = self?.collection.map({ $0.cells.count })
//                case .update(let indexes):
//                    self?.collectionView.reloadItems(at: indexes)
//                }
//            }
//        }
//        countData = collection.map({ $0.cells.count })
//        collectionView.reloadData()
    }
}
