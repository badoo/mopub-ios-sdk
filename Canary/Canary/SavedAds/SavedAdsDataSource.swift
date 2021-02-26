//
//  SavedAdsDataSource.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Saved ad units data source
 */
final class SavedAdsDataSource: AdUnitDataSource {
    private enum Section: Int {
        case savedAds
        case loadedAds
        
        var title: String {
            switch self {
            case .savedAds:
                return "Saved Ads"
            case .loadedAds:
                return "Loaded Ads"
            }
        }
    }
    
    // MARK: - Overrides
    
    /**
     Initializes the data source with an optional plist file.
     - Parameter plistName: Name of a plist file (without the extension) to initialize the
     data source.
     - Parameter bundle: Bundle where the plist file lives.
     */
    required init(plistName: String = "", bundle: Bundle = Bundle.main) {
        super.init(plistName: plistName, bundle: bundle)
        reloadData()
    }
    
    /**
     Reloads the data source.
     */
    override func reloadData() {
        self.adUnits = [Section.savedAds.title: SavedAdsManager.sharedInstance.savedAds,
                        Section.loadedAds.title: SavedAdsManager.sharedInstance.loadedAds]
    }
    
    /**
     Data source sections as human readable text meant for display as section headings to the user.
     */
    override var sections: [String] {
        return [Section.savedAds.title, Section.loadedAds.title]
    }
    
    /**
     Removes an item if supported.
     */
    override func removeItem(at indexPath: IndexPath) -> AdUnit? {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure("Unexpected section index: \(indexPath.section)")
            return nil
        }
        
        guard let adUnit: AdUnit = adUnits[section.title]?[indexPath.row] else {
            assertionFailure("Ad unit not found in index path [\(indexPath.section), \(indexPath.row)]")
            return nil
        }
        
        switch section {
        case .savedAds:
            // Remove the ad unit entry
            SavedAdsManager.sharedInstance.removeSavedAd(adUnit: adUnit)
        case .loadedAds:
            // Remove the ad unit entry
            SavedAdsManager.sharedInstance.removeLoadedAds(adUnit: adUnit)
        }
        
        // Reload the internal state
        reloadData()
        
        return adUnit
    }
}
