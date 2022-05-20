//
//  WeeklyMonthlyAndAnnualViewController.swift
//  TTInAppPurchases
//
//  Created by Revathi on 18/04/22.
//

import UIKit
import Lottie
import NVActivityIndicatorView

public class WeeklyMonthlyAndAnnualViewController: UIViewController, SubscriptionViewControllerProtocol {
      
    //MARK: - IBOutlets
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
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
    @IBOutlet weak var bottomHeaderLabel: UILabel!
    @IBOutlet weak var bottomDescriptionLabel: UILabel!
    @IBOutlet var priceButtons: [UIButton]!
    @IBOutlet var tickMarkImageViews: [UIImageView]!
    
    //MARK: IBOutlet Collections
    @IBOutlet var priceButtonsZoomedHeight: [NSLayoutConstraint]!
    @IBOutlet var priceButtonStandardHeight: [NSLayoutConstraint]!
    @IBOutlet weak var restorePurchasesButton: UIButton!
    @IBOutlet weak var privacyAndTermsOfLawLabel: UILabel!
    
    //MARK: External Parameters
    public weak var delegate: SubscriptionViewControllerDelegate?
    public weak var uiProviderDelegate: UpgradeUIProviderDelegate?
    public var giftOffer: Bool = false
    public var hideCloseButton: Bool = false
    
    //MARK: Internal Parameters
    private var lottieView: AnimationView!
    private let bounds = UIScreen.main.bounds
    private var featureLabelTextStyle: UIFont.TextStyle = .callout
    private var restoreButtonTextStyle: UIFont.TextStyle = .footnote
    
