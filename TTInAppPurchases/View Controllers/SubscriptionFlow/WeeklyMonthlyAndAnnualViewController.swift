//
//  WeeklyMonthlyAndAnnualViewController.swift
//  TTInAppPurchases
//
//  Created by Revathi on 18/04/22.
//

import UIKit
import Lottie
import NVActivityIndicatorView
import CoreAudio

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
    
    //MARK: External Parameters
    public weak var delegate: SubscriptionViewControllerDelegate?
    public weak var uiProviderDelegate: UpgradeUIProviderDelegate?
    public weak var specialOfferUIProviderDelegate: SpecialOfferUIProviderDelegate?
    public var giftOffer: Bool = false
    public var hideCloseButton: Bool = false
    
    //MARK: Internal Parameters
    private let lottieView = AnimationView(name: "HelloAnimation")
    private let bounds = UIScreen.main.bounds
    private var featureLabelTextStyle: UIFont.TextStyle = .callout
    
    private var _selectedIndex = 1 {
        didSet {
            if isViewLoaded {
                
                checkFreeOfferTrialStatus(for: _selectedIndex)
                
                switch(_selectedIndex) {
                case 0:
                    highlightButton(at: 0)
                    unhighlightButton(at: 1)
                    unhighlightButton(at: 2)
                case 1:
                    highlightButton(at: 1)
                    unhighlightButton(at: 0)
                    unhighlightButton(at: 2)
                case 2:
                    highlightButton(at: 2)
                    unhighlightButton(at: 0)
                    unhighlightButton(at: 1)
                default: break
                }
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
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(self)
    }
    
    @objc func setupSubscriptionButtons(notification: Notification?) {
        NVActivityIndicatorView.stop()

        _configureFirstSubscriptionButton()
        _configureSecondSubscriptionButton()
        _configureThirdSubscriptionButton()
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
    
    // TODO: Add localized text for dummy header and description labels
    private func _configureHeaderLabels() {
        primaryHeaderLabel.configure(with: UIFont.font(.sofiaProBold, style: .title2))
        primaryHeaderLabel.text = "Upgrade To Premium"
        
        bottomHeaderLabel.configure(with: UIFont.font(.sofiaProSemibold, style: .subheadline))
        bottomHeaderLabel.text = "Download, Try and Test the App"
    }
    
    private func _configureDescriptionLabels() {
        topDescriptionLabel.configure(with: UIFont.font(.sofiaProLight, style: .caption2))
        topDescriptionLabel.text = "EZTape Call Recorder is the simplest and most seamless recording app on the app store. This business app allows you to record your incoming and outgoing phone calls."
        
        bottomDescriptionLabel.configure(with: UIFont.font(.sofiaProRegular, style: .caption1))
        bottomDescriptionLabel.text = "Call recordings like never before on your iOS device. Call, Record*, Store and Share the call with your teammates. *We are supporting the online and outdoor call recording where you don’t have anything to write the important stuff. We are not breaching anyone’s privacy policy."
    }
    
    private func _configureFeatureLabel() {
        feature1Label.configure(with: UIFont.font(.sofiaProMedium, style: .caption2))
        feature1Label.text = "Automatic call recordings or tap call merging"
        
        feature2Label.configure(with: UIFont.font(.sofiaProMedium, style: .caption2))
        feature2Label.text = "Unlimited recordings for the selected days"
        
        feature3Label.configure(with: UIFont.font(.sofiaProMedium, style: .caption2))
        feature3Label.text = "No extra fee to record inbound calls"
        
        feature4Label.configure(with: UIFont.font(.sofiaProMedium, style: .caption2))
        feature4Label.text = "Easy and hassle-free cancellation"
    }
    
    private func _configureFreeTrialLabel() {
        let title = "Try 7 days Free Trial"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProMedium.rawValue, size: 8) ?? UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 3))
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 11) ?? UIFont.systemFont(ofSize: 11), range: NSRange(location: 4, length: 1))
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProMedium.rawValue, size: 8) ?? UIFont.systemFont(ofSize: 8), range: NSRange(location: 6, length: 4))
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 11) ?? UIFont.systemFont(ofSize: 11), range: NSRange(location: 11, length: 10))
        
        freeTrialLabel.attributedText = attributedString
    }
    
    private func _configurePriceButton() {
        for button in priceButtons {
            button.layer.cornerRadius = 6
            button.titleLabel?.textAlignment = .center
        }
    }
    
    // TODO: Localize button title text
    private func _configureFirstSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 0, withDurationSuffix: false) ?? "-"
        let title = "1\nweek pack\nat"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 30) ?? UIFont.systemFont(ofSize: 30), range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.font, value: UIFont.font(.sofiaProRegular, style: .footnote), range: NSRange(location: 2, length: 9))
        attributedString.addAttribute(.font, value: UIFont.font(.sofiaProSemibold, style: .footnote), range: NSRange(location: 12, length: 2))
        let attrString = NSMutableAttributedString(string: " \(price)",
                                                   attributes: [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .headline)])
        attributedString.append(attrString)
        firstSubscriptionButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func _configureSecondSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 1, withDurationSuffix: false) ?? "-"
        let title = "1\nmonth pack\nat"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 30) ?? UIFont.systemFont(ofSize: 30), range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.font, value: UIFont.font(.sofiaProRegular, style: .footnote), range: NSRange(location: 2, length: 10))
        attributedString.addAttribute(.font, value: UIFont.font(.sofiaProSemibold, style: .footnote), range: NSRange(location: 13, length: 2))
        let attrString = NSMutableAttributedString(string: " \(price)",
                                                   attributes: [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .headline)])
        attributedString.append(attrString)
        secondSubscriptionButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func _configureThirdSubscriptionButton() {
        let price = uiProviderDelegate?.subscriptionPrice(for: 2, withDurationSuffix: false) ?? "-"
        let title = "12\nmonths pack\nat"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: Constants.Fonts.sofiaProBold.rawValue, size: 30) ?? UIFont.systemFont(ofSize: 30), range: NSRange(location: 0, length: 2))
        attributedString.addAttribute(.font, value: UIFont.font(.sofiaProRegular, style: .footnote), range: NSRange(location: 3, length: 11))
        attributedString.addAttribute(.font, value: UIFont.font(.sofiaProSemibold, style: .footnote), range: NSRange(location: 15, length: 2))
        let attrString = NSMutableAttributedString(string: " \(price)",
                                                   attributes: [NSAttributedString.Key.font: UIFont.font(.sofiaProSemibold, style: .headline)])
        attributedString.append(attrString)
        thirdSubscriptionButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func _configureSubscribeButton() {
        subscribeButton.titleLabel?.configure(with: UIFont.font(.sofiaProMedium, style: .title3))
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
            subscribeButton.setTitle("Start Free Trial", for: .normal)
        } else {
            subscribeButton.setTitle("Subscribe Now", for: .normal)
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

}
