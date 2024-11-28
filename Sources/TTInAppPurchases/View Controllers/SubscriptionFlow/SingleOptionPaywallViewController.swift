//
//  SingleOptionPaywallViewController.swift
//  CallRecorder
//
//  Created by Sagar on 8/12/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Lottie

public class SingleOptionPaywallViewController: UIViewController, SubscriptionViewControllerProtocol {

    private let bounds = UIScreen.main.bounds
    private var featureLabelTextStyle: UIFont.TextStyle = .callout
    private var restoreButtonTextStyle: UIFont.TextStyle = .footnote
    private var lottieView: AnimationView!
    
    public weak var delegate: SubscriptionViewControllerDelegate?
    public weak var uiProviderDelegate: UpgradeUIProviderDelegate?
    private var _index = 0
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var primaryHeaderLabel: UILabel!
    @IBOutlet weak var pricingTopLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var pricingBottomLabel: UILabel!
    @IBOutlet weak var restorePurchasesButton: UIButton!
    
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var feature1Label: UILabel!
    @IBOutlet weak var feature2Label: UILabel!
    @IBOutlet weak var feature3Label: UILabel!
    @IBOutlet weak var feature4Label: UILabel!
    @IBOutlet weak var continueButton: SubtitleButton!
    
    @IBOutlet weak var privacyAndTermsOfLawLabel: UILabel!
    public var lifetimeOffer: Bool = false {
        didSet {
            print("lifetimeOffer has been set to \(lifetimeOffer)")
        }
    }
    public var hideCloseButton: Bool = false
    public var isFromCancelSubscription: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        _configureUI()
        _configureFeatureLabel()
        _configurePrimaryHeaderLabel()
        _configurePricingBottomLabel()
        _configureFeatureLabel()
        _configureContinueButton()
        _configurePrivacyAndTermsOfLawLabel()
        _configurePricingTopLabel()
        _configureRestorePurchasesButton()
        _configureCancelButton()
        
        if uiProviderDelegate!.productsFetched() {
            setupSubscriptionButtons(notification: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector:
                                                    #selector(setupSubscriptionButtons(notification:)), name:
                                                        Notification.Name.iapProductsFetchedNotification,
                                                   object: nil)
        }
        
