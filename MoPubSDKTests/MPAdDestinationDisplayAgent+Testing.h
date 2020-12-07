//
//  MPAdDestinationDisplayAgent+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdDestinationDisplayAgent.h"

#import <SafariServices/SafariServices.h>
#import <StoreKit/StoreKit.h>
#import "MPAnalyticsTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdDestinationDisplayAgent (Testing)

@property (nonatomic, assign) BOOL isLoadingDestination;
@property (nonatomic, strong) SKStoreProductViewController *storeKitController;
@property (nonatomic, strong) SFSafariViewController *safariController;

@property (nonatomic, copy, class, nullable) void (^presentStoreKitControllerWithProductParametersBlock)(NSDictionary *);
@property (nonatomic, copy, class, nullable) void (^showAdBrowserControllerBlock)(void);

@end

NS_ASSUME_NONNULL_END
