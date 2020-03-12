//
//  XCTestCase+Waiting.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest

extension XCTestCase {
    /**
     Default timeout values specifically for the waiting methods.
     */
    struct Timeout {
        static let elementAppear: TimeInterval = 30
        static let elementHighlight: TimeInterval = 30
    }
    
    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = Timeout.elementAppear) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let elementExpectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
        
        let result = XCTWaiter().wait(for: [elementExpectation], timeout: timeout)
        return result == .completed
    }
    
    func waitForElementToHighlight(_ element: XCUIElement, timeout: TimeInterval = Timeout.elementHighlight) -> Bool {
        let predicate = NSPredicate(format: "exists == true and isSelected == true")
        let elementExpectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
        
        let result = XCTWaiter().wait(for: [elementExpectation], timeout: timeout)
        return result == .completed
    }
}
