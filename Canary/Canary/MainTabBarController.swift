//
//  MainTabBarController.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class MainTabBarController: UITabBarController {
    /**
     Button used for displaying status notifications.
     */
    private var notificationButton: UIButton = UIButton(type: .custom)
    
    /**
     The navigation controller of the "Saved Ads" tab, which is a `UINavigationController`.
     */
    var savedAdsNavigationController: UINavigationController {
        guard let savedAdsController = viewControllers?.first(where: {
            $0.tabBarItem.title == "Saved Ads"
        }) as? UINavigationController else {
            fatalError()
        }
        return savedAdsController
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the notification label
        notificationButton.accessibilityIdentifier = AccessibilityIdentifier.notificationButton
        notificationButton.alpha = 0.0
        notificationButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        notificationButton.addTarget(self, action: #selector(self.dismissNotification), for: .touchUpInside)
        view.addSubview(notificationButton)
        
        // Set notification label to word wrap
        notificationButton.titleLabel?.numberOfLines = 0
        notificationButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        // Constrain the notification label
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notificationButton.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            // Lock notification button height to height of label
            notificationButton.heightAnchor.constraint(equalTo: notificationButton.titleLabel!.heightAnchor,
                                                       constant: notificationButton.contentEdgeInsets.top + notificationButton.contentEdgeInsets.bottom)
        ])
    }

    // MARK: - Notifications
    
    /**
     Displays a status notification onscreen just above the tab bar.
     - Parameter text: Status text to display
     - Parameter textColor: Text color
     - Parameter backgroundColor: Background color
     */
    func showNotification(withText text: String, textColor: UIColor = .white, backgroundColor: UIColor = .black) {
        notificationButton.backgroundColor = backgroundColor
        notificationButton.setTitle(text, for: .normal)
        notificationButton.setTitleColor(textColor, for: .normal)
        notificationButton.layoutIfNeeded()
        
        UIView.animate(withDuration: Constants.notificationAnimationDuration) {
            self.notificationButton.alpha = 1.0
        }
    }
    
    /**
     Dismisses the notification display.
     */
    @objc
    func dismissNotification() {
        UIView.animate(withDuration: Constants.notificationAnimationDuration) {
            self.notificationButton.alpha = 0.0
        }
    }
}
