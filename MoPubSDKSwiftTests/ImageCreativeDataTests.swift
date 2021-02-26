//
//  ImageCreativeDataTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest

@testable import MoPubSDK

class ImageCreativeDataTests: XCTestCase {
    
    /// Tests that json with a valid image URL and a valid clickthrough URL parses correctly
    func testValidDataWithClickthrough() {
        // Set up test data
        let testCreativeURLString = "https://www.mopub.com/etc/designs/mopub-aem-twitter/public/svg/mopub.svg"
        let testClickthroughURLString = "https://google.com"
        let testDict = [
            "image": testCreativeURLString,
            "clk": testClickthroughURLString
        ]
        let data = testDict.jsonData
        
        // Make image creative data from test data
        guard let imageCreativeData = ImageCreativeData(withServerResponseData: data) else {
            XCTAssert(false)
            return
        }
        
        // Test creative URL parsed correctly
        XCTAssertEqual(imageCreativeData.imageURL, URL(string: testCreativeURLString)!)
        
        // Get non-nil clickthrough URL from test data
        guard let clickthroughURL = imageCreativeData.clickthroughURL else {
            XCTAssert(false)
            return
        }
        
        // Test clickthrough URL parsed correctly
        XCTAssertEqual(clickthroughURL, URL(string: testClickthroughURLString)!)
    }
    
    /// Tests that json with a valid image URL and an empty string clickthrough URL parses correctly
    func testValidDataWithEmptyStringClickthrough() {
        // Set up test data
        let testCreativeURLString = "https://www.mopub.com/etc/designs/mopub-aem-twitter/public/svg/mopub.svg"
        let testClickthroughURLString = ""
        let testDict = [
            "image": testCreativeURLString,
            "clk": testClickthroughURLString
        ]
        let data = testDict.jsonData
        
        // Make image creative data from test data
        guard let imageCreativeData = ImageCreativeData(withServerResponseData: data) else {
            XCTAssert(false)
            return
        }
        
        // Test creative URL parsed correctly
        XCTAssertEqual(imageCreativeData.imageURL, URL(string: testCreativeURLString)!)
        
        // Test clickthrough URL is nil
        XCTAssertNil(imageCreativeData.clickthroughURL)
    }
    
    /// Tests that json with a valid image URL and no clickthrough URL parses correctly
    func testValidDataWithNoClickthrough() {
        // Set up test data
        let testCreativeURLString = "https://www.mopub.com/etc/designs/mopub-aem-twitter/public/svg/mopub.svg"
        let testDict = [
            "image": testCreativeURLString,
        ]
        let data = testDict.jsonData
        
        // Make image creative data from test data
        guard let imageCreativeData = ImageCreativeData(withServerResponseData: data) else {
            XCTAssert(false)
            return
        }
        
        // Test creative URL parsed correctly
        XCTAssertEqual(imageCreativeData.imageURL, URL(string: testCreativeURLString)!)
        
        // Test clickthrough URL is nil
        XCTAssertNil(imageCreativeData.clickthroughURL)
    }
    
    /// Tests that json without a valid image URL does not parse
    func testInvalidCreativeURLResultsInNilImageCreativeData() {
        // Set up test data
        let testCreativeURLString = ""
        let testClickthroughURLString = "https://google.com"
        let testDict = [
            "image": testCreativeURLString,
            "clk": testClickthroughURLString
        ]
        let data = testDict.jsonData
        
        // Make image creative data from test data
        let imageCreativeData = ImageCreativeData(withServerResponseData: data)
        
        // Test creative data is nil
        XCTAssertNil(imageCreativeData)
    }
    
    /// Tests that json without any image URL does not parse
    func testNoCreativeURLResultsInNilImageCreativeData() {
        // Set up test data
        let testClickthroughURLString = "https://google.com"
        let testDict = [
            "clk": testClickthroughURLString
        ]
        let data = testDict.jsonData
        
        // Make image creative data from test data
        let imageCreativeData = ImageCreativeData(withServerResponseData: data)
        
        // Test creative data is nil
        XCTAssertNil(imageCreativeData)
    }
    
}
