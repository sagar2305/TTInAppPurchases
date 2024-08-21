//
//  MonthlyAndAnnualViewController.swift
//  CallRecorder
//
//  Created by Sandesh on 27/07/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit
import LGButton
import NVActivityIndicatorView
import Lottie

public protocol UpgradeUIProviderDelegate: AnyObject {
    func productsFetched() -> Bool
    func headerMessage(for index: Int) -> String
    func subscriptionTitle(for index: Int) -> String
    func subscriptionPrice(for index: Int, withDurationSuffix: Bool) -> String
    func continueButtonTitle(for index: Int) -> String
    func offersFreeTrial(for index: Int) -> Bool
    func introductoryPrice(for index: Int, withDurationSuffix: Bool) -> String
    func monthlyBreakdownOfPrice(withIntroDiscount: Bool, withDurationSuffix: Bool) -> String
    /// provide Lottie animating view for subscription page
    /// and whether to shift the xOffSet (Only For EZTAPE)
    func animatingAnimationView() -> (view: AnimationView,offsetBy: CGFloat?)
    func featureOne() -> String
    func featureTwo() -> String
    func featureThree() -> String
    func featureFour() -> String
    func freeTrialDuration(for index: Int) -> String
    func subscribeButtonSubtitle(for index: Int) -> String
}

class MonthlyAndAnnualViewController: UIViewController, SubscriptionViewControllerProtocol {
    var hideCloseButton: Bool = false
    var lifetimeOffer = false
    weak var delegate: SubscriptionViewControllerDelegate?
    weak var uiProviderDelegate: UpgradeUIProviderDelegate?
    
    private var _selectedIndex = 1 {
        didSet {
            if isViewLoaded {
                if _selectedIndex == 0 {
                    _highlight(buttonAt: 0)
                    _unhighlight(buttonAt: 1)
                } else {
                    _highlight(buttonAt: 1)
                    _unhighlight(buttonAt: 0)
                }
            }
        }
    }
    
    @IBOutlet weak var backgroundImageOverlayView: UIView!
    @IBOutlet weak var scrollViewContentHeaderOffset: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerMessageLabel: UILabel!
    
    @IBOutlet weak var firstSubscriptionButton: LGButton!
    @IBOutlet weak var firstSubscriptionCheckedImage: UIImageView!
    @IBOutlet weak var firstSubscriptionTitleLabel: UILabel!
    @IBOutlet weak var firstSubscriptionPriceLabel: UILabel!
    
    @IBOutlet weak var secondSubscriptionButton: LGButton!
    @IBOutlet weak var secondSubscriptionCheckedImage: UIImageView!
    @IBOutlet weak var secondSubscriptionTitleLabel: UILabel!
    @IBOutlet weak var secondSubscriptionPriceLabel: UILabel!
    @IBOutlet weak var trialInfoLabel: UILabel!
    
    @IBOutlet weak var restorePurchasesButton: UIButton!

    @IBOutlet weak var feature1Label: UILabel!
    @IBOutlet weak var feature2Label: UILabel!
    @IBOutlet weak var feature3Label: UILabel!
    @IBOutlet weak var feature4Label: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var privacyAndTermsOfLawLabel: UILabel!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _selectedIndex = 1

        _configureUI()
        _setScrollViewContentHeaderOffset()
        _configureBackgroundImageOverlayView()
        _configureCancelButton()
        _configureFeatureLabel()
        _configurePrivacyAndTermsOfLawLabel()
        _configureRestorePurchasesButton()
        
        if uiProviderDelegate!.productsFetched() {
            setupSubscriptionButtons(notification: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector:
                #selector(setupSubscriptionButtons(notification:)), name:
            Notification.Name.iapProductsFetchedNotification,
                object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        delegate?.viewWillAppear(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(self)
    }
    
    @objc func setupSubscriptionButtons(notification: Notification?) {
        NVActivityIndicatorView.stop()

        _configureHeaderMessageLabel()
        _configureFirstSubscriptionButton()
        _configureSecondSubscriptionButton()
        _configureContinueButton()
    }
    
    private func _configureUI() {
        headerMessageLabel.configure(with: UIFont.font(.sofiaProRegular, style: .title2))
        firstSubscriptionTitleLabel.configure(with: UIFont.font(.sofiaProMedium, style: .body))
        firstSubscriptionPriceLabel.configure(with: UIFont.font(.sofiaProBold, style: .body))
        secondSubscriptionTitleLabel.configure(with: UIFont.font(.sofiaProMedium, style: .body))
        secondSubscriptionPriceLabel.configure(with: UIFont.font(.sofiaProBold, style: .body))
        trialInfoLabel.configure(with: UIFont.font(.sofiaProLight, style: .footnote))
        continueButton.backgroundColor = .systemGreen
        continueButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title3))
    }
    
