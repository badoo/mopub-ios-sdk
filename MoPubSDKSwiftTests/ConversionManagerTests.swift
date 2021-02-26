//
//  ConversionManagerTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest

// In order to get access to our code, without having to make all
// of our types and functions public, we can use the @testable
// keyword to also import all internal symbols from our app target.
@testable import MoPubSDK

class ConversionManagerTests: XCTestCase {
    // MARK: - UserDefaults Keys
    
    struct UserDefaultsKey {
        /// This must correspond to the `UserDefaults` key used for the `appId` property wrapper.
        static let appId: String = "com.mopub.conversion.appId"
        
        /// This must correspond to the
        static let isConversionAlreadyTracked: String = "com.mopub.conversion"
    }
    
    // MARK: - Constants
    
    struct Constants {
        /// 10 second test timeout.
        static let timeout: TimeInterval = 10.0
    }

    // MARK: - Test Setup
    
    override func setUpWithError() throws {
        // Make sure the UserDefaults entries are removed
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.appId)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.isConversionAlreadyTracked)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - State
    
    /// Verifies that the `appId` property is stored in `UserDefaults` properly.
    func testSetAppId() throws {
        // Preconditions
        let fakeAppId: String = "1234567890"
        let standardDefaults = UserDefaults.standard
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.appId))
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.isConversionAlreadyTracked))
        
        // Track conversion.
        ConversionManager.setConversionAppId(fakeAppId)
        
        // Verify
        guard let retrievedAppId = standardDefaults.string(forKey: UserDefaultsKey.appId) else {
            XCTFail("Retrieved `appId` is nil")
            return
        }
        
        XCTAssertTrue(retrievedAppId == fakeAppId)
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.isConversionAlreadyTracked))
    }

    // MARK: - Tracking
    
    func testNoConversionWhenNoAppId() throws {
        // Preconditions
        let standardDefaults = UserDefaults.standard
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.appId))
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.isConversionAlreadyTracked))
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Track conversion")
        
        // Set the app ID used for conversion tracking.
        ConversionManager.trackConversion() { result in
            if case .failure(ConversionTrackingError.noApplicationIdSpecified) = result {
                expectation.fulfill()
            }
        }
        
        // Wait for asynchronous response
        wait(for: [expectation], timeout: Constants.timeout)
        
        // Verify
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.appId))
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.isConversionAlreadyTracked))
    }
    
    func testNoConversionWhenAlreadyTracked() throws {
        // Preconditions
        let fakeAppId: String = "1234567890"
        
        // Preload an already tracked state.
        let standardDefaults = UserDefaults.standard
        standardDefaults.setValue(fakeAppId, forKey: UserDefaultsKey.appId)
        standardDefaults.setValue(true, forKey: UserDefaultsKey.isConversionAlreadyTracked)
        XCTAssertNotNil(standardDefaults.string(forKey: UserDefaultsKey.appId))
        XCTAssertTrue(standardDefaults.bool(forKey: UserDefaultsKey.isConversionAlreadyTracked))
        
        // Create an expectation for a background download task.
        // Expectation is inverted since we are expecting the the callback to
        // not be called.
        let expectation = XCTestExpectation(description: "Track conversion")
        expectation.isInverted = true
        
        // Set the app ID used for conversion tracking.
        ConversionManager.trackConversion() { error in
            expectation.fulfill()
        }
        
        // Wait for asynchronous response
        wait(for: [expectation], timeout: Constants.timeout)
        
        // Verify
        guard let retrievedAppId = standardDefaults.string(forKey: UserDefaultsKey.appId) else {
            XCTFail("Retrieved `appId` is nil")
            return
        }
        
        XCTAssertTrue(retrievedAppId == fakeAppId)
        XCTAssertTrue(standardDefaults.bool(forKey: UserDefaultsKey.isConversionAlreadyTracked))
    }
    
    func testConversionSuccess() throws {
        // Preconditions
        let fakeAppId: String = "1234567890"
        let standardDefaults = UserDefaults.standard
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.appId))
        XCTAssertNil(standardDefaults.object(forKey: UserDefaultsKey.isConversionAlreadyTracked))
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Track conversion")
        
        // Set the app ID and track conversion.
        ConversionManager.setConversionAppId(fakeAppId)
        ConversionManager.trackConversion() { result in
            guard case .success = result else {
                return
            }
            
            expectation.fulfill()
        }
        
        // Wait for asynchronous response
        wait(for: [expectation], timeout: Constants.timeout)
        
        // Verify
        guard let retrievedAppId = standardDefaults.string(forKey: UserDefaultsKey.appId) else {
            XCTFail("Retrieved `appId` is nil")
            return
        }
        
        XCTAssertTrue(retrievedAppId == fakeAppId)
        XCTAssertTrue(standardDefaults.bool(forKey: UserDefaultsKey.isConversionAlreadyTracked))
    }
}
