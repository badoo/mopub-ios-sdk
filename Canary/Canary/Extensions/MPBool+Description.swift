//
//  MPBool+Description.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPubSDK

public extension MPBool {
    var description: String {
        switch self {
        case .unknown: return "unknown"
        case .yes: return "true"
        case .no: return "false"
        @unknown default: fatalError("\(#function) unexpected enum case")
        }
    }
}
