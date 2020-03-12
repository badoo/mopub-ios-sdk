//
//  CanaryScreenshots.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest

class CanaryScreenshots: XCTestCase {

    override func setUp() {
        let app = XCUIApplication()
        
        // Configure Fastlane snapshot tool.
        setupSnapshot(app)
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadNative() {
        let app = XCUIApplication()
        
        // Navigate to the Sample Ads tab
        app.tabBars.buttons["Sample Ads"].tap()
        snapshot("\(Screenshot.screen1)")
        
        // Navigate to Native sample ad and load.
        app.cells.staticTexts["Native"].tap()
        app.buttons.element(matching: .button, identifier: AccessibilityIdentifier.adActionsLoad).tap()
        
        // Wait for native ad to load
        let adLoaded = waitForElementToHighlight(app.cells.element(matching: .cell, identifier: CallbackFunctionNames.nativeAdDidLoad))
        XCTAssert(adLoaded)
        
        let imagesLoaded = waitForElementToAppear(app.images.element(matching: .image, identifier: AccessibilityIdentifier.nativeAdImageView))
        XCTAssert(imagesLoaded)
        snapshot("\(Screenshot.screen2)")
    }
    
    func testLoadInterstitial() {
        let app = XCUIApplication()
        
        // Navigate to the Sample Ads tab
        app.tabBars.buttons["Sample Ads"].tap()
        
        // Navigate to HTML interstitial sample ad and load.
        app.cells.staticTexts["HTML Interstitial"].tap()
        app.buttons.element(matching: .button, identifier: AccessibilityIdentifier.adActionsLoad).tap()
        
        // Wait for interstitial ad to load
        let adLoaded = waitForElementToHighlight(app.cells.element(matching: .cell, identifier: CallbackFunctionNames.interstitialDidLoadAd))
        XCTAssert(adLoaded)
        
        // Show the ad
        app.buttons.element(matching: .button, identifier: AccessibilityIdentifier.adActionsShow).tap()
        snapshot("\(Screenshot.screen3)")
    }
}
