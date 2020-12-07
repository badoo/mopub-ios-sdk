//
//  XCTestCaseExtensions.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import XCTest

extension XCTestCase {
    func data(from filename: String, fileExtension: String) -> Data? {
        let fullFilename = "\(filename).\(fileExtension)"
        return XCTContext.runActivity(named: "Load \(fullFilename)") { _ in
            guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: fileExtension) else {
                XCTFail("Cannot find \(fullFilename)")
                return nil
            }
            guard let data = try? Data(contentsOf: url) else {
                XCTFail("Could not load \(fullFilename)")
                return nil
            }
            return data
        }
    }
}
