//
//  SttCollectionViewWithSectionSource.swift
//  STT
//
//  Created by Standret on 30.05.18.
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

open class SttCollectionViewWithSectionSource<TCell: SttViewInjector, TSection: SttViewInjector>: SttBaseCollectionViewSource<TCell> {
    
    private var countData: [Int]!
    
    private var _collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>!
    public var collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)> { return _collection }
    
    private var disposable: DisposeBag!
    
    public convenience init (
        collectionView: UICollectionView,
        cellIdentifiers: [SttIdentifiers],
        sectionIdentifier: [String],
        collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>) {
        
        self.init(collectionView: collectionView, cellIdentifiers: cellIdentifiers, sectionIdentifier: sectionIdentifier)
        updateSource(collection: collection)
    }
    
    open func updateSource(collection: SttObservableCollection<(SttObservableCollection<TCell>, TSection)>) {
        _collection = collection
        
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
                self?._collectionView.performBatchUpdates({ [weak self] in
                    switch type {
                    case .reload:
                        self?.countData = self?.collection.map({ $0.0.count })
                        self?._collectionView.reloadSections(IndexSet(arrayLiteral: index))
                    case .delete:
                        self?._collectionView.deleteItems(at: indexes.map({ IndexPath(row: $0, section: index) }))
                        self?.countData = self?.collection.map({ $0.0.count })
                    case .insert:
                        self?._collectionView.insertItems(at: indexes.map({ IndexPath(row: $0, section: index) }))
                        self?.countData = self?.collection.map({ $0.0.count })
                    case .update:
                        self?._collectionView.reloadItems(at: indexes.map({ IndexPath(row: $0, section: index) }))
                    }
                })
            }).disposed(by: subCollectionDisposeBag)
        }
        
        countData = collection.map({ $0.0.count })
        _collectionView.reloadData()
    }
    
    override open func presenter(at indexPath: IndexPath) -> TCell {
        return _collection![indexPath.section].0[indexPath.row]
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countData[section]
    }
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return countData.count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: collectionViewReusableSection(at: indexPath),
                                                                   for: indexPath) as! SttCollectionReusableView<TSection>
        view.presenter = _collection?[indexPath.section].1
        return view
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReusableCell(at: indexPath),
                                                      for: indexPath) as! SttCollectionViewCell<TCell>
        
        cell.presenter = presenter(at: indexPath)
        return cell
    }
}
