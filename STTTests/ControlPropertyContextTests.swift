//
//  ControlPropertyContextTests.swift
//  STTTests
//
//  Created by Peter Standret on 9/22/19.
//  Copyright © 2019 standret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Quick
import Nimble

@testable import STT

class StringConverter: ConverterType {
    
    func convert(value: String, parameter: Any?)  -> Int {
        return Int(value)!
    }
    
    func convertBack(value: Int, parameter: Any?) -> String {
        return String(value)
    }
}

class ControlPropertyContextTests: QuickSpec {
    
    override func spec() {
        
        describe("ControlPropertyContext") {
            
            context("simple binding to UITextField") {
                
                var variable: Dynamic<String>!
                var set: BindingSet<ControlPropertyContextTests>!
                var tf: UITextField!
                
                beforeEach {
                    variable = Dynamic("initial")
                    set = BindingSet(self)
                    tf = UITextField()
                }
                
                it("should set inital value from variable") {
                    set.bind(tf)
                        .to(variable)
                        .apply()
                    
                    expect(variable.value).to(equal("initial"))
                    expect(tf.text).to(equal("initial"))
                }
                
                it("should change value on variable if tf changed") {
                    set.bind(tf)
                        .to(variable)
                        .apply()
                    
                    tf.text = "111"
                    
                    expect(variable.value).to(equal("111"))
                    expect(tf.text).to(equal("111"))
                }
            }
            
//            context("simple binding to UITextField") {
//
//                var variable: Dynamic<Int>!
//                var set: BindingSet<ControlPropertyContextTests>!
//                var tf: UITextField!
//
//                beforeEach {
//                    variable = Dynamic(2319)
//                    set = BindingSet(self)
//                    tf = UITextField()
//                }
//
//                it("should set inital value from variable") {
//                    set.bind(tf)
//                        .withConverter(StringConverter())
//                        .to(variable)
//                        .apply()
//
//                    expect(variable.value).to(equal(2319))
//                    expect(tf.text).to(equal("2319"))
//                }
//
//                it("should change value on variable if tf changed") {
//                    set.bind(tf)
//                        .withConverter(StringConverter())
//                        .to(variable)
//                        .apply()
//
//                    tf.text = "111"
//
//                    expect(variable.value).to(equal(111))
//                    expect(tf.text).to(equal("111"))
//                }
//            }
        }
    }
}
