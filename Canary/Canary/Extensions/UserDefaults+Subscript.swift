//
//  UserDefaults+Subscript.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

// MARK: - Subscript support

extension UserDefaults {
    /**
     A generic key that enables value type and default value specification.
     */
    struct Key<ValueType> {
        /**
         This `String` representation of the key.
         */
        let stringValue: String
        
        /**
         If the value does not exist in `UserDefaults`, return this default value instead.
         */
        let defaultValue: ValueType
        
        init(_ stringValue: String, defaultValue: ValueType) {
            self.stringValue = stringValue
            self.defaultValue = defaultValue
        }
    }
    
    subscript<T>(key: Key<T>) -> T {
        get {
            return value(forKey: key.stringValue) as? T ?? key.defaultValue
        }
        set {
            set(newValue, forKey: key.stringValue)
        }
    }
}

// MARK: - UserDefaults with subscript

extension UserDefaults {
    /**
     The private `UserDefaults.Key` for accessing `shouldClearCachedNetworks`.
     */
    private var shouldClearCachedNetworksKey: Key<Bool> {
        return Key<Bool>("shouldClearCachedNetworks", defaultValue: false)
    }
    
    /**
     If `true`, call `MoPub.sharedInstance().clearCachedNetworks()` before initializing the MoPub SDK;
     otherwise, do nothing.
     */
    var shouldClearCachedNetworks: Bool {
        get {
            return self[shouldClearCachedNetworksKey]
        }
        set {
            self[shouldClearCachedNetworksKey] = newValue
        }
    }
    
    /**
     The private `UserDefaults.Key` for accessing `cachedAdUnitId`.
     */
    private var cachedAdUnitIdKey: Key<String?> {
        return Key<String?>("cachedAdUnitIdKey", defaultValue: nil)
    }
    
    /**
     Cached ad unit ID used for MoPub SDK initialization
     */
    var cachedAdUnitId: String? {
        get {
            return self[cachedAdUnitIdKey]
        }
        set {
            guard let adUnitId = newValue else {
                self.removeObject(forKey: cachedAdUnitIdKey.stringValue)
                return
            }
            
            self[cachedAdUnitIdKey] = adUnitId
        }
    }

    /**
     The private `UserDefaults.Key` for accessing `loadedAds`.
     */
    private var loadedAdsKey: Key<Data> {
        return Key<Data>("loadedAdsKey", defaultValue: Data())
    }
    
    /**
     Ad unit ID's that have been loaded in history.
     */
    var loadedAds: [AdUnit] {
        get {
            guard let history = try? JSONDecoder().decode([AdUnit].self, from: self[loadedAdsKey]) else {
                return []
            }
            return history
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                assertionFailure()
                return
            }
            self[loadedAdsKey] = data
        }
    }
}
