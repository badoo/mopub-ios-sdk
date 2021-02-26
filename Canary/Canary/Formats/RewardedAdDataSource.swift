//
//  RewardedAdDataSource.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPubSDK
import UIKit

class RewardedAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    // MARK: - Status Properties
    
    /**
     Currently selected reward by the user.
     */
    private var selectedReward: MPReward? = nil
    
    /**
     Table of which events were triggered.
     */
    var eventTriggered: [AdEvent: Bool] = [:]
    
    /**
     Status event titles that correspond to the events found in `MPRewardedAdsDelegate`
     */
    lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad]            = CallbackFunctionNames.rewardedAdDidLoad
        titleStrings[.didFailToLoad]      = CallbackFunctionNames.rewardedAdDidFailToLoad
        titleStrings[.didFailToPlay]      = CallbackFunctionNames.rewardedAdDidFailToShow
        titleStrings[.willPresent]        = CallbackFunctionNames.rewardedAdWillPresent
        titleStrings[.didPresent]         = CallbackFunctionNames.rewardedAdDidPresent
        titleStrings[.willDismiss]        = CallbackFunctionNames.rewardedAdWillDismiss
        titleStrings[.didDismiss]         = CallbackFunctionNames.rewardedAdDidDismiss
        titleStrings[.didExpire]          = CallbackFunctionNames.rewardedAdDidExpire
        titleStrings[.clicked]            = CallbackFunctionNames.rewardedAdDidReceiveTapEvent
        titleStrings[.willLeaveApp]       = CallbackFunctionNames.rewardedAdWillLeaveApplication
        titleStrings[.shouldRewardUser]   = CallbackFunctionNames.rewardedAdShouldReward
        titleStrings[.didTrackImpression] = CallbackFunctionNames.didTrackImpression
        
        return titleStrings
    }()
    
    /**
     Optional status messages that correspond to the events found in the ad's delegate protocol.
     These are reset as part of `clearStatus`.
     */
    var messages: [AdEvent: String] = [:]
    
    // MARK: - Initialization
    
    /**
     Initializes the Interstitial ad data source.
     - Parameter adUnit: Interstitial ad unit.
     */
    init(adUnit: AdUnit) {
        super.init()
        self.adUnit = adUnit
        
        // Register for rewarded video events
        MPRewardedAds.setDelegate(self, forAdUnitId: adUnit.id)
    }
    
    deinit {
        MPRewardedAds.removeDelegate(forAdUnitId: adUnit.id)
    }
    
    // MARK: - AdDataSource
    
    /**
     The ad unit information sections available for the ad.
     */
    lazy var information: [AdInformation] = {
        return [.id, .keywords, .userDataKeywords, .customData]
    }()
    
    /**
     Closures associated with each available ad action.
     */
    lazy var actionHandlers: [AdAction: AdActionHandler] = {
        var handlers: [AdAction: AdActionHandler] = [:]
        handlers[.load] = { [weak self] _ in
            self?.loadAd()
        }
        
        handlers[.show] = { [weak self] (sender) in
            self?.showAd(sender: sender)
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .didFailToPlay, .willPresent, .didPresent, .willDismiss, .didDismiss, .didExpire, .clicked, .willLeaveApp, .shouldRewardUser, .didTrackImpression]
    }()
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? {
        return nil
    }
    
    /**
     Queries if the data source has an ad loaded.
     */
    var isAdLoaded: Bool {
        return MPRewardedAds.hasAdAvailable(forAdUnitID: adUnit.id)
    }
    
    /**
     Queries if the data source currently requesting an ad.
     */
    private(set) var isAdLoading: Bool = false
    
    /**
    Optional ad size used for requesting inline ads. This should be `nil` for non-inline ads.
    */
    var requestedAdSize: CGSize? = nil
    
    // MARK: - Reward Selection
    
    /**
     Presents the reward selection as an action sheet. It will preselect the first item.
     - Parameter sender: `UIButton` element that initiated the reward selection
     - Parameter complete: Completion closure that's invoked when the select button has been pressed
     */
    private func presentRewardSelection(from sender: Any, complete: @escaping (() -> Swift.Void)) {
        // No rewards to present.
        guard let availableRewards = MPRewardedAds.availableRewards(forAdUnitID: adUnit.id) as? [MPReward],
            availableRewards.count > 0 else {
            return
        }
        
        // Create the alert.
        let alert = UIAlertController(title: "Choose Reward", message: nil, pickerViewDelegate: self, pickerViewDataSource: self, sender: sender)
        
        // Create the selection button.
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { _ in
            complete()
        }))
        
        // Present the alert
        delegate?.adPresentationViewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Ad Loading
    
    private func loadAd() {
        guard !isAdLoading else {
            return
        }
        
        isAdLoading = true
        clearStatus { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
        
        // Clear out previous reward.
        selectedReward = nil
        
        // Load the rewarded ad.
        MPRewardedAds.loadRewardedAd(withAdUnitID: adUnit.id, keywords: adUnit.keywords, userDataKeywords: adUnit.userDataKeywords, mediationSettings: nil)
        
        SavedAdsManager.sharedInstance.addLoadedAds(adUnit: adUnit)
    }
    
    private func showAd(sender: Any) {
        guard MPRewardedAds.hasAdAvailable(forAdUnitID: adUnit.id) else {
            print("Attempted to show a rewarded ad when it is not ready")
            return
        }
        
        // Prompt the user to select a reward
        presentRewardSelection(from: sender) { [weak self] in
            if let strongSelf = self {
                // Validate a reward was selected
                guard strongSelf.selectedReward != nil else {
                    print("No reward was selected")
                    return
                }
                
                // Present the ad.
                MPRewardedAds.presentRewardedAd(forAdUnitID: strongSelf.adUnit.id, from: strongSelf.delegate?.adPresentationViewController, with: strongSelf.selectedReward, customData: strongSelf.adUnit.customData)
            }
        }
    }
}

