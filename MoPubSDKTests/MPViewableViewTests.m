//
//  MPViewableViewTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPMockViewabilityObstruction.h"
#import "MPMockViewabilityTracker.h"
#import "MPMockViewableView.h"
#import "MPViewableView.h"

@interface MPViewableViewTests : XCTestCase

@end

@implementation MPViewableViewTests

#pragma mark - Test Helpers

- (MPViewableView *)newViewableViewWithTracker:(MPMockViewabilityTracker * _Nullable)tracker {
    MPViewableView *view = [[MPViewableView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    view.viewabilityTracker = tracker;
    return view;
}

#pragma mark - Adding Subviews

// Tests that adding subviews while having no `viewabilityTracker` set will have no side
// effects.
- (void)testAddSubviewNoTracker {
    MPViewableView *view = [self newViewableViewWithTracker:nil];

    XCTAssertNotNil(view);
    XCTAssertNil(view.viewabilityTracker);
    XCTAssertTrue(view.subviews.count == 0);

    // Add a normal subview
    UIView *normalView = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:normalView];

    XCTAssertTrue(view.subviews.count == 1);
    XCTAssertTrue([view.subviews containsObject:normalView]);
}

// Tests that adding normal subviews while having a `viewabilityTracker` set will have no side
// effects.
- (void)testAddSubviewTracker {
    MPMockViewabilityTracker *tracker = [MPMockViewabilityTracker new];
    MPViewableView *view = [self newViewableViewWithTracker:tracker];

    XCTAssertNotNil(view);
    XCTAssertNotNil(view.viewabilityTracker);
    XCTAssertTrue(view.subviews.count == 0);

    // Add a normal subview
    UIView *normalView = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:normalView];

    XCTAssertTrue(view.subviews.count == 1);
    XCTAssertTrue([view.subviews containsObject:normalView]);
    XCTAssertTrue(tracker.registeredFriendlyObstructions.count == 0);

    // Add a Viewable view.
    MPMockViewableView *viewableView = [[MPMockViewableView alloc] initWithFrame:CGRectZero];
    XCTAssertNil(viewableView.viewabilityTracker);

    [view addSubview:viewableView];

    XCTAssertTrue(view.subviews.count == 2);
    XCTAssertTrue([view.subviews containsObject:viewableView]);

    XCTAssertTrue(tracker.registeredFriendlyObstructions.count == 1);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:viewableView]);

    XCTAssertNotNil(viewableView.viewabilityTracker);
}

#pragma mark - Changing Trackers

// Tests that changing trackers will update all trackers downstream and re-register
// friendly obstructions with the new tracker.
- (void)testChangeTracker {
    MPMockViewabilityTracker *oldTracker = [MPMockViewabilityTracker new];
    MPMockViewabilityTracker *newTracker = [MPMockViewabilityTracker new];
    MPViewableView *view = [self newViewableViewWithTracker:oldTracker];

    XCTAssertNotNil(view);
    XCTAssertNotNil(view.viewabilityTracker);
    XCTAssertTrue(view.viewabilityTracker == oldTracker);
    XCTAssertTrue(view.subviews.count == 0);

    // Add a Viewable view.
    MPMockViewableView *viewableView = [[MPMockViewableView alloc] initWithFrame:CGRectZero];
    XCTAssertNil(viewableView.viewabilityTracker);

    [view addSubview:viewableView];

    XCTAssertTrue(view.subviews.count == 1);
    XCTAssertTrue([view.subviews containsObject:viewableView]);

    XCTAssertTrue(oldTracker.registeredFriendlyObstructions.count == 1);
    XCTAssertTrue([oldTracker.registeredFriendlyObstructions containsObject:viewableView]);

    XCTAssertNotNil(viewableView.viewabilityTracker);
    XCTAssertTrue(viewableView.viewabilityTracker == oldTracker);

    // Change the tracker
    view.viewabilityTracker = newTracker;
    XCTAssertNotNil(view.viewabilityTracker);
    XCTAssertTrue(view.viewabilityTracker == newTracker);

    XCTAssertTrue(newTracker.registeredFriendlyObstructions.count == 1);
    XCTAssertTrue([newTracker.registeredFriendlyObstructions containsObject:viewableView]);

    XCTAssertNotNil(viewableView.viewabilityTracker);
    XCTAssertTrue(viewableView.viewabilityTracker == newTracker);
}

#pragma mark - Friendly Obstructions

// Tests that friendly obstruction aggregation works.
- (void)testTieredFriendlyObstructions {
    MPMockViewabilityTracker *tracker = [MPMockViewabilityTracker new];
    MPViewableView *view = [self newViewableViewWithTracker:tracker];

    XCTAssertNotNil(view);
    XCTAssertNotNil(view.viewabilityTracker);
    XCTAssertTrue(view.subviews.count == 0);

    // Add a normal subview
    UIView *normalView = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:normalView];

    // Add a Viewable view.
    MPMockViewableView *viewableView = [[MPMockViewableView alloc] initWithFrame:CGRectZero];
    [view addSubview:viewableView];

    XCTAssertTrue(view.subviews.count == 2);
    XCTAssertTrue([view.subviews containsObject:viewableView]);

    XCTAssertTrue(tracker.registeredFriendlyObstructions.count == 1);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:viewableView]);

    // Add a Viewable view to the existing viewable view
    MPMockViewableView *anotherViewableView = [[MPMockViewableView alloc] initWithFrame:CGRectZero];
    [viewableView addSubview:anotherViewableView];

    XCTAssertTrue(viewableView.subviews.count == 1);
    XCTAssertTrue([viewableView.subviews containsObject:anotherViewableView]);

    XCTAssertTrue(tracker.registeredFriendlyObstructions.count == 2);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:viewableView]);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:anotherViewableView]);

    // Add a friendly obstruction to the additional viewable view
    MPMockViewabilityObstruction *obstruction = [[MPMockViewabilityObstruction alloc] initWithFrame:CGRectZero];
    [anotherViewableView addSubview:obstruction];

    XCTAssertTrue(anotherViewableView.subviews.count == 1);
    XCTAssertTrue([anotherViewableView.subviews containsObject:obstruction]);
    XCTAssertTrue(anotherViewableView.friendlyObstructions.count == 1);
    XCTAssertTrue([anotherViewableView.friendlyObstructions containsObject:obstruction]);

    XCTAssertTrue(viewableView.friendlyObstructions.count == 2);
    XCTAssertTrue([viewableView.friendlyObstructions containsObject:obstruction]);

    XCTAssertTrue(view.friendlyObstructions.count == 3);
    XCTAssertTrue([view.friendlyObstructions containsObject:obstruction]);

    XCTAssertTrue(tracker.registeredFriendlyObstructions.count == 3);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:viewableView]);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:anotherViewableView]);
    XCTAssertTrue([tracker.registeredFriendlyObstructions containsObject:obstruction]);
}

@end
