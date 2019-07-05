//
//  DoubleGenericBindingTests.swift
//  STTTests
//
//  Created by Peter Standret on 7/5/19.
//  Copyright © 2019 standret. All rights reserved.
//

import XCTest
@testable import STT

class DoubleGenericBindingTests: XCTestCase {

    var view: UIView!
    var label: UILabel!
    
    var set: SttBindingSet<DoubleGenericBindingTests>!
    
    override func setUp() {
        
        view = UIView()
        label = UILabel()
        
        set = SttBindingSet(parent: self)
    }
    
    
    func testBoolValueCombiner() {
        
        let val1 = Dynamic(true)
        let val2 = Dynamic(false)
        
        set.bind(Bool.self, Bool.self).forProperty({ $0.label.text = "\($1) \($2)" })
            .to(val1, val2)
        set.apply()
        
        XCTAssertEqual(label.text, "true false")
        
        val1.value = false
        
        XCTAssertEqual(label.text, "false false")
        
        val2.value = true
        
        XCTAssertEqual(label.text, "false true")
        
        val1.value = true
        
        XCTAssertEqual(label.text, "true true")
    }
}
