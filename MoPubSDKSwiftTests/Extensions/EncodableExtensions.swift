//
//  EncodableExtensions.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/// Add a getter for JSON-encoded data
extension Encodable {
    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }
}
