//
//  MPNativeAd.h
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MPNativeAdAdapter;
@protocol MPNativeAdDelegate;
@protocol MPNativeAdRenderer;
@class MPAdConfiguration;

/**
 * The `MPNativeAd` class is used to render and manage events for a native advertisement. The
 * class provides methods for accessing native ad properties returned by the server, as well as
 * convenience methods for URL navigation and metrics-gathering.
 */

@interface MPNativeAd : NSObject

/** @name Ad Resources */

/**
 * The delegate of the `MPNativeAd` object.
 */
@property (nonatomic, weak) id<MPNativeAdDelegate> delegate;
/**
 * Exposed click status of the Ad to destinguish between clicks on Ad and Info.
 * - Alexander Balaban
 */
@property (nonatomic, assign) BOOL hasTrackedClick;

/**
 * A dictionary representing the native ad properties.
 */
@property (nonatomic, readonly) NSDictionary *properties;

- (instancetype)initWithAdAdapter:(id<MPNativeAdAdapter>)adAdapter;

/** @name Retrieving Ad View */

/**
 * Retrieves a rendered view containing the ad.
 *
 * @param error A pointer to an error object. If an error occurs, this pointer will be set to an
 * actual error object containing the error information.
 *
 * @return If successful, the method will return a view containing the rendered ad. The method will
 * return nil if it cannot render the ad data to a view.
 */
- (UIView *)retrieveAdViewWithError:(NSError **)error;

- (void)trackMetricForURL:(NSURL *)URL;

@end