    private func _setScrollViewContentHeaderOffset() {
        let bounds = UIScreen.main.bounds
        
        if bounds.height <= 568 {
            //4" devices
            scrollViewContentHeaderOffset.constant = 80
        } else if bounds.height == 667 {
            //4.7" devices
            scrollViewContentHeaderOffset.constant = 135
        } else if bounds.height == 736 {
            // 5.5"
            scrollViewContentHeaderOffset.constant = 195
        } else if bounds.height == 812 {
            // 11 PRO, iPhoneXS  & iPhone X
            scrollViewContentHeaderOffset.constant = 195
        } else if bounds.height >= 896 {
            // 11 PRO MAX, XS MAX, XR & 11
            scrollViewContentHeaderOffset.constant = 215
        }
    }
    
    private func _configureBackgroundImageOverlayView() {
        backgroundImageOverlayView.addLinearGradient([
            UIColor.clear.cgColor,
            UIColor(red: 0.118, green: 0.118, blue: 0.113, alpha: 1.0).cgColor
        ], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 0.42))
    }
    
    private func _configureCancelButton() {
        cancelButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        cancelButton.setTitle("𝘅", for: .normal)
        cancelButton.isHidden = hideCloseButton ? true : false
    }
    
    private func _configureHeaderMessageLabel() {
        headerMessageLabel.text = uiProviderDelegate?.headerMessage(for: _selectedIndex)
    }
    
    private func _configureFirstSubscriptionButton() {
        firstSubscriptionTitleLabel.configure(with: UIFont.font(.sofiaProMedium, style: .body))
        firstSubscriptionTitleLabel.text = uiProviderDelegate?.subscriptionTitle(for: 0)
        
        firstSubscriptionPriceLabel.configure(with: UIFont.font(.sofiaProBold, style: .body))
        firstSubscriptionPriceLabel.text = uiProviderDelegate?.subscriptionPrice(for: 0, withDurationSuffix: true)
        
        firstSubscriptionButton.borderColor = UIColor.buttonTextColor
    }
    
    private func _configureSecondSubscriptionButton() {
        secondSubscriptionTitleLabel.configure(with: UIFont.font(.sofiaProMedium, style: .body))
        secondSubscriptionTitleLabel.text = uiProviderDelegate?.subscriptionTitle(for: 1)
        
        secondSubscriptionPriceLabel.configure(with: UIFont.font(.sofiaProBold, style: .body))
        secondSubscriptionPriceLabel.text = uiProviderDelegate?.introductoryPrice(for: 1, withDurationSuffix: true)
        
        trialInfoLabel.configure(with: UIFont.font(.sofiaProLight, style: .footnote))
        trialInfoLabel.text = "7 days free trial, then".localized
        trialInfoLabel.isHidden = !uiProviderDelegate!.offersFreeTrial(for: 1)
        
        secondSubscriptionButton.borderColor = UIColor.buttonTextColor
    }

    private func _configureRestorePurchasesButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: 1,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryTextColor,
            NSAttributedString.Key.font: UIFont.font(.sofiaProRegular, style: .body)
            ]
        let attributedHeader = NSAttributedString(string: "Restore Purchase".localized, attributes: attributes)
        restorePurchasesButton.setAttributedTitle(attributedHeader, for: .normal)
    }
    
    private func _configureFeatureLabel() {
        feature1Label.configure(with: UIFont.font(.sofiaProRegular, style: .callout))
        feature1Label.text = SubscriptionHelper.attributedFeatureText(uiProviderDelegate?.featureOne() ?? "")
        
        feature2Label.configure(with: UIFont.font(.sofiaProRegular, style: .callout))
        feature2Label.text = SubscriptionHelper.attributedFeatureText(uiProviderDelegate?.featureTwo() ?? "")
        
        feature3Label.configure(with: UIFont.font(.sofiaProRegular, style: .callout))
        feature3Label.text = SubscriptionHelper.attributedFeatureText(uiProviderDelegate?.featureThree() ?? "")
       
        feature4Label.configure(with: UIFont.font(.sofiaProRegular, style: .callout))
        feature4Label.text = SubscriptionHelper.attributedFeatureText(uiProviderDelegate?.featureFour() ?? "")
    }

    private func _configureContinueButton() {
        continueButton.backgroundColor = .systemGreen
        continueButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title3))
        continueButton.setTitle(uiProviderDelegate?.continueButtonTitle(for: _selectedIndex), for: .normal)
    }
    
    private func _configurePrivacyAndTermsOfLawLabel() {
        let text = "By signing up you agree to our Terms of law and Privacy policy".localized
        let attributedString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms of law".localized)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range1)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range1)
        let range2 = (text as NSString).range(of: "Privacy policy".localized)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range2)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range2)
        
        privacyAndTermsOfLawLabel.configure(with: UIFont.font(.sofiaProRegular, style: .footnote))
        privacyAndTermsOfLawLabel.attributedText = attributedString
        
        //Adding Tap geture
        privacyAndTermsOfLawLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(didTapLabel(_:)))
        privacyAndTermsOfLawLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapLabel(_ tapGesture: UITapGestureRecognizer) {
        let labelString = privacyAndTermsOfLawLabel.text! as NSString
        
        let termsOfLaw = labelString.range(of: "Terms of law".localized)
        let privacyPolicyRange = labelString.range(of: "Privacy policy".localized)
        
        if tapGesture.didTapAttributedTextInLabel(label: privacyAndTermsOfLawLabel, inRange: termsOfLaw) {
            delegate?.showTermsOfLaw(self)
        } else  if tapGesture.didTapAttributedTextInLabel(label: privacyAndTermsOfLawLabel, inRange: privacyPolicyRange) {
            delegate?.showPrivacyPolicy(self)
        }
    }
    
    private func _highlight(buttonAt index: Int) {
        _button(at: index).backgroundColor = .primaryColor
        _button(at: index).borderWidth = 0
        _checkedImage(at: index).image = UIImage(named: "checked_circle")!
        _titleLabel(at: index).textColor = .buttonTextColor
        _priceLabel(at: index).textColor = .buttonTextColor
    }
    
    private func _unhighlight(buttonAt index: Int) {
        _button(at: index).backgroundColor = .clear
        _button(at: index).borderWidth = 2
        _checkedImage(at: index).image = UIImage(named: "unchecked_circle")!
        _titleLabel(at: index).textColor = .buttonTextColor
        _priceLabel(at: index).textColor = .buttonTextColor
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        delegate?.exit(self)
    }
    
    @IBAction func selectedFirstSubscription(_ sender: LGButton) {
        _selectedIndex = 0
        _configureHeaderMessageLabel()
        _configureContinueButton()
        didTapContinueButton(nil)
    }
    
    @IBAction func selectedSecondSubscription(_ sender: LGButton) {
        _selectedIndex = 1
        _configureHeaderMessageLabel()
        _configureContinueButton()
        didTapContinueButton(nil)
    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
        delegate?.restorePurchases(self)
    }
    
    @IBAction func didTapContinueButton(_ sender: UIButton?) {
        delegate?.selectPlan(at: _selectedIndex, controller: self)
    }
    
    // MARK: - Helper
    private func _button(at index: Int) -> LGButton {
        return index == 0 ? firstSubscriptionButton : secondSubscriptionButton
    }

    private func _checkedImage(at index: Int) -> UIImageView {
        return index == 0 ? firstSubscriptionCheckedImage : secondSubscriptionCheckedImage
    }

    private func _titleLabel(at index: Int) -> UILabel {
        return index == 0 ? firstSubscriptionTitleLabel : secondSubscriptionTitleLabel
    }

    private func _priceLabel(at index: Int) -> UILabel {
        return index == 0 ? firstSubscriptionPriceLabel : secondSubscriptionPriceLabel
    }
}
