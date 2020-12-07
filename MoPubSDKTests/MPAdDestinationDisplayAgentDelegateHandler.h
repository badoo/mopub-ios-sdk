//
//  MPAdDestinationDisplayAgentDelegateHandler.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdDestinationDisplayAgent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdDestinationDisplayAgentDelegateHandler : NSObject <MPAdDestinationDisplayAgentDelegate>

@property (nonatomic, copy, nullable) UIViewController * (^viewControllerForPresentingModalViewBlock)(void);
@property (nonatomic, copy, nullable) void (^displayAgentWillPresentModalBlock)(void);
@property (nonatomic, copy, nullable) void (^displayAgentWillLeaveApplicationBlock)(void);
@property (nonatomic, copy, nullable) void (^displayAgentDidDismissModalBlock)(void);

@end

NS_ASSUME_NONNULL_END
