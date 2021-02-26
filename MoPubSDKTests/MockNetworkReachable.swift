//
//  MockNetworkReachable.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import SystemConfiguration

// In order to get access to our code, without having to make all
// of our types and functions public, we can use the @testable
// keyword to also import all internal symbols from our app target.
@testable import MoPubSDK

class MockNetworkReachable: NetworkReachable {
    var reachabilityFlags: SCNetworkReachabilityFlags = .reachable
    
    init(_ reachabilityFlags: SCNetworkReachabilityFlags) {
        self.reachabilityFlags = reachabilityFlags
    }
}
