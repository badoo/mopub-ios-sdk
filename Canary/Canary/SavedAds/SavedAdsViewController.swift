//
//  SavedAdsViewController.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

final class SavedAdsViewController: AdUnitTableViewController {
    private var notificationTokens = [Notification.Token]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        // Initialize the data source before invoking the base class's `viewDidLoad()` method.
        super.initialize(with: SavedAdsDataSource())
        super.viewDidLoad()
        
        reloadData()
        
        notificationTokens.append(SavedAdsManager.DataUpdatedNotification.addObserver { [weak self] _ in
            self?.reloadData()
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        // Remove the ad unit from the data source. This will automatically
        // trigger a UI update.
        dataSource?.removeItem(at: indexPath)
    }
}
