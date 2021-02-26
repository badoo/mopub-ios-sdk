//
//  ImageCreatorTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class ImageCreatorTests: XCTestCase {
    
    struct Constants {
        static let epislon = 0.001
    }
    
    func testInvalidData() {
        let data = Data()
        let image = ImageCreator.image(with: data)
        XCTAssertNil(image)
    }

    func testStaticImage() {
        guard let data = data(from: "static", fileExtension: "png") else {
            return
        }
        
        guard let image = ImageCreator.image(with: data) else {
            XCTFail("Failed to create image")
            return
        }
        
        XCTAssertEqual(image.size.width, 1)
        XCTAssertEqual(image.size.height, 1)
        XCTAssertNil(image.images)
        XCTAssertEqual(image.duration, 0.0, accuracy: Constants.epislon)
    }
    
    func testGIF() {
        guard let data = data(from: "animated", fileExtension: "gif") else {
            return
        }
        
        guard let image = ImageCreator.image(with: data) else {
            XCTFail("Failed to create image")
            return
        }
        
        guard let images = image.images else {
            XCTFail("No animation images in the image")
            return
        }
        
        XCTAssertEqual(image.size.width, 1)
        XCTAssertEqual(image.size.height, 1)
        
        // This gif is 10 frames at 24 FPS (delay of 0.04)
        XCTAssertEqual(images.count, 10)
        XCTAssertEqual(image.duration, 0.40, accuracy: Constants.epislon)
    }
    
    func testGIFClamping() {
        guard let data = data(from: "animated_unclamped", fileExtension: "gif") else {
            return
        }
        
        guard let image = ImageCreator.image(with: data) else {
            XCTFail("Failed to create image")
            return
        }
        
        guard let images = image.images else {
            XCTFail("No animation images in the image")
            return
        }
        
        XCTAssertEqual(image.size.width, 1)
        XCTAssertEqual(image.size.height, 1)
        
        // This gif is 10 frames but specifies 100 FPS which is too fast.
        // so it will be clamped to 10 FPS.
        XCTAssertEqual(images.count, 10)
        XCTAssertEqual(image.duration, 1.0, accuracy: Constants.epislon)
    }
}
