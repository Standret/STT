//
//  BinderContextTests.swift
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

class IntConverter: ConverterType {
    
    func convert(value: Int, parameter: Any?)  -> String {
        return "(\(value))"
    }
}

class BinderContextTests: QuickSpec {
    
    override func spec() {
        
        describe("BinderContext") {
            
            context("simple binding to UILabel") {
                
                var variable: Dynamic<String>!
                var set: BindingSet<BinderContextTests>!
                var label: UILabel!
                
                beforeEach {
                    variable = Dynamic("initial")
                    set = BindingSet(self)
                    label = UILabel()
                }
                
                it("should set inital value") {
                    set.bind(variable)
                        .to(label)
                        .apply()
                    
                    expect(label.text).to(equal("initial"))
                }
                
                it("should not set inital value") {
                    set.bind(variable)
                        .withMode(.readListener)
                        .to(label)
                        .apply()
                    
                    expect(label.text).to(beNil())
                }
                
                it("should set inital next value") {
                    set.bind(variable)
                        .withMode(.readListener)
                        .to(label)
                        .apply()
                    
                    variable.value = "text"
                    
                    expect(label.text).to(equal("text"))
                }
            }
            
            context("type binding to UILabel") {
                
                var set: BindingSet<BinderContextTests>!
                var label: UILabel!
                
                beforeEach {
                    set = BindingSet(self)
                    label = UILabel()
                }
                
                context("INT") {
                
                    it("should set inital 5 value") {
                        let variable = Dynamic<Int>(5)

                        set.bind(variable)
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("5"))
                    }
                    
                    it("should set inital 5 value from Optional") {
                        let variable = Dynamic<Int?>(5)

                        set.bind(variable, fallbackValue: 0)
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("5"))
                    }
                    
                    it("should set default next value") {
                        let variable = Dynamic<Int?>(nil)

                        set.bind(variable, fallbackValue: 0)
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("0"))
                    }
                    
                    it("should set fallback next value") {
                        let variable = Dynamic<Int?>(nil)
                        
                        set.bind(variable, fallbackValue: 2319)
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("2319"))
                    }
                }
                
                context("CONVERTER") {
                    
                    it("should set inital 5 value") {
                        let variable = Dynamic<Int>(5)
                        
                        set.bind(variable)
                            .withConverter(IntConverter())
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("(5)"))
                    }
                    
                    it("should set inital 5 value from Optional") {
                        let variable = Dynamic<Int?>(5)
                        
                        set.bind(variable, fallbackValue: 2319)
                            .withConverter(IntConverter())
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("(5)"))
                    }
                    
                    it("should set default next value") {
                        let variable = Dynamic<Int?>(nil)
                        
                        set.bind(variable, fallbackValue: 2319)
                            .withConverter(IntConverter())
                            .to(label)
                            .apply()
                        
                        expect(label.text).to(equal("(2319)"))
                    }
                }
                
                context("DISPOSE") {
                    
                    it("should dispose simple sequence") {
                        let variable = Dynamic<String>("value")
                        
                        set.bind(variable)
                            .to(label)
                            .apply()
                            .dispose()
                        
                        variable.value = "newValue"
                        
                        expect(label.text).to(equal("value"))
                    }
                    
                    it("should dispose converter value") {
                        let variable = Dynamic<Int?>(5)
                        
                        set.bind(variable, fallbackValue: 2319)
                            .withConverter(IntConverter())
                            .to(label)
                            .apply()
                            .dispose()
                        
                        variable.value = 222
                        
                        expect(label.text).to(equal("(5)"))
                    }
                }
            }
        }
    }
}
