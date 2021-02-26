//
//  ATSSettingTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class ATSSettingTests: XCTestCase {
    func testEmpty() {
        let setting = ATSSetting.setting(from: [:])
        XCTAssertFalse(setting.contains(.allowsArbitraryLoads))
        XCTAssertFalse(setting.contains(.allowsArbitraryLoadsForMedia))
        XCTAssertFalse(setting.contains(.allowsArbitraryLoadsInWebContent))
        XCTAssertFalse(setting.contains(.requiresCertificateTransparency))
        XCTAssertFalse(setting.contains(.allowsLocalNetworking))
        XCTAssertEqual(setting, .enabled)
    }
    
    func testAllowsArbitraryLoads() {
        let setting = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true])
        XCTAssertEqual(setting, .allowsArbitraryLoads)
    }
    
    func testMultiple() {
        let setting = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                "NSAllowsArbitraryLoadsForMedia": true,
                                                "NSAllowsArbitraryLoadsInWebContent": true,
                                                "NSAllowsLocalNetworking": true,
                                                "NSRequiresCertificateTransparency": true])
        XCTAssertFalse(setting.contains(.allowsArbitraryLoads))
        XCTAssertTrue(setting.contains(.allowsArbitraryLoadsForMedia))
        XCTAssertTrue(setting.contains(.allowsArbitraryLoadsInWebContent))
        XCTAssertTrue(setting.contains(.requiresCertificateTransparency))
        XCTAssertTrue(setting.contains(.allowsLocalNetworking))
    }

    func testRemovesArbitraryLoadsWhenMediaExists() {
        let setting = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                "NSAllowsArbitraryLoadsForMedia": true])
        XCTAssertFalse(setting.contains(.allowsArbitraryLoads))
        XCTAssertTrue(setting.contains(.allowsArbitraryLoadsForMedia))
        
        // Allow arbitrary loads should be removed even if NSAllowsArbitraryLoadsForMedia
        // is false.
        let setting2 = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                 "NSAllowsArbitraryLoadsForMedia": false])
        XCTAssertFalse(setting2.contains(.allowsArbitraryLoads))
        XCTAssertFalse(setting2.contains(.allowsArbitraryLoadsForMedia))
    }
    
    func testRemovesArbitraryLoadsWhenWebContentExists() {
        let setting = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                "NSAllowsArbitraryLoadsInWebContent": true])
        XCTAssertFalse(setting.contains(.allowsArbitraryLoads))
        XCTAssertTrue(setting.contains(.allowsArbitraryLoadsInWebContent))
        
        let setting2 = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                 "NSAllowsArbitraryLoadsInWebContent": false])
        XCTAssertFalse(setting2.contains(.allowsArbitraryLoads))
        XCTAssertFalse(setting2.contains(.allowsArbitraryLoadsInWebContent))
    }
    
    func testRemovesArbitraryLoadsWhenLocalNetworkingExists() {
        let setting = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                "NSAllowsLocalNetworking": true])
        XCTAssertFalse(setting.contains(.allowsArbitraryLoads))
        XCTAssertTrue(setting.contains(.allowsLocalNetworking))
        
        let setting2 = ATSSetting.setting(from: ["NSAllowsArbitraryLoads": true,
                                                 "NSAllowsLocalNetworking": false])
        XCTAssertFalse(setting2.contains(.allowsArbitraryLoads))
        XCTAssertFalse(setting2.contains(.allowsLocalNetworking))
    }
}
