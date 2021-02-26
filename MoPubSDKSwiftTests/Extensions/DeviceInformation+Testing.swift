//
//  DeviceInformation+Testing.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import CoreLocation
@testable import MoPubSDK

// MARK: - Connectivity
public extension DeviceInformation {
    @objc static var mockCellularService: CellularService?
    
    @_dynamicReplacement(for: cellularService)
    static var swizzle_cellularService: CellularService? {
        return mockCellularService
    }
    
    static var mockReachability: NetworkReachable?
    
    @_dynamicReplacement(for: reachability)
    static var swizzle_reachability: NetworkReachable? {
        return mockReachability
    }
}

// MARK: - Location
public extension DeviceInformation {    
    @_dynamicReplacement(for: applicationVersion)
    @objc static var swizzle_applicationVersion: String? {
        // The main bundle's info plist does not have a version when testing.
        return "5.0.0"
    }
    
    @objc static var mockLocationManagerLocationServiceEnabled = true
    
    @_dynamicReplacement(for: locationManagerLocationServiceEnabled)
    static var swizzle_locationManagerLocationServiceEnabled: Bool {
        return mockLocationManagerLocationServiceEnabled
    }
    
    @objc static var mockLocationManagerAuthorizationStatus = CLAuthorizationStatus.notDetermined

    @_dynamicReplacement(for: locationManagerAuthorizationStatus)
    static var swizzle_locationManagerAuthorizationStatus: CLAuthorizationStatus {
        return mockLocationManagerAuthorizationStatus
    }
    
    @objc static var mockLocationManager = CLLocationManager()
    
    @_dynamicReplacement(for: locationManager)
    static var swizzle_locationManager: CLLocationManager {
        return mockLocationManager
    }
    
    // Obj-C versions so that we don't have to make these public.
    @objc static func objc_clearCachedLastLocation() {
        clearCachedLastLocation()
    }
}
