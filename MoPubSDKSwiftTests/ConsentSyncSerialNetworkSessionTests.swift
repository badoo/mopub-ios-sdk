//
//  ConsentSyncSerialNetworkSessionTests.swift
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

class ConsentSyncSerialNetworkSessionTests: XCTestCase {
    
    // MARK: - Constants
    
    struct Constants {
        /// 2 second test timeout.
        static let timeout: TimeInterval = 2.0
    }

    // MARK: - Test Setup

    override func setUp() {
        // Reset `taskStarted`
        let mockNetworkSession = MockHTTPNetworkSession.self
        mockNetworkSession.requestsStarted.removeAll()
    }
    
    // MARK: - Tests

    /// Tests to make sure a standard network request will be performed
    func testSingleNetworkRequestAttempt() {
        // Mock comparator to determine if the requests are equivalent
        let mockComparator = MockURLRequestComparator()
        
        // Mock network session interface for performing the underlying requests
        let mockNetworkSession = MockHTTPNetworkSession.self
        
        // Create the `ConsentSyncSerialNetworkSession` instance
        let session = ConsentSyncSerialNetworkSession(comparator: mockComparator, networkSession: mockNetworkSession)
        
        // Create an expectation for the asyncronous response
        let expectation = XCTestExpectation(description: "Request completed")
        
        // Request to be attempted
        let request = MPURLRequest(url: URL(string: "https://twitter.com")!)
        
        // Attempt to perform the request
        session.attemptTask(with: request) { (data, response) in
            // Fulfill the expectation
            expectation.fulfill()
        } errorHandler: { _ in }
        
        // Wait for asynchronous response
        wait(for: [expectation], timeout: Constants.timeout)
        
        // The request should have been started by the underlying networking session
        XCTAssertTrue(mockNetworkSession.requestsStarted.contains(request as URLRequest))
    }
    
    /// Tests to make sure two non-duplicate requests will be performed
    func testDifferentNetworkRequestsAttempt() {
        // Mock comparator to determine if the requests are equivalent
        let mockComparator = MockURLRequestComparator()
        
        // Mock network session interface for performing the underlying requests
        let mockNetworkSession = MockHTTPNetworkSession.self
        
        // Create the `ConsentSyncSerialNetworkSession` instance
        let session = ConsentSyncSerialNetworkSession(comparator: mockComparator, networkSession: mockNetworkSession)
        
        // Create the expectations for the asyncronous responses
        let expectation1 = XCTestExpectation(description: "First request completed")
        let expectation2 = XCTestExpectation(description: "Second request completed")
        
        // Requests to be attempted (note: only the URL hosts are used by the `MockURLRequestComparator` for determining equality)
        let request1 = MPURLRequest(url: URL(string: "https://twitter.com/?id=1")!)
        let request2 = MPURLRequest(url: URL(string: "https://apple.com/?id=2")!)
        
        // Attempt to perform the first request
        session.attemptTask(with: request1) { (data, response) in
            // Fulfill the expectation
            expectation1.fulfill()
        } errorHandler: { _ in }
        
        // Attempt to perform the second request
        session.attemptTask(with: request2) { (data, response) in
            // Fulfill the expectation
            expectation2.fulfill()
        } errorHandler: { _ in }
        
        // Wait for asynchronous responses
        wait(for: [expectation1, expectation2], timeout: Constants.timeout, enforceOrder: true)
        
        // request1 should have been started by the underlying networking session
        XCTAssertTrue(mockNetworkSession.requestsStarted.contains(request1 as URLRequest))
        
        // request2 should have been started by the underlying networking session
        XCTAssertTrue(mockNetworkSession.requestsStarted.contains(request2 as URLRequest))
    }
    
    /// Tests to make sure two duplicate requests in succession will not be performed
    func testIdenticalNetworkRequestAttempts() {
        // Mock comparator to determine if the requests are equivalent
        let mockComparator = MockURLRequestComparator()
        
        // Mock network session interface for performing the underlying requests
        let mockNetworkSession = MockHTTPNetworkSession.self
        
        // Create the `ConsentSyncSerialNetworkSession` instance
        let session = ConsentSyncSerialNetworkSession(comparator: mockComparator, networkSession: mockNetworkSession)
        
        // Create the expectations for the asyncronous responses
        let expectation1 = XCTestExpectation(description: "First request completed")
        
        // Expectation is inverted because we expect it to not be called
        let expectation2 = XCTestExpectation(description: "Second request completed")
        expectation2.isInverted = true
        
        // Requests to be attempted (note: only the URL hosts are used by the `MockURLRequestComparator` for determining equality)
        let request1 = MPURLRequest(url: URL(string: "https://twitter.com/?id=1")!)
        let request2 = MPURLRequest(url: URL(string: "https://twitter.com/?id=2")!)
        
        // Attempt to perform the first request
        session.attemptTask(with: request1) { (data, response) in
            // Fulfill the expectation
            expectation1.fulfill()
        } errorHandler: { _ in }
        
        // Attempt to perform the second request
        session.attemptTask(with: request2) { (data, response) in
            // Fulfill the expectation
            expectation2.fulfill()
        } errorHandler: { _ in }
        
        // Wait for asynchronous responses
        wait(for: [expectation1, expectation2], timeout: Constants.timeout, enforceOrder: true)
        
        // request1 should have been started by the underlying networking session
        XCTAssertTrue(mockNetworkSession.requestsStarted.contains(request1 as URLRequest))
        
        // request2 should not have been started by the underlying networking session
        XCTAssertFalse(mockNetworkSession.requestsStarted.contains(request2 as URLRequest))
    }
}

class MockHTTPNetworkSession: MPHTTPNetworkSession {
    /// Keep track of all requests started on this underlying network session
    static var requestsStarted = [URLRequest]()
    
    override class func startTask(withHttpRequest request: URLRequest, responseHandler: ((Data, HTTPURLResponse) -> Void)?, errorHandler: ((Error) -> Void)? = nil) -> URLSessionTask {
        // Keep track of the requests started on this `MPHTTPNetworkSession` instance
        requestsStarted.append(request)
        
        // Invoke the response handler
        responseHandler?(Data(), HTTPURLResponse())
        
        // Return unused URLSessionTask
        return URLSession.shared.dataTask(with: request)
    }
}

class MockURLRequestComparator: URLRequestComparable {
    func isRequest(_ urlRequest1: MPURLRequest?, duplicateOf urlRequest2: MPURLRequest?) -> Bool {
        // Simply comparing on host of the URL so we can do proper assertion checking in test cases
        return urlRequest1?.url?.host == urlRequest2?.url?.host
    }
}
