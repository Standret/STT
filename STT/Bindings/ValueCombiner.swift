//
//  ValueCombiner.swift
//  STT
//
//  Created by Peter Standret on 9/22/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ValueCombiner<Element1, Element2>: BindingContextType {
    
    private let property1: Dynamic<Element1>
    private let property2: Dynamic<Element2>
    
    private var innerContext: BindingContextType!
    private var lazzyApplier: Applier!
    
    private var binidngMode: BindingMode = .readBind
    
    init(_ property1: Dynamic<Element1>,
         _ property2: Dynamic<Element2>
        ) {
        
        self.property1 = property1
        self.property2 = property2
    }
    
    public func combine<Result>(_ selector: @escaping (Element1, Element2) -> Result) -> BinderContext<Result> {
        
        let newProperty = Dynamic<Result>(selector(property1.value, property2.value))
        
        lazzyApplier = { [unowned self] in
            switch self.binidngMode {
            case .readBind, .twoWayBind:
                return Disposables.create(
                    self.property1.bind({ newProperty.value = selector($0, self.property2.value) }),
                    self.property2.bind({ newProperty.value = selector(self.property1.value, $0) })
                )
            case .readListener, .twoWayListener:
                return Disposables.create(
                    self.property1.addListener({ newProperty.value = selector($0, self.property2.value) }),
                    self.property2.addListener({ newProperty.value = selector(self.property1.value, $0) })
                )
            default:
                fatalError("Incorrect type")
            }
        }
        
        return BinderContext<Result>(newProperty)
    }
    
    public func apply() -> Disposable {
        
        let innerContextDisp = innerContext.apply()
        let lazyApplierDisp = lazzyApplier()
        
        return Disposables.create(innerContextDisp, lazyApplierDisp)
    }
}

public class Value3Combiner<Element1, Element2, Element3>: BindingContextType {
    
    private let property1: Dynamic<Element1>
    private let property2: Dynamic<Element2>
    private let property3: Dynamic<Element3>
    
    private var innerContext: BindingContextType!
    private var lazzyApplier: Applier!
    
    private var binidngMode: BindingMode = .readBind
    
    init(_ property1: Dynamic<Element1>,
         _ property2: Dynamic<Element2>,
         _ property3: Dynamic<Element3>
        ) {
        
        self.property1 = property1
        self.property2 = property2
        self.property3 = property3
    }
    
    public func combine<Result>(_ selector: @escaping (Element1, Element2, Element3) -> Result) -> BinderContext<Result> {
        
        let newProperty = Dynamic<Result>(selector(property1.value, property2.value, property3.value))
        
        lazzyApplier = { [unowned self] in
            switch self.binidngMode {
            case .readBind, .twoWayBind:
                return Disposables.create(
                    self.property1.bind({ newProperty.value = selector($0, self.property2.value, self.property3.value) }),
                    self.property2.bind({ newProperty.value = selector(self.property1.value, $0, self.property3.value) }),
                    self.property3.bind({ newProperty.value = selector(self.property1.value, self.property2.value, $0) })
                )
            case .readListener, .twoWayListener:
                return Disposables.create(
                    self.property1.addListener({ newProperty.value = selector($0, self.property2.value, self.property3.value) }),
                    self.property2.addListener({ newProperty.value = selector(self.property1.value, $0, self.property3.value) }),
                    self.property3.addListener({ newProperty.value = selector(self.property1.value, self.property2.value, $0) })
                )
            default:
                fatalError("Incorrect type")
            }
        }
        
        return BinderContext<Result>(newProperty)
    }
    
    public func apply() -> Disposable {
        
        let innerContextDisp = innerContext.apply()
        let lazyApplierDisp = lazzyApplier()
        
        return Disposables.create(innerContextDisp, lazyApplierDisp)
    }
}

public class Value4Combiner<Element1, Element2, Element3, Element4>: BindingContextType {
    
    private let property1: Dynamic<Element1>
    private let property2: Dynamic<Element2>
    private let property3: Dynamic<Element3>
    private let property4: Dynamic<Element4>
    
    private var innerContext: BindingContextType!
    private var lazzyApplier: Applier!
    
    private var binidngMode: BindingMode = .readBind
    
    init(_ property1: Dynamic<Element1>,
         _ property2: Dynamic<Element2>,
         _ property3: Dynamic<Element3>,
         _ property4: Dynamic<Element4>
        ) {
        
        self.property1 = property1
        self.property2 = property2
        self.property3 = property3
        self.property4 = property4
    }
    
    public func combine<Result>(_ selector: @escaping (Element1, Element2, Element3, Element4) -> Result) -> BinderContext<Result> {
        
        let newProperty = Dynamic<Result>(selector(property1.value, property2.value, property3.value, property4.value))
        
        lazzyApplier = { [unowned self] in
            switch self.binidngMode {
            case .readBind, .twoWayBind:
                return Disposables.create(
                    self.property1.bind({ newProperty.value = selector($0, self.property2.value, self.property3.value, self.property4.value) }),
                    self.property2.bind({ newProperty.value = selector(self.property1.value, $0, self.property3.value, self.property4.value) }),
                    self.property3.bind({ newProperty.value = selector(self.property1.value, self.property2.value, $0, self.property4.value) }),
                    self.property4.bind({ newProperty.value = selector(self.property1.value, self.property2.value, self.property3.value, $0) })
                )
            case .readListener, .twoWayListener:
                return Disposables.create(
                    self.property1.addListener({ newProperty.value = selector($0, self.property2.value, self.property3.value, self.property4.value) }),
                    self.property2.addListener({ newProperty.value = selector(self.property1.value, $0, self.property3.value, self.property4.value) }),
                    self.property3.addListener({ newProperty.value = selector(self.property1.value, self.property2.value, $0, self.property4.value) }),
                    self.property4.addListener({ newProperty.value = selector(self.property1.value, self.property2.value, self.property3.value, $0) })
                )
            default:
                fatalError("Incorrect type")
            }
        }
        
        return BinderContext<Result>(newProperty)
    }
    
    public func apply() -> Disposable {
        
        let innerContextDisp = innerContext.apply()
        let lazyApplierDisp = lazzyApplier()
        
        return Disposables.create(innerContextDisp, lazyApplierDisp)
    }
}
