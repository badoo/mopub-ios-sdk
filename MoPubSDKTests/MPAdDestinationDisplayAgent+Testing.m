//
//  MPAdDestinationDisplayAgent+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdDestinationDisplayAgent+Testing.h"

@implementation MPAdDestinationDisplayAgent (Testing)

@dynamic isLoadingDestination;
@dynamic storeKitController;
@dynamic safariController;

static void (^sPresentStoreKitControllerWithProductParametersBlock)(NSDictionary *) = nil;

+ (void)setPresentStoreKitControllerWithProductParametersBlock:(void (^)(NSDictionary * _Nonnull))presentStoreKitControllerWithProductParametersBlock {
    sPresentStoreKitControllerWithProductParametersBlock = presentStoreKitControllerWithProductParametersBlock;
}
+ (void (^)(NSDictionary * _Nonnull))presentStoreKitControllerWithProductParametersBlock {
    return sPresentStoreKitControllerWithProductParametersBlock;
}

static void (^sShowAdBrowserControllerBlock)(void) = nil;

+ (void)setShowAdBrowserControllerBlock:(void (^)(void))showAdBrowserControllerBlock {
    sShowAdBrowserControllerBlock = showAdBrowserControllerBlock;
}
+ (void (^)(void))showAdBrowserControllerBlock {
    return sShowAdBrowserControllerBlock;
}

- (void)presentStoreKitControllerWithProductParameters:(NSDictionary *)parameters {
    if (MPAdDestinationDisplayAgent.presentStoreKitControllerWithProductParametersBlock != nil) {
        MPAdDestinationDisplayAgent.presentStoreKitControllerWithProductParametersBlock(parameters);
    }
}

- (void)showAdBrowserController {
    if (MPAdDestinationDisplayAgent.showAdBrowserControllerBlock != nil) {
        MPAdDestinationDisplayAgent.showAdBrowserControllerBlock();
    }
}

@end
