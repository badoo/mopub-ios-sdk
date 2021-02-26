//
//  DeviceInformationTests.swift
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

class DeviceInformationTests: XCTestCase {

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.notReachable` if `reachabilityFlags` does not include `.reachable` and the `CellularService` instance returns `.notReachable`
    func testCurrentNetworkStatusNotReachable() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .notReachable)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .notReachable)
    }
    
    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.notReachable` if `reachabilityFlags` does not include `.reachable` even though the `CellularService` instance returns `.reachableViaWiFi`
    func testCurrentNetworkStatusNotReachableWhenUsingWiFi() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaWiFi)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .notReachable)
    }
    
    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaWiFi` only when `reachabilityFlags` includes `.reachable` and the `CellularService` instance returns `.reachableViaWiFi`
    func testCurrentNetworkStatusReachableViaWiFi() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaWiFi)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaWiFi)
    }
    
    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetworkUnknownGeneration` only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetworkUnknownGeneration`
    func testCurrentNetworkStatusReachableViaUnknownGeneration() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetworkUnknownGeneration)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetworkUnknownGeneration)
    }
    
    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetwork2G` only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetwork2G`
    func testCurrentNetworkStatusReachableViaCellularNetwork2G() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetwork2G)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetwork2G)
    }
    
    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetwork3G` only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetwork3G`
    func testCurrentNetworkStatusReachableViaCellularNetwork3G() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetwork3G)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetwork3G)
    }
    
    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetwork4G` only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetwork4G`
    func testCurrentNetworkStatusReachableViaCellularNetwork4G() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetwork4G)
        
        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetwork4G)
    }
}
