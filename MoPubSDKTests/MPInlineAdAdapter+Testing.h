//
//  MPInlineAdAdapter+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerView.h"
#import "MPInlineAdAdapter.h"
#import "MPViewabilityTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPInlineAdAdapter (Testing)
- (id<MPViewabilityTracker> _Nullable)viewabilityTrackerForWebContentInView:(MPAdContainerView *)webContainer;

@end

NS_ASSUME_NONNULL_END
