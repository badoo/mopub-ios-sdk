//
//  MPBannerAdManager+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerAdManager.h"

@interface MPBannerAdManager (Testing)
@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPInlineAdAdapter *onscreenAdapter;
@property (nonatomic, strong) MPInlineAdAdapter *requestingAdapter;
@end
