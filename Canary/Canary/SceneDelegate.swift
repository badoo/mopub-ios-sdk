//
//  SceneDelegate.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPubSDK
import UIKit
import AppTrackingTransparency

private let kAppId = "112358"

class SceneDelegate: UIResponder {
    /**
     Possible modes of this scene delegate.
     */
    enum Mode {
        /**
         This `SceneDelegate` is instantiated but not yet assgined to a particular scene.
         */
        case unknown
        
        /**
         This represents the one & only main scene of this app.
         */
        case mainScene(mainSceneState: MainSceneState)
        
        /**
         This represents a dedicated scene for showing a ad.
         */
        case adViewScene
    }
    
    /**
     This is the data container for `Mode.mainScene`.
    */
    struct MainSceneState {
        /**
         Scene container controller. Assignment deferred to `handleMainSceneStart`.
         */
        let containerViewController: ContainerViewController
        
        
        
        init(containerViewController: ContainerViewController) {
            self.containerViewController = containerViewController
            
        }
    }
    
    /**
     Use this to handle the one-off app init events.
     */
    static var didHandleAppInit = false
    
    /**
     Scene window.
     */
    var window: UIWindow?
    
    /**
     Current mode of the scene delegates. Should be assigned in `scene(_:willConnectTo:options:)`.
    */
    private(set) var mode: Mode = .unknown
    
    /**
     Handle the start event of the main scene.
     
     Call this to when:
        * Pre iOS 13: application did finish launching (as single scene)
        * iOS 13+: scene will connect to session
     
     - Parameter mopub: the target `MoPub` instance
     - Parameter adConversionTracker: the target `MPAdConversionTracker` instance
     - Parameter userDefaults: the target `UserDefaults` instance
    */
    func handleMainSceneStart(mopub: MoPub = .sharedInstance(),
                              adConversionTracker: MPAdConversionTracker = .shared(),
                              userDefaults: UserDefaults = .standard) {
        // Extract the UI elements for easier manipulation later. Calls to `loadViewIfNeeded()` are
        // needed to load any children view controllers before `viewDidLoad()` occurs.
        guard let containerViewController = window?.rootViewController as? ContainerViewController else {
            fatalError()
        }
        containerViewController.loadViewIfNeeded()
        
        mode = .mainScene(mainSceneState: MainSceneState(containerViewController: containerViewController))
        
        if userDefaults.shouldClearCachedNetworks {
            mopub.clearCachedNetworks() // do this before initializing the MoPub SDK
            print("\(#function) cached networks are cleared")
        }

        // Make one-off calls here
        if (SceneDelegate.didHandleAppInit == false) {
            SceneDelegate.didHandleAppInit = true
            
            // Register app conversion.
            // This is for SKAdNetwork advertising campaigns that use this app
            // as the target installed app.
            if #available(iOS 11.3, *) {
                SKAdNetwork.registerAppForAdNetworkAttribution()
            }
            
            // MoPub SDK initialization
            checkAndInitializeSdk(containerViewController: containerViewController)

            // Conversion tracking
            adConversionTracker.reportApplicationOpen(forApplicationID: kAppId)
        }
    }
    
    /**
     Attempts to open a URL.
     - Parameter url: the URL to open
     - Returns: `true` if successfully open, `false` if not
    */
    @discardableResult
    func openURL(_ url: URL) -> Bool {
        switch mode {
        case .mainScene(let mainSceneState):
            guard
                url.scheme == "mopub",
                url.host == "load",
                let adUnit = AdUnit(url: url) else {
                    return false
            }
            return SceneDelegate.openMoPubAdUnit(adUnit: adUnit,
                                                 onto: mainSceneState.containerViewController,
                                                 shouldSave: true)
        case .adViewScene, .unknown:
            return false
        }
    }
    
    /**
     Attempts to open a valid `AdUnit` object instance
     - Parameter adUnit: MoPub `AdUnit` object instance
     - Parameter containerViewController: Container view controller that will present the opened deep link
     - Parameter shouldSave: Flag indicating that the ad unit that was opened should be saved
     - Parameter savedAdsManager: The manager for saving the ad unit
     - Returns: `true` if successfully shown, `false` if not
     */
    @discardableResult
    static func openMoPubAdUnit(adUnit: AdUnit,
                                onto containerViewController: ContainerViewController,
                                shouldSave: Bool,
                                savedAdsManager: SavedAdsManager = .sharedInstance) -> Bool {
        // Generate the destinate view controller and attempt to push the destination to the
        // Saved Ads navigation controller.
        guard
            let vcClass = NSClassFromString(adUnit.viewControllerClassName) as? AdViewController.Type,
            let destination: UIViewController = vcClass.instantiateFromNib(adUnit: adUnit) as? UIViewController else {
                return false
        }
        
        DispatchQueue.main.async {
            // If the ad unit should be saved, we will switch the tab to the saved ads
            // tab and then push the view controller on that navigation stack.
            containerViewController.mainTabBarController?.selectedIndex = 1
            if shouldSave {
                savedAdsManager.addSavedAd(adUnit: adUnit)
            }
            containerViewController.savedAdsNavigationController.pushViewController(destination, animated: true)
        }
        return true
    }
}

// MARK: - UIWindowSceneDelegate

/*
 For future `UIWindowSceneDelegate` implementation, if there is a `UIApplicationDelegate` counterpart,
 we should share the implementation in `SceneDelegate` for both `UIWindowSceneDelegate` and
 `UIApplicationDelegate`.
 */
