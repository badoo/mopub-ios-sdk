//
//  APIEndpointsTests.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPub

class APIEndpointsTests: XCTestCase {

    override func setUp() {
        APIEndpoints.baseHostname = APIEndpoints.defaultBaseHostname
    }
    
    func testDefaultHostname() {
        XCTAssertEqual(APIEndpoints.baseHostname, "ads.mopub.com")
        XCTAssertEqual(APIEndpoints.baseURL?.absoluteString, "https://ads.mopub.com")
    }
    
    func testSetEmptyHostname() {
        APIEndpoints.baseHostname = ""
        XCTAssertEqual(APIEndpoints.baseHostname, "ads.mopub.com")
        
        APIEndpoints.baseHostname = " "
        XCTAssertEqual(APIEndpoints.baseHostname, "ads.mopub.com")
        
        APIEndpoints.baseHostname = "\n"
        XCTAssertEqual(APIEndpoints.baseHostname, "ads.mopub.com")
        
        APIEndpoints.baseHostname = "\t"
        XCTAssertEqual(APIEndpoints.baseHostname, "ads.mopub.com")
    }
    
    func testSetBaseHostname() {
        APIEndpoints.baseHostname = "test.hostname"
        
        XCTAssertEqual(APIEndpoints.baseHostname, "test.hostname")
        XCTAssertEqual(APIEndpoints.baseURL?.absoluteString, "https://test.hostname")
        XCTAssertEqual(APIEndpoints.baseURLComponents(with: .open).url?.absoluteString, "https://test.hostname/m/open")
    }
    
    func testPaths() {
        XCTAssertEqual(APIEndpoints.baseURLComponents(with: .adRequest).url?.absoluteString, "https://ads.mopub.com/m/ad")
        XCTAssertEqual(APIEndpoints.baseURLComponents(with: .nativePositioning).url?.absoluteString, "https://ads.mopub.com/m/pos")
        XCTAssertEqual(APIEndpoints.baseURLComponents(with: .open).url?.absoluteString, "https://ads.mopub.com/m/open")
        XCTAssertEqual(APIEndpoints.baseURLComponents(with: .consentDialog).url?.absoluteString, "https://ads.mopub.com/m/gdpr_consent_dialog")
        XCTAssertEqual(APIEndpoints.baseURLComponents(with: .consentSync).url?.absoluteString, "https://ads.mopub.com/m/gdpr_sync")
    }
    
    func testObjcFunctions() {
        XCTAssertEqual(APIEndpoints.adRequestURLComponents.url?.absoluteString, "https://ads.mopub.com/m/ad")
        XCTAssertEqual(APIEndpoints.nativePositioningURLComponents.url?.absoluteString, "https://ads.mopub.com/m/pos")
        XCTAssertEqual(APIEndpoints.openURLComponents.url?.absoluteString, "https://ads.mopub.com/m/open")
        XCTAssertEqual(APIEndpoints.consentDialogURLComponents.url?.absoluteString, "https://ads.mopub.com/m/gdpr_consent_dialog")
        XCTAssertEqual(APIEndpoints.consentSyncURLComponents.url?.absoluteString, "https://ads.mopub.com/m/gdpr_sync")
    }

    func testCallbackPaths() {
        XCTAssertEqual(APIEndpoints.callbackBaseURLComponents(with: .skAdNetworkSync).url?.absoluteString, "https://cb.mopub.com/supported_ad_partners")
    }
    
    func testObjcCallbackFunctions() {
        XCTAssertEqual(APIEndpoints.skAdNetworkSyncURLComponents.url?.absoluteString, "https://cb.mopub.com/supported_ad_partners")
    }
}
