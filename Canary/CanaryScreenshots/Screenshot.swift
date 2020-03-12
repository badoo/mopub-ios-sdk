//
//  Screenshot.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Screenshot names that will be taken. When uploaded to the AppStore,
 they are uploaded in alphabetical order.
 */
enum Screenshot: CustomStringConvertible {
    case screen1
    case screen2
    case screen3
    case screen4
    case screen5
    
    // MARK: - CustomStringConvertible
    var description: String {
        switch self {
        case .screen1: return "screen01"
        case .screen2: return "screen02"
        case .screen3: return "screen03"
        case .screen4: return "screen04"
        case .screen5: return "screen05"
        }
    }
}