extension RewardedAdDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - UIPickerViewDataSource
    
    // There will always be a single column of currencies
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MPRewardedAds.availableRewards(forAdUnitID: adUnit.id).count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let reward: MPReward = MPRewardedAds.availableRewards(forAdUnitID: adUnit.id)[row] as? MPReward,
            let amount = reward.amount,
            let currency = reward.currencyType else {
            return nil
        }
        
        return "\(amount) \(currency)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let reward: MPReward = MPRewardedAds.availableRewards(forAdUnitID: adUnit.id)[row] as? MPReward else {
            return
        }
        
        selectedReward = reward
    }
}

extension RewardedAdDataSource: MPRewardedAdsDelegate {
    // MARK: - MPRewardedAdsDelegate
    
    func rewardedAdDidLoad(forAdUnitID adUnitID: String!) {
        isAdLoading = false
        setStatus(for: .didLoad) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        isAdLoading = false
        setStatus(for: .didFailToLoad, message: error.localizedDescription) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdDidFailToShow(forAdUnitID adUnitID: String!, error: Error!) {
        setStatus(for: .didFailToPlay, message: error.localizedDescription) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdWillPresent(forAdUnitID adUnitID: String!) {
        setStatus(for: .willPresent) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdDidPresent(forAdUnitID adUnitID: String!) {
        setStatus(for: .didPresent) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdWillDismiss(forAdUnitID adUnitID: String!) {
        setStatus(for: .willDismiss) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdDidDismiss(forAdUnitID adUnitID: String!) {
        setStatus(for: .didDismiss) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdDidExpire(forAdUnitID adUnitID: String!) {
        setStatus(for: .didExpire) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        setStatus(for: .clicked) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdWillLeaveApplication(forAdUnitID adUnitID: String!) {
        setStatus(for: .willLeaveApp) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedAdShouldReward(forAdUnitID adUnitID: String!, reward: MPReward!) {
        let message = reward?.description ?? "No reward specified"
        setStatus(for: .shouldRewardUser, message: message) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func didTrackImpression(withAdUnitID adUnitID: String!, impressionData: MPImpressionData!) {
        let message = impressionData?.description ?? "No impression data"
        setStatus(for: .didTrackImpression, message: message) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
}