        lottieView = uiProviderDelegate?.animatingAnimationView().view
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        animationView.addSubview(lottieView)
        let xOffset: CGFloat = uiProviderDelegate?.animatingAnimationView().offsetBy ?? 0
        NSLayoutConstraint.activate( [
            lottieView.topAnchor.constraint(equalTo: animationView.topAnchor,constant: xOffset),
            lottieView.rightAnchor.constraint(equalTo: animationView.rightAnchor),
            lottieView.bottomAnchor.constraint(equalTo: animationView.bottomAnchor),
            lottieView.leftAnchor.constraint(equalTo: animationView.leftAnchor)
        ])
        lottieView.frame = animationView.bounds
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewWillAppear(self)
        lottieView.play()
    }
    
    @objc func setupSubscriptionButtons(notification: Notification?) {
        NVActivityIndicatorView.stop()
        _configurePrimaryHeaderLabel()
        _configurePricingTopLabel()
        _configurePricingBottomLabel()
        _configureContinueButtonText()
    }
    
    private func _configureUI() {
        primaryHeaderLabel.configure(with: UIFont.font(.sofiaProBlack, style: .largeTitle))
        
        if bounds.height >= 896 {
        // 12 PRO MAX, 11 PRO MAX, XS MAX, XR , 11
            featureLabelTextStyle = bounds.height >= 926 ? .title3 : .headline
            // 12 PRO MAX
            stackViewHeightConstraint.constant = bounds.height >= 926 ? 170 : 160
            restoreButtonTextStyle = .body
            pricingTopLabel.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        } else if bounds.height >= 812 {
        // 11 PRO, iPhoneXS  & iPhone X, iPhone 12 & 12 PRO
            featureLabelTextStyle = .body
            restoreButtonTextStyle = .body
            pricingTopLabel.configure(with: UIFont.font(.sofiaProBold, style: .title3))
        } else {
        // all the rest
            restoreButtonTextStyle = .callout
            pricingTopLabel.configure(with: UIFont.font(.sofiaProBold, style: .headline))
            featureLabelTextStyle = .body
        }
    }
    
    private func _configurePrimaryHeaderLabel() {
        if lifetimeOffer || isFromCancelSubscription {
            primaryHeaderLabel.text = "Exclusive One-Time Offer!".localized.capitalized
        } else {
            primaryHeaderLabel.text = uiProviderDelegate?.headerMessage(for: _index)
        }
    }
    
    private func _configurePricingTopLabel() {
        if lifetimeOffer {
            // Configure for lifetime offer
            pricingTopLabel.configure(with: UIFont.font(.sofiaProRegular, style: .title2))
            let subscriptionPrice = uiProviderDelegate?.subscriptionPrice(for: _index, withDurationSuffix: false) ?? ""
            let attributedString = NSMutableAttributedString(string: subscriptionPrice)
            pricingTopLabel.attributedText = attributedString
        } else {
            // Check if an introductory price is available
            if let introductoryPrice = uiProviderDelegate?.introductoryPrice(for: _index, withDurationSuffix: true), !introductoryPrice.isEmpty {
                // Introductory price exists
                let attributedString = NSMutableAttributedString(string: "\(introductoryPrice) ")
                let regularPrice = uiProviderDelegate?.subscriptionPrice(for: _index, withDurationSuffix: false) ?? ""
                
                let attributedString1 = NSMutableAttributedString(
                    string: "(\(regularPrice))".localized,
                    attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                )
                
                attributedString.append(attributedString1)
                pricingTopLabel.attributedText = attributedString
            } else {
                // No introductory price, only show the regular subscription price
                let subscriptionPrice = uiProviderDelegate?.subscriptionPrice(for: _index, withDurationSuffix: true) ?? ""
                let attributedString = NSMutableAttributedString(string: subscriptionPrice)
                pricingTopLabel.attributedText = attributedString
            }
        }
    }
    
    private func _configureContinueButtonText() {
        if lifetimeOffer {
            continueButton.setSubtitle("This offer will never be shown again!".localized)
        } else {
            let subtitleText = uiProviderDelegate?.subscribeButtonSubtitle(for: 0) ?? ""
            continueButton.setSubtitle(subtitleText)
        }
    }
    
    private func _configurePricingBottomLabel() {
        pricingBottomLabel.configure(with: UIFont.font(.sofiaProRegular, style: .subheadline))
        if lifetimeOffer {
            pricingBottomLabel.configure(with: UIFont.font(.sofiaProRegular, style: .body))
            pricingBottomLabel.text = "No Recurring Subscription!".localized
        } else {
            let price = uiProviderDelegate!.monthlyBreakdownOfPrice(withDurationSuffix: true)
            pricingBottomLabel.text = "( \(price) " + "only".localized + " )"
        }
    }
    
    
    private func _configureFeatureLabel() {
        guard let features = uiProviderDelegate?.allFeatures(lifetimeOffer: lifetimeOffer) else {
            return
        }
        
        let featureLabels = [feature1Label, feature2Label, feature3Label, feature4Label]
        
        for (index, label) in featureLabels.enumerated() {
            label?.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
            
            // Ensure we don't access an out-of-bounds index in the features array
            if index < features.count {
                label?.text = SubscriptionHelper.attributedFeatureText(features[index])
            } else {
                label?.text = "" // or handle it however you prefer if there are fewer features than labels
            }
        }
    }
    
    private func _configureContinueButton() {
        print("Configuring continue button")
        continueButton.layer.cornerRadius = 27
        continueButton.backgroundColor = .primaryColor
        continueButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title3))
        let title = lifetimeOffer ? "Unlock Lifetime Access".localized.uppercased() : "Continue".localized.uppercased()
        continueButton.setTitle(title, for: .normal)
        continueButton.titleEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)

        print("About to configure subtitle text")
        // Configure subtitle text using the new method
        continueButton.subtitleText.textColor = UIColor.systemYellow
        continueButton.subtitleText.font = UIFont.font(.sofiaProMedium, style: .footnote)
        continueButton.subtitleText.setItalicText()

        print("About to set subtitle text")
        // Set the subtitle text
        _configureContinueButtonText()
        print("Finished configuring continue button")
    }
    
    private func _configureCancelButton() {
        cancelButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        cancelButton.setTitle("𝘅", for: .normal)
        cancelButton.isHidden = hideCloseButton ? true : false
    }
    
    private func _configureRestorePurchasesButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: 1,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryTextColor,
            NSAttributedString.Key.font: UIFont.font(.sofiaProRegular, style: restoreButtonTextStyle)
        ]
        let attributedHeader = NSAttributedString(string: "Restore Purchase".localized, attributes: attributes)
        restorePurchasesButton.setAttributedTitle(attributedHeader, for: .normal)
    }
    
    private func _configurePrivacyAndTermsOfLawLabel() {
        let text = "Terms of law".localized + " " + "and".localized + " " + "Privacy policy".localized
        let attributedString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms of law".localized)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range1)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range1)
        let range2 = (text as NSString).range(of: "Privacy policy".localized)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range2)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range2)
        
        privacyAndTermsOfLawLabel.configure(with: UIFont.font(.sofiaProRegular, style: .footnote))
        privacyAndTermsOfLawLabel.attributedText = attributedString
        
        //Adding Tap gesture
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
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        if isFromCancelSubscription {
            delegate?.openRefundLinkOrChat(self)
        }
//        delegate?.exit(self)
    }
    
    @IBAction func didTapRestorePurchaseButton(_ sender: UIButton) {
        delegate?.restorePurchases(self)
    }
    
    @IBAction func didTapContinueButton(_ sender: UIButton) {
        delegate?.selectPlan(at: _index, controller: self)
    }
}
