//
//  MockCellularService.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

// In order to get access to our code, without having to make all
// of our types and functions public, we can use the @testable
// keyword to also import all internal symbols from our app target.
@testable import MoPubSDK

class MockCellularService: CellularService {
    var mockCurrentRadioAccessTechnology: NetworkStatus = .notReachable
    
    convenience init(carrier: CTCarrier = CTCarrier(), key: String? = nil, currentRadioAccessTechnology: NetworkStatus) {
        self.init(carrier: carrier, key: key)
        mockCurrentRadioAccessTechnology = currentRadioAccessTechnology
    }

    override var currentRadioAccessTechnology: NetworkStatus {
        get {
            return mockCurrentRadioAccessTechnology
        }
    }
}
