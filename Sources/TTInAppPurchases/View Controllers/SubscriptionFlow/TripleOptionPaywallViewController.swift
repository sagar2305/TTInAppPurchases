//
//  TripleOptionPaywallViewController.swift
//  TTInAppPurchases
//
//  Created by Revathi on 18/04/22.
//

import UIKit
import Lottie
import NVActivityIndicatorView
import SwiftUI
import StoreKit

public class TripleOptionPaywallViewController: UIViewController, SubscriptionViewControllerProtocol {
    public weak var delegate: SubscriptionViewControllerDelegate?
    public weak var uiProviderDelegate: UpgradeUIProviderDelegate?
      
    //MARK: - IBOutlets
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var subscribeButton: SubtitleButton!
    @IBOutlet weak var primaryHeaderLabel: UILabel!
    @IBOutlet weak var feature1Label: UILabel!
    @IBOutlet weak var feature2Label: UILabel!
    @IBOutlet weak var feature3Label: UILabel!
    @IBOutlet weak var feature4Label: UILabel!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var freeTrialLabel: UILabel!
    @IBOutlet weak var firstSubscriptionButton: UIButton!
    @IBOutlet weak var secondSubscriptionButton: UIButton!
    @IBOutlet weak var thirdSubscriptionButton: UIButton!
    @IBOutlet weak var topDescriptionLabel: UILabel!
    @IBOutlet var priceButtons: [UIButton]!
    @IBOutlet var tickMarkViews: [UIView]!
    
    //MARK: IBOutlet Collections
    
    @IBOutlet var priceButtonStandardWidth: [NSLayoutConstraint]!
    @IBOutlet var priceButtonZoomedWidth: [NSLayoutConstraint]!
    
    @IBOutlet var priceButtonHeight: [NSLayoutConstraint]!
    @IBOutlet var subscriptionViews: [UIView]!
    
    @IBOutlet weak var subscriptionStackView: UIStackView!
    @IBOutlet weak var restorePurchasesButton: UIButton!
    @IBOutlet weak var privacyAndTermsOfLawLabel: UILabel!
    
    @IBOutlet weak var firstButtonDurationLabel: UILabel!
    @IBOutlet weak var firstButtonWeekLabel: UILabel!
    @IBOutlet weak var firstButtonPriceLabel: UILabel!
    @IBOutlet weak var secondButtonDurationLabel: UILabel!
    @IBOutlet weak var secondButtonMonthLabel: UILabel!
    @IBOutlet weak var secondButtonPriceLabel: UILabel!
    @IBOutlet weak var secondButtonSaveLabel: UILabel!
    @IBOutlet weak var thirdButtonDurationLabel: UILabel!
    @IBOutlet weak var thirdButtonMonthLabel: UILabel!
    @IBOutlet weak var thirdButtonPriceLabel: UILabel!
    @IBOutlet weak var thirdButtonSaveLabel: UILabel!
    @IBOutlet weak var thirdButtonPackTypeLabel: UILabel!
    @IBOutlet weak var secondButtonPackTypeLabel: UILabel!
    
    
    //MARK: External Parameters
    public var hideCloseButton: Bool = false
    public var lifetimeOffer: Bool = false
    
    //MARK: Internal Parameters
    private var lottieView: AnimationView!
    private let bounds = UIScreen.main.bounds
    private var featureLabelTextStyle: UIFont.TextStyle = .callout
    private var restoreButtonTextStyle: UIFont.TextStyle = .footnote
    private let characterSet = CharacterSet(charactersIn: "0123456789.").inverted
    
    private var _selectedIndex = 2 {
        didSet {
            if isViewLoaded {
                checkFreeOfferTrialStatus(for: _selectedIndex)
                unhighlightButton(at: oldValue)
                highlightButton(at: _selectedIndex)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - View Controller Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        _selectedIndex = 2

       // _drawShape()
        _configureUI()
        _configureHeaderLabels()
        _configureDescriptionLabels()
        _configureFeatureLabel()
        _configureCancelButton()
        _configurePriceButton()
        _configureSubscribeButton()
        _configurePriceButtonTitle()
        _configureSecondButtonPackTitle()
        _configureThirdButtonPackTitle()
        _configureRestorePurchasesButton()
        _configurePrivacyAndTermsOfLawLabel()

        if let (animView, offsetBy) = uiProviderDelegate?.animatingAnimationView() {
            lottieView = animView
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            animationView.addSubview(lottieView)
            NSLayoutConstraint.activate([
                lottieView.topAnchor.constraint(equalTo: animationView.topAnchor, constant: offsetBy ?? 0),
                lottieView.rightAnchor.constraint(equalTo: animationView.rightAnchor),
                lottieView.bottomAnchor.constraint(equalTo: animationView.bottomAnchor),
                lottieView.leftAnchor.constraint(equalTo: animationView.leftAnchor)
            ])
            lottieView.frame = animationView.bounds
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            lottieView.animationSpeed = 1.0
        }
        
        if uiProviderDelegate?.productsFetched() == true {
            setupSubscriptionButtons(notification: nil)
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(setupSubscriptionButtons(notification:)),
                                                   name: Notification.Name.iapProductsFetchedNotification,
                                                   object: nil)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewWillAppear(self)
        lottieView.play()
    }
    
    public override var prefersStatusBarHidden: Bool {
         return true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(self)
    }
    
    @objc func setupSubscriptionButtons(notification: Notification?) {
        NVActivityIndicatorView.stop()

        _configurePriceButtonTitle()
    }

    //MARK: - Configure UI
    private func _drawShape() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: view.bounds.size.width * 0.65, y: 0))
        
