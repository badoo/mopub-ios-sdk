//
//  MPAdDestinationDisplayAgentDelegateHandler.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdDestinationDisplayAgentDelegateHandler.h"

@implementation MPAdDestinationDisplayAgentDelegateHandler

- (UIViewController *)viewControllerForPresentingModalView {
    if (self.viewControllerForPresentingModalViewBlock != nil) {
        return self.viewControllerForPresentingModalViewBlock();
    }

    return nil;
}

- (void)displayAgentWillPresentModal {
    if (self.displayAgentWillPresentModalBlock != nil) {
        self.displayAgentWillPresentModalBlock();
    }
}

- (void)displayAgentDidDismissModal {
    if (self.displayAgentDidDismissModalBlock != nil) {
        self.displayAgentDidDismissModalBlock();
    }
}

- (void)displayAgentWillLeaveApplication {
    if (self.displayAgentWillLeaveApplicationBlock != nil) {
        self.displayAgentWillLeaveApplicationBlock();
    }
}

@end
