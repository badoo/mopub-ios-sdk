//
//  AppDelegate.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {
    static var shared: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return appDelegate
    }
    
    /**
     This default `SceneDelegate` is created for pre-iOS 13 backward compatibility as a single scene app.
    */
    private lazy var _sceneDelegate = SceneDelegate()
    private var sceneDelegate: SceneDelegate {
        get {
            if #available(iOS 13, *) {
                fatalError("Handle multi-scene in `SceneDelegate` for iOS 13+")
            } else {
                return _sceneDelegate
            }
        }
    }
    
    /**
     Application window.
     */
    var window: UIWindow? {
        get {
            if #available(iOS 13, *) {
                // Handle multi-scene in `SceneDelegate` for iOS 13+. Return `nil` instead of
                // `fatalError` because iOS 13 UIKit calls this getter regardlessly.
                return nil
            } else {
                return sceneDelegate.window
            }
        }
        set {
            if #available(iOS 13, *) {
                fatalError("Handle multi-scene in `SceneDelegate` for iOS 13+")
            } else {
                sceneDelegate.window = newValue
            }
        }
    }
    
    /**
     Application container controller.
     */
    var containerViewController: ContainerViewController? {
        if #available(iOS 13, *) {
            fatalError("Handle multi-scene in `SceneDelegate` for iOS 13+")
        } else {
            switch sceneDelegate.mode {
            case .adViewScene, .unknown:
                print("`containerViewController` is only available for the main scene")
                return nil
            case .mainScene(let mainSceneState):
                return mainSceneState.containerViewController
            }
        }
    }
}

// MARK: - UIApplicationDelegate

/*
For future `UIApplicationDelegate` implementation, if there is a `UIWindowSceneDelegate` counterpart,
we should share the implementation in `SceneDelegate` for both `UIWindowSceneDelegate` and
`UIApplicationDelegate`.
*/
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13, *) {
            // Do nothing here. App launch will be handled by `SceneDelegate.scene(_:willConnectTo:options:)`
        } else {
            sceneDelegate.handleMainSceneStart()
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 13, *) {
            fatalError("Handle multi-scene in `SceneDelegate` for iOS 13+")
        } else {
            return sceneDelegate.openURL(url)
        }
    }
}

// MARK: - UISceneSession Lifecycle

@available(iOS 13, *)
extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        if let adUnit = AdUnit.adUnitFromSceneConnectionOptions(options) {
            print("\(#function) open ad unit [\(adUnit.name): \(adUnit.id)]")
            return UISceneConfiguration(name: "Open Ad View", sessionRole: connectingSceneSession.role)
        } else {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }
}
