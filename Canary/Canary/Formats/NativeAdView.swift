//
//  NativeAdView.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

/**
 Provides a common native ad view.
 */
@IBDesignable
class NativeAdView: UIView {
    // IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var callToActionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var sponsoredByLabel: UILabel!
    @IBOutlet weak var privacyInformationIconImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    // IBInspectable
    @IBInspectable var nibName: String? = "NativeAdView"
    
    // Content View
    private(set) var contentView: UIView? = nil
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNib()
    }
    
    /**
     The function is essential for supporting flexible width. The native view content might be
     stretched, cut, or have undesired padding if the height is not estimated properly.
     */
    static func estimatedViewHeightForWidth(_ width: CGFloat) -> CGFloat {
        // The numbers are obtained from the constraint defined in the xib file
        let padding: CGFloat = 8
        let iconImageViewWidth: CGFloat = 50
        let estimatedNonMainContentCombinedHeight: CGFloat = 72 // [title, main text, call to action] labels
        
        let mainContentWidth = width - padding * 3 - iconImageViewWidth
        let mainContentHeight = mainContentWidth / 2 // the xib has a 2:1 width:height ratio constraint
        return floor(mainContentHeight + estimatedNonMainContentCombinedHeight + padding * 2)
    }
    
    func setupNib() -> Void {
        guard let view = loadViewFromNib(nibName: nibName) else {
            return
        }
        
        // Accessibility
        mainImageView.accessibilityIdentifier = AccessibilityIdentifier.nativeAdImageView
        
        // Size the nib's view to the container and add it as a subview.
        view.frame = bounds
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        addSubview(view)
        contentView = view
        
        // Pin the anchors of the content view to the view.
        let viewConstraints = [view.topAnchor.constraint(equalTo: topAnchor),
                               view.bottomAnchor.constraint(equalTo: bottomAnchor),
                               view.leadingAnchor.constraint(equalTo: leadingAnchor),
                               view.trailingAnchor.constraint(equalTo: trailingAnchor)]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupNib()
        contentView?.prepareForInterfaceBuilder()
    }
}

extension NativeAdView: MPNativeAdRendering {
    // MARK: - MPNativeAdRendering
    
    func nativeTitleTextLabel() -> UILabel! {
        return titleLabel
    }
    
    func nativeMainTextLabel() -> UILabel! {
        return mainTextLabel
    }
    
    func nativeCallToActionTextLabel() -> UILabel! {
        return callToActionLabel
    }
    
    func nativeIconImageView() -> UIImageView! {
        return iconImageView
    }
    
    func nativeMainImageView() -> UIImageView! {
        return mainImageView
    }
    
    func nativeSponsoredByCompanyTextLabel() -> UILabel! {
        return sponsoredByLabel
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView! {
        return privacyInformationIconImageView
    }
    
    func nativeVideoView() -> UIView! {
        return videoView
    }
    
    static func localizedSponsoredByText(withSponsorName sponsorName: String!) -> String! {
        return "Brought to you by \(sponsorName!)"
    }
}