    private var _selectedIndex = 1 {
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
        
        _selectedIndex = 1

        _drawShape()
        _configureUI()
        _configureHeaderLabels()
        _configureDescriptionLabels()
        _configureFeatureLabel()
        _configureCancelButton()
        _configurePriceButton()
        _configureSubscribeButton()
        _configureFreeTrialLabel()
        _configurePriceButtonTitle()
        _configureRestorePurchasesButton()
        _configurePrivacyAndTermsOfLawLabel()
        
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
        
        if uiProviderDelegate!.productsFetched() {
            setupSubscriptionButtons(notification: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector:
                #selector(setupSubscriptionButtons(notification:)), name:
            Notification.Name.iapProductsFetchedNotification,
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
    }
    
    private func _configureHeaderLabels() {
        primaryHeaderLabel.configure(with: UIFont.font(.sofiaProBlack, style: .title2))
        primaryHeaderLabel.text = "Upgrade To Premium".localized
        
        bottomHeaderLabel.configure(with: UIFont.font(.sofiaProSemibold, style: .headline))
        bottomHeaderLabel.text = "Download, Try and Test the App".localized
    }
    
    private func _configureDescriptionLabels() {
        topDescriptionLabel.configure(with: UIFont.font(.sofiaProLight, style: .subheadline))
        topDescriptionLabel.text = "EZTape Call Recorder is the simplest and most seamless recording app on the app store. This business app allows you to record your incoming and outgoing phone calls.".localized
        
        bottomDescriptionLabel.configure(with: UIFont.font(.sofiaProRegular, style: .subheadline))
        bottomDescriptionLabel.text = "Call recordings like never before on your iOS device. Call, Record*, Store and Share the call with your teammates. *We are supporting the online and outdoor call recording where you don’t have anything to write the important stuff. We are not breaching anyone’s privacy policy.".localized
    }
    
    private func _configureFeatureLabel() {
        feature1Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
        feature1Label.text = uiProviderDelegate?.featureOne() ?? ""
        
        feature2Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
        feature2Label.text = uiProviderDelegate?.featureTwo() ?? ""
        
        feature3Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
        feature3Label.text = uiProviderDelegate?.featureThree() ?? ""
        
        feature4Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
        feature4Label.text = uiProviderDelegate?.featureFour() ?? ""
    }
    
    private func _configureFreeTrialLabel() {
        let title = "Try 7 days Free Trial".localized
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font:  UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 11) ?? UIFont.systemFont(ofSize: 11)])
        freeTrialLabel.attributedText = attributedString
    }
    
    private func _configurePriceButton() {
        for button in priceButtons {
            button.layer.cornerRadius = 6
            button.titleLabel?.textAlignment = .center
        }
    }
    
    private let boldAttribute = [NSAttributedString.Key.font:  UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 30) ?? UIFont.systemFont(ofSize: 30)]
    private let regularAttribute = [NSAttributedString.Key.font: UIFont.font(.sofiaProRegular, style: .footnote)]
    private let semiBoldAttribute = [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .footnote)]
    private let priceAttribute = [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .headline)]
    private let newLine = NSMutableAttributedString(string: "\n")
    
    private func _configureFirstSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 0, withDurationSuffix: false) ?? "-"
        let attributedString = NSMutableAttributedString(string: "1\n", attributes: boldAttribute)
        let partone = NSMutableAttributedString(string: "week pack".localized, attributes: regularAttribute)
        let partTwo = NSMutableAttributedString(string: "at".localized, attributes: semiBoldAttribute)
        let pricePart = NSMutableAttributedString(string: " \(price)", attributes: priceAttribute)
        attributedString.append(partone)
        attributedString.append(newLine)
        attributedString.append(partTwo)
        attributedString.append(pricePart)
        firstSubscriptionButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func _configureSecondSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 1, withDurationSuffix: false) ?? "-"
        let attributedString = NSMutableAttributedString(string: "1\n", attributes: boldAttribute)
        let partone = NSMutableAttributedString(string: "month pack".localized, attributes: regularAttribute)
        let partTwo = NSMutableAttributedString(string: "at".localized, attributes: semiBoldAttribute)
        let pricePart = NSMutableAttributedString(string: " \(price)", attributes: priceAttribute)
        attributedString.append(partone)
        attributedString.append(newLine)
        attributedString.append(partTwo)
        attributedString.append(pricePart)
        secondSubscriptionButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func _configureThirdSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 2, withDurationSuffix: false) ?? "-"
        let attributedString = NSMutableAttributedString(string: "12\n", attributes: boldAttribute)
        let partone = NSMutableAttributedString(string: "months pack".localized, attributes: regularAttribute)
        let partTwo = NSMutableAttributedString(string: "at".localized, attributes: semiBoldAttribute)
        let pricePart = NSMutableAttributedString(string: " \(price)", attributes: priceAttribute)
        attributedString.append(partone)
        attributedString.append(newLine)
        attributedString.append(partTwo)
        attributedString.append(pricePart)
        thirdSubscriptionButton.setAttributedTitle(attributedString, for: .normal)
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
        cancelButton.isHidden = hideCloseButton ? true : false
    }
    

    private func highlightButton(at index: Int) {
        let button = priceButtons[index]
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.primaryColor.cgColor
        
        let tickImage = tickMarkImageViews[index]
        tickImage.isHidden = false
        
        priceButtonStandardHeight[index].priority = UILayoutPriority(rawValue: 250)
        priceButtonsZoomedHeight[index].priority = UILayoutPriority(rawValue: 750)
    }
    
    private func unhighlightButton(at index: Int) {
        let button = priceButtons[index]
        button.layer.borderWidth = 0
        
        let tickImage = tickMarkImageViews[index]
        tickImage.isHidden = true
        
        priceButtonsZoomedHeight[index].priority = UILayoutPriority(rawValue: 250)
        priceButtonStandardHeight[index].priority = UILayoutPriority(rawValue: 750)
    }
    
    private func checkFreeOfferTrialStatus(for index: Int) {
        let offersFreeTrial = uiProviderDelegate!.offersFreeTrial(for: index)
        if offersFreeTrial {
            freeTrialLabel.isHidden = false
            subscribeButton.setTitle("Start Free Trial".localized, for: .normal)
        } else {
            subscribeButton.setTitle("Subscribe Now".localized, for: .normal)
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