        let QPoint1 = CGPoint(x: view.bounds.size.width * 0.40, y: view.bounds.size.height * 0.15)
        let QPoint2 = CGPoint(x: view.bounds.size.width * 0.30, y: view.bounds.size.height * 0.02)
        
        path.addCurve(to: CGPoint(x: 0, y: view.bounds.size.width * 0.30),
                      controlPoint1: QPoint1,
                      controlPoint2: QPoint2)
        path.close()
        
        let layer1 = CAShapeLayer()
        layer1.fillColor = UIColor.primaryColor.cgColor
        layer1.path = path.cgPath
        contentView.layer.insertSublayer(layer1, at: 1)
        
        let layer2 = CAShapeLayer()
        layer2.fillColor = UIColor.primaryColor.withAlphaComponent(0.4).cgColor
        layer2.path = path.cgPath
        layer2.transform = CATransform3DMakeScale(1.13, 1.10, 0)
        contentView.layer.insertSublayer(layer2, below: layer1)
    }
    
    private func _configureUI() {
        if bounds.height >= 896 {
            // 12 PRO MAX, 11 PRO MAX, XS MAX, XR , 11
            featureLabelTextStyle = bounds.height >= 926 ? .title3 : .headline
            // 12 PRO MAX
            stackViewHeightConstraint.constant = bounds.height >= 926 ? 170 : 160
        } else {
            // all the rest
            featureLabelTextStyle = .body
        }
    }
    
    private func _configurePriceButtonTitle() {
        _configureFirstSubscriptionButton()
        _configureSecondSubscriptionButton()
        _configureThirdSubscriptionButton()
        _selectedIndex = 2
    }
    
    private func _configureHeaderLabels() {
        primaryHeaderLabel.configure(with: UIFont.font(.sofiaProBlack, style: .title2))
        primaryHeaderLabel.text = "Upgrade To Premium".localized
    }

    private func _configureDescriptionLabels() {
        topDescriptionLabel.configure(with: UIFont.font(.sofiaProLight, style: .body))
        topDescriptionLabel.text = uiProviderDelegate?.headerMessage(for: 0) ?? ""
    }
    
    private func _configureFeatureLabel() {
        guard let features = uiProviderDelegate?.allFeatures(lifetimeOffer: false) else {
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
    
    private func _configurePriceButton() {
        for button in priceButtons {
            button.layer.cornerRadius = 6
        }
    }
    
    private let regularAttribute = [NSAttributedString.Key.font: UIFont.font(.sofiaProRegular, style: .subheadline)]
    private let semiBoldAttribute = [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .subheadline)]
    private let priceAttribute = [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .headline)]
    
    private func _configureFirstSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 0, withDurationSuffix: false) ?? "-"
        let attributedString = NSMutableAttributedString(string: "at".localized, attributes: semiBoldAttribute)
        let pricePart = NSMutableAttributedString(string: " \(price)", attributes: priceAttribute)
        attributedString.append(pricePart)
        firstButtonDurationLabel.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        firstButtonWeekLabel.attributedText = NSMutableAttributedString(string: "week pack".localized, attributes: regularAttribute)
        firstButtonPriceLabel.attributedText = attributedString
    }
    
    private func _configureSecondSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 1, withDurationSuffix: false) ?? "-"
        let attributedString = NSMutableAttributedString(string: "at".localized, attributes: semiBoldAttribute)
        let pricePart = NSMutableAttributedString(string: " \(price)", attributes: priceAttribute)
        attributedString.append(pricePart)
        
        secondButtonDurationLabel.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        secondButtonMonthLabel.attributedText = NSMutableAttributedString(string: "month pack".localized, attributes: regularAttribute)
        secondButtonPriceLabel.attributedText = attributedString
        
        secondButtonSaveLabel.configure(with: UIFont.font(.sofiaProMedium, style: .subheadline))
        
        let weeklyPrice = (uiProviderDelegate?.subscriptionPrice(for: 0, withDurationSuffix: false) ?? "-").components(separatedBy: characterSet)
            .joined()
        let monthlyPrice = price.components(separatedBy: characterSet)
            .joined()
        
        if let weeklyValue = Float(weeklyPrice), let monthlyValue = Float(monthlyPrice) {
            let save = (weeklyValue - (monthlyValue / 4))/weeklyValue * 100
            secondButtonSaveLabel.text = "Save".localized + String(format: " %.2f", save) + "%"
        }
    }
    
    private func _configureThirdSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 2, withDurationSuffix: false) ?? "-"
        let attributedString = NSMutableAttributedString(string: "at".localized, attributes: semiBoldAttribute)
        let pricePart = NSMutableAttributedString(string: " \(price)", attributes: priceAttribute)
        attributedString.append(pricePart)
        
        thirdButtonDurationLabel.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        thirdButtonMonthLabel.attributedText = NSMutableAttributedString(string: "months pack".localized, attributes: regularAttribute)
        thirdButtonPriceLabel.attributedText = attributedString
        
        thirdButtonSaveLabel.configure(with: UIFont.font(.sofiaProMedium, style: .subheadline))
        
        let weeklyPrice = (uiProviderDelegate?.subscriptionPrice(for: 0, withDurationSuffix: false) ?? "-").components(separatedBy: characterSet)
            .joined()
        let yearlyPrice = price.components(separatedBy: characterSet)
            .joined()
        
        if let weeklyValue = Float(weeklyPrice), let yearlyValue = Float(yearlyPrice) {
            let save = (weeklyValue - (yearlyValue / 52))/weeklyValue * 100
            thirdButtonSaveLabel.text = "Save".localized + String(format: " %.2f", save) + "%"
        }
        
    }
    
    private func _configureSecondButtonPackTitle()  {
        secondButtonPackTypeLabel.configure(with: UIFont.font(.sofiaProRegular, style: .footnote))
        secondButtonPackTypeLabel.text = "Popular".localized
    }
    
    private func _configureThirdButtonPackTitle() {
        thirdButtonPackTypeLabel.configure(with: UIFont.font(.sofiaProRegular, style: .footnote))
        thirdButtonPackTypeLabel.text = "Best Value".localized
    }
    
    private func _configureSubscribeButton() {
        subscribeButton.titleLabel?.configure(with: UIFont.font(.sofiaProMedium, style: .title3))
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

    private func _configureCancelButton() {
        cancelButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        cancelButton.setTitle("𝘅", for: .normal)
        cancelButton.alpha = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.cancelButton.alpha = 0.8
        }
        
    }
    

    private func highlightButton(at index: Int) {
        let button = priceButtons[index]
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.primaryColor.cgColor
        
        let tickImage = tickMarkViews[index]
        tickImage.isHidden = false
        
        priceButtonStandardWidth[index].priority = UILayoutPriority(rawValue: 250)
        priceButtonZoomedWidth[index].priority = UILayoutPriority(rawValue: 750)
        
        priceButtonHeight[index].constant = 150
    }
    
    private func unhighlightButton(at index: Int) {
        let button = priceButtons[index]
        button.layer.borderWidth = 0
        
        let tickImage = tickMarkViews[index]
        tickImage.isHidden = true
        
        priceButtonZoomedWidth[index].priority = UILayoutPriority(rawValue: 250)
        priceButtonStandardWidth[index].priority = UILayoutPriority(rawValue: 750)
        
        priceButtonHeight[index].constant = 135
    }
    
    private func checkFreeOfferTrialStatus(for index: Int) {
        guard let uiProviderDelegate = uiProviderDelegate else { return }
        
        let offersFreeTrial = uiProviderDelegate.offersFreeTrial(for: index)
        if offersFreeTrial {
            freeTrialLabel.isHidden = false
            let freeTrialDuration = uiProviderDelegate.freeTrialDuration(for: index)

            subscribeButton.contentVerticalAlignment = .top
            subscribeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
            let subtitleText = uiProviderDelegate.subscribeButtonSubtitle(for: index)
            subscribeButton.setSubtitle(subtitleText)
            
            let title = freeTrialDuration + " " + "Free Trial".localized
            let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .footnote)])
            freeTrialLabel.attributedText = attributedString
            subscribeButton.setTitle("CONTINUE".localized, for: .normal)
        } else {
            subscribeButton.contentEdgeInsets = UIEdgeInsets.zero
            subscribeButton.contentVerticalAlignment = .center
            subscribeButton.setSubtitle("")
            freeTrialLabel.isHidden = true
            subscribeButton.setTitle("CONTINUE".localized, for: .normal)
        }
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
    
    //MARK: - IBActions
    
    @IBAction func selectedFirstSubscription(_ sender: UIButton) {
        _selectedIndex = sender.tag // 0
    }
    
    @IBAction func selectedSecondSubscription(_ sender: UIButton) {
        _selectedIndex = sender.tag // 1
    }
    
    @IBAction func selectedThirdSubscription(_ sender: UIButton) {
        _selectedIndex = sender.tag // 2
    }
    
    @IBAction func didTapSubscribeNowButton(_ sender: UIButton) {
        delegate?.selectPlan(at: _selectedIndex, controller: self)
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        delegate?.exit(self)
    }
    
    @IBAction func didTapRestorePurchase(_ sender: Any) {
        delegate?.restorePurchases(self)
    }
    

}