@available(iOS 13, *)
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        if let rootViewController = AdUnit.adViewControllerForSceneConnectionOptions(connectionOptions) {
            // load the view programmatically
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
            self.window = window
            self.mode = .adViewScene
        } else {
            handleMainSceneStart()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Options are specified in the UIApplication.h section for openURL options.
        // An empty options dictionary will result in the same behavior as the older openURL call,
        // aside from the fact that this is asynchronous and calls the completion handler rather
        // than returning a result. The completion handler is called on the main queue.
        for urlContext in URLContexts {
            openURL(urlContext.url)
        }
    }
}

// MARK: - Private App Init

private extension SceneDelegate {
    /**
     Check if the Canary app has a cached ad unit ID for consent. If not, the app will present an alert dialog allowing custom ad unit ID entry.
     - Parameter containerViewController: the main container view controller
     - Parameter userDefaults: the target `UserDefaults` instance
     */
    func checkAndInitializeSdk(containerViewController: ContainerViewController, userDefaults: UserDefaults = .standard) {
        // Retrieve the ad unit used to initialize the SDK.
        let adUnitIdForConsent: String = userDefaults.cachedAdUnitId ?? Constants.defaultAdUnitId
        
        // Next, initialize the SDK
        initializeMoPubSdk(adUnitIdForConsent: adUnitIdForConsent, containerViewController: containerViewController, mopub: MoPub.sharedInstance()) {
            // Prompt for authorization status after running the `initializeMoPubSDK` method (which
            // also shows the GDPR prompt, if available) so Canary isn't trying to present two
            // view controllers simultaneously
            self.promptForTrackingAuthorizationStatus(fromViewController: containerViewController)
        }
    }

    private func promptForTrackingAuthorizationStatus(fromViewController viewController: UIViewController, completion: (() -> Void)? = nil) {
        // If tracking authorization status is equal to `.notDetermined`, prompt
        // to see if Canary should ask for authorization permission.
        // Doing this check before actually requesting permission allows Canary
        // to black-box test `.notDetermined` status, as well as `.authorized`
        // and `.denied`. Not showing the prompt makes it so `.notDetermined`
        // cannot be properly tested as the call to `requestTrackingAuthorization`
        // forces a state-change to strictly `.denied` or `.authorized`.
        
        guard #available(iOS 14.0, *) else {
            // Not running iOS 14
            completion?()
            return
        }
        
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            // Already have an authorization status; don't need to reprompt
            completion?()
            return
        }
        
        let alertController = UIAlertController(title: "Do you want to be prompted to set IDFA permissions now?", message: "IDFA consent", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes, prompt now.", style: .default, handler: { _ in
            ATTrackingManager.requestTrackingAuthorization { _ in
                // Request completed; call completion
                completion?()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "No, prompt in 1 minute.", style: .default, handler: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    // No-op
                }
            }
            
            // Don't wait on tracking manager and call completion instead:
            completion?()
        }))
        
        alertController.addAction(UIAlertAction(title: "No, prompt at next startup.", style: .cancel, handler: { _ in
            // Not setting an authorization now. Call completion.
            completion?()
        }))
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

    /**
     Initializes the MoPub SDK with the given ad unit ID used for consent management.
     - Parameter adUnitIdForConsent: This value must be a valid ad unit ID associated with your app.
     - Parameter containerViewController: the main container view controller
     - Parameter mopub: the target `MoPub` instance
     */
    func initializeMoPubSdk(adUnitIdForConsent: String,
                            containerViewController: ContainerViewController,
                            mopub: MoPub = .sharedInstance(),
                            completion: (() -> Void)? = nil) {
        // MoPub SDK initialization
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitIdForConsent)
        sdkConfig.globalMediationSettings = []
        sdkConfig.loggingLevel = .info
        
        mopub.initializeSdk(with: sdkConfig) {
            // Update the state of the menu now that the SDK has completed initialization.
            if let menuController = containerViewController.menuViewController {
                menuController.updateIfNeeded()
            }
            
            // Request user consent to collect personally identifiable information
            // used for targeted ads
            if let tabBarController = containerViewController.mainTabBarController {
                SceneDelegate.displayConsentDialog(from: tabBarController, mopub: mopub) {
                    completion?()
                }
            }
        }
    }
}

// MARK: - Private Helpers

private extension SceneDelegate {
    /**
     Loads the consent request dialog (if not already loaded), and presents the dialog
     from the specified view controller. If user consent is not needed, nothing is done.
     - Parameter presentingViewController: `UIViewController` used for presenting the dialog
     - Parameter mopub: the target `MoPub` instance
     */
    static func displayConsentDialog(from presentingViewController: UIViewController,
                                     mopub: MoPub = .sharedInstance(),
                                     completion: (() -> Void)? = nil) {
        // Verify that we need to acquire consent.
        guard mopub.shouldShowConsentDialog else {
            completion?()
            return
        }
        
        // Load the consent dialog if it's not available. If it is already available,
        // the completion block will immediately fire.
        mopub.loadConsentDialog { (error: Error?) in
            guard error == nil else {
                print("Consent dialog failed to load: \(String(describing: error?.localizedDescription))")
                completion?()
                return
            }
            
            mopub.showConsentDialog(from: presentingViewController, didShow: nil) {
                completion?()
            }
        }
    }
}
