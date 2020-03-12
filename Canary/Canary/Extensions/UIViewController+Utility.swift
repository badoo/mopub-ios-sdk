//
//  UIViewController+Utility.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

// MARK: - UIScene Compatibility

extension UIViewController {
    /**
     Scene container controller.
    */
    var containerViewController: ContainerViewController? {
        if #available(iOS 13.0, *) {
            guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
                fatalError()
            }
            switch sceneDelegate.mode {
            case .adViewScene, .unknown:
                print("`containerViewController` is only available for the main scene")
                return nil
            case .mainScene(let mainSceneState):
                return mainSceneState.containerViewController
            }
        } else {
            return AppDelegate.shared.containerViewController
        }
    }
    
    @available(iOS 13.0, *)
    @objc func destroySceneSession() {
        guard let session = view.window?.windowScene?.session else {
            fatalError()
        }
        
        UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
            print("\(#function) error: \(error)")
        }
    }
}
