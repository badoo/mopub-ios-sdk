//
//  MPAdServerCommunicatorDelegateHandler.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerCommunicatorDelegateHandler.h"

@implementation MPAdServerCommunicatorDelegateHandler

- (void)communicatorDidReceiveAdConfigurations:(NSArray<MPAdConfiguration *> *)configurations {
    if (self.communicatorDidReceiveAdConfigurations) {
        self.communicatorDidReceiveAdConfigurations(configurations);
    }
}

- (void)communicatorDidFailWithError:(NSError *)error {
    if (self.communicatorDidFailWithError) {
        self.communicatorDidFailWithError(error);
    }
}

@end
