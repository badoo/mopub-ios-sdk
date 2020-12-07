//
//  CallbackFunctionNames.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

/**
 This is a list of callback function names that show up in the ad view UI. This file is shared
 between app targets and test targets.

 Here we use string constants instead of `NSStringFromSelector(#selector(_SOME_SELECTOR_))` for the
 callback names because UI test target for Release build has `Enable Testability = NO` configuration,
 and thus `@testable import Canary` will fail to compile.
 
 Note: Update `CallbackFunctionNameTests` if correspondingly after updating this file.
 */
enum CallbackFunctionNames {
    // MARK: - MPAdViewDelegate
    static let adViewDidLoadAd = "adViewDidLoadAd:adSize:"
    static let adViewDidFailToLoadAd = "adView:didFailToLoadAdWithError:"
    static let willPresentModalViewForAd = "willPresentModalViewForAd:"
    static let didDismissModalViewForAd = "didDismissModalViewForAd:"
    static let willLeaveApplicationFromAd = "willLeaveApplicationFromAd:"

    // MARK: - MPMoPubAdDelegate
    static let didTrackImpression = "mopubAd:didTrackImpressionWithImpressionData:"

    // MARK: - MPInterstitialAdControllerDelegate
    static let interstitialDidLoadAd = "interstitialDidLoadAd:"
    static let interstitialDidFailToLoadAd = "interstitialDidFailToLoadAd:"
    static let interstitialWillAppear = "interstitialWillAppear:"
    static let interstitialDidAppear = "interstitialDidAppear:"
    static let interstitialWillDisappear = "interstitialWillDisappear:"
    static let interstitialDidDisappear = "interstitialDidDisappear:"
    static let interstitialDidExpire = "interstitialDidExpire:"
    static let interstitialDidReceiveTapEvent = "interstitialDidReceiveTapEvent:"

    // MARK: - MPNativeAdDelegate
    static let nativeAdDidLoad = "native ad did load" // `MPNativeAdDelegate` does not have corresponding callback
    static let nativeAdDidFailToLoad = "native ad did fail load" // `MPNativeAdDelegate` does not have corresponding callback
    static let willPresentModal = "willPresentModalForNativeAd:"
    static let didDismissModal = "didDismissModalForNativeAd:"
    static let willLeaveApplication = "willLeaveApplicationFromNativeAd:"

    // MARK: - MPRewardedVideoDelegate
    static let rewardedVideoAdDidLoad = "rewardedVideoAdDidLoadForAdUnitID:"
    static let rewardedVideoAdDidFailToLoad = "rewardedVideoAdDidFailToLoadForAdUnitID:error:"
    static let rewardedVideoAdDidFailToPlay = "rewardedVideoAdDidFailToPlayForAdUnitID:error:"
    static let rewardedVideoAdWillAppear = "rewardedVideoAdWillAppearForAdUnitID:"
    static let rewardedVideoAdDidAppear = "rewardedVideoAdDidAppearForAdUnitID:"
    static let rewardedVideoAdWillDisappear = "rewardedVideoAdWillDisappearForAdUnitID:"
    static let rewardedVideoAdDidDisappear = "rewardedVideoAdDidDisappearForAdUnitID:"
    static let rewardedVideoAdDidExpire = "rewardedVideoAdDidExpireForAdUnitID:"
    static let rewardedVideoAdDidReceiveTapEvent = "rewardedVideoAdDidReceiveTapEventForAdUnitID:"
    static let rewardedVideoAdWillLeaveApplication = "rewardedVideoAdWillLeaveApplicationForAdUnitID:"
    static let rewardedVideoAdShouldReward = "rewardedVideoAdShouldRewardForAdUnitID:reward:"
}
