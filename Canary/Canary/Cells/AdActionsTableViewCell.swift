//
//  AdActionsTableViewCell.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

protocol AdActionsTableViewCellDelegate: AnyObject {
    func requestedAdSizeUpdated(to size: CGSize)
}

final class AdActionsTableViewCell: UITableViewCell, TableViewCellRegisterable {
    // MARK: - IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var showAdButton: RoundedButton!
    @IBOutlet weak var loadAdButton: RoundedButton!
    @IBOutlet weak var adSizeStackView: UIStackView!
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    // MARK: - Properties
    weak var delegate: AdActionsTableViewCellDelegate? = nil
    fileprivate var willLoadAd: AdActionHandler? = nil
    fileprivate var willShowAd: AdActionHandler? = nil
    
    // MARK: - Requested Ad Size
    private static let numberFormatter = NumberFormatter()
    private(set) var requestedAdSize: CGSize {
        get {
            let width = CGFloat(truncating: Self.numberFormatter.number(from: widthTextField.text ?? "") ?? 0.0)
            let height = CGFloat(truncating: Self.numberFormatter.number(from: heightTextField.text ?? "") ?? 0.0)
            return CGSize(width: width, height: height)
        }
        set {
            widthTextField.text = "\(newValue.width)"
            heightTextField.text = "\(newValue.height)"
        }
    }
    
    private var isRequestedAdSizeValid: Bool {
        // If the ad sizes are not required, they are always marked as valid.
        guard !adSizeStackView.isHidden else {
            return true
        }
        
        let widthIsValid = Self.numberFormatter.number(from: widthTextField.text ?? "") != nil
        let heightIsValid = Self.numberFormatter.number(from: heightTextField.text ?? "") != nil
        return widthIsValid && heightIsValid
    }
    
    // MARK: - IBActions
    @IBAction func onLoad(_ sender: Any) {
        willLoadAd?(sender)
    }
    
    @IBAction func onShow(_ sender: Any) {
        willShowAd?(sender)
    }
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set text colors correctly
        if #available(iOS 13.0, *) {
            widthTextField.textColor = .label
            heightTextField.textColor = .label
        }
        
        // Accessibility
        loadAdButton.accessibilityIdentifier = AccessibilityIdentifier.adActionsLoad
        showAdButton.accessibilityIdentifier = AccessibilityIdentifier.adActionsShow
    }
    
    // MARK: - Refreshing
    
    func refresh(adSize: CGSize? = nil,
                 isAdLoading: Bool = false,
                 loadAdHandler: AdActionHandler? = nil,
                 showAdHandler: AdActionHandler? = nil,
                 showButtonEnabled: Bool = false) {
        // If there is no initial ad size passed in, we can assume that this format does not
        // support manual input of requested ad sizes.
        if let adSize = adSize {
            adSizeStackView.isHidden = false
            requestedAdSize = adSize
        }
        else {
            adSizeStackView.isHidden = true
        }
        
        willLoadAd = loadAdHandler
        willShowAd = showAdHandler
        
        // Loading button state is only disabled if
        // 1. the show button is enabled and has a valid handler
        // OR
        // 2. the ad is currently loading.
        loadAdButton.isEnabled = (showAdHandler == nil || !showButtonEnabled) && !isAdLoading
        widthTextField.isEnabled = loadAdButton.isEnabled
        heightTextField.isEnabled = loadAdButton.isEnabled
        
        // Showing an ad is optional. Hide it if there is no show handler.
        showAdButton.isHidden = (showAdHandler == nil)
        showAdButton.isEnabled = showButtonEnabled
        
        // Require re-layout
        setNeedsLayout()
    }
}

extension AdActionsTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Since editing the text field is only possible when the load button is
        // enabled, we can assume that toggling the enabled state is safe here.
        loadAdButton.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Done editing by pressing the return key or done key
        if (string == "\n") {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isRequestedAdSizeValid {
            loadAdButton.isEnabled = true
            delegate?.requestedAdSizeUpdated(to: requestedAdSize)
        }
    }
}
