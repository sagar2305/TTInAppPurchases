import UIKit
import Lottie
import NVActivityIndicatorView
import SwiftUI
import StoreKit

public class QuadrupleOptionPaywallViewController: UIViewController, SubscriptionViewControllerProtocol {
    
    // MARK: - Properties
    public weak var delegate: SubscriptionViewControllerDelegate?
    public weak var uiProviderDelegate: UpgradeUIProviderDelegate?
    public var hideCloseButton: Bool = false
    public var lifetimeOffer: Bool = false
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("𝘅", for: .normal)
        button.titleLabel?.font = UIFont.font(.sofiaProBold, style: .title2)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var primaryHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProBlack, style: .title2)
        label.text = "Upgrade To Premium".localized
        label.textAlignment = .center
        return label
    }()
    
    private lazy var topDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProLight, style: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var reviewCarouselView: ReviewCarouselView = {
        let view = ReviewCarouselView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var featureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var freeTrialInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProRegular, style: .subheadline)
        label.textAlignment = .center
        label.text = "7 day free trial, then $59.99/year"
        return label
    }()
    
    private lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.font(.sofiaProMedium, style: .title3)
        button.setTitle("CONTINUE".localized, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapSubscribeNowButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProMedium, style: .subheadline)
        label.textAlignment = .center
        label.text = "No payment now! Save 75%"
        label.textColor = .systemGreen
        return label
    }()
    
    private lazy var subscriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var freeTrialLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProSemibold, style: .footnote)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var restorePurchasesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.font(.sofiaProRegular, style: .footnote)
        button.setTitle("Restore Purchase".localized, for: .normal)
        button.addTarget(self, action: #selector(didTapRestorePurchase), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyAndTermsOfLawLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProRegular, style: .footnote)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var priceButtons: [UIButton] = []
    private var tickMarkViews: [UIView] = []
    
    // MARK: - Internal Properties
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
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        _selectedIndex = 2
        
        _configureUI()
        _configureHeaderLabels()
        _configureDescriptionLabels()
        _configureFeatureLabel()
        _configureCancelButton()
        _configurePriceButton()
        _configureSubscribeButton()
        _configurePriceButtonTitle()
        _configureRestorePurchasesButton()
        _configurePrivacyAndTermsOfLawLabel()
        
        setupSubscriptionButtons()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewWillAppear(self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(self)
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [cancelButton, primaryHeaderLabel, topDescriptionLabel, reviewCarouselView, featureStackView, 
         freeTrialInfoLabel, subscribeButton, saveInfoLabel, subscriptionStackView, 
         freeTrialLabel, restorePurchasesButton, privacyAndTermsOfLawLabel].forEach { contentView.addSubview($0) }
        
        for _ in 0..<3 {
            let button = createPriceButton()
            priceButtons.append(button)
            subscriptionStackView.addArrangedSubview(button)
            
            let tickMark = createTickMarkView()
            tickMarkViews.append(tickMark)
            button.addSubview(tickMark)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Increase the top spacing for the primary header label
            primaryHeaderLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32), // Changed from 8 to 32
            primaryHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            primaryHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topDescriptionLabel.topAnchor.constraint(equalTo: primaryHeaderLabel.bottomAnchor, constant: 16),
            topDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewCarouselView.topAnchor.constraint(equalTo: topDescriptionLabel.bottomAnchor, constant: 16),
            reviewCarouselView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewCarouselView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewCarouselView.heightAnchor.constraint(equalToConstant: 100),
            
            featureStackView.topAnchor.constraint(equalTo: reviewCarouselView.bottomAnchor, constant: 24),
            featureStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            featureStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            freeTrialInfoLabel.topAnchor.constraint(equalTo: featureStackView.bottomAnchor, constant: 32),
            freeTrialInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            freeTrialInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subscribeButton.topAnchor.constraint(equalTo: freeTrialInfoLabel.bottomAnchor, constant: 16),
            subscribeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),

            saveInfoLabel.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 8),
            saveInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subscriptionStackView.topAnchor.constraint(equalTo: saveInfoLabel.bottomAnchor, constant: 32),
            subscriptionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscriptionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            freeTrialLabel.topAnchor.constraint(equalTo: subscriptionStackView.bottomAnchor, constant: 8),
            freeTrialLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            restorePurchasesButton.topAnchor.constraint(equalTo: freeTrialLabel.bottomAnchor, constant: 16),
            restorePurchasesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            privacyAndTermsOfLawLabel.topAnchor.constraint(equalTo: restorePurchasesButton.bottomAnchor, constant: 16),
            privacyAndTermsOfLawLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            privacyAndTermsOfLawLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            privacyAndTermsOfLawLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func createPriceButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.addTarget(self, action: #selector(subscriptionButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createTickMarkView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }
    
    // MARK: - UI Configuration
    private func _configureUI() {
        // Configure UI based on screen size
    }
    
    private func _configureHeaderLabels() {
        // Already configured in lazy var
    }
    
    private func _configureDescriptionLabels() {
        topDescriptionLabel.text = uiProviderDelegate?.headerMessage(for: 0) ?? ""
    }
    
    private func _configureFeatureLabel() {
        let features = uiProviderDelegate?.allFeatures(lifetimeOffer: lifetimeOffer) ?? []
        for feature in features {
            if feature != "Easy call recordings" {
                let label = UILabel()
                label.font = UIFont.font(.sofiaProRegular, style: featureLabelTextStyle)
                label.text = "✓ " + feature
                label.numberOfLines = 0
                label.textAlignment = .center
                featureStackView.addArrangedSubview(label)
            }
        }
    }
    
    private func _configureCancelButton() {
        cancelButton.alpha = hideCloseButton ? 0.0 : 0.8
    }
    
    private func _configurePriceButton() {
        // Already configured in createPriceButton()
    }
    
    private func _configureSubscribeButton() {
        // Already configured in lazy var
    }
    
    private func _configurePriceButtonTitle() {
        for (index, button) in priceButtons.enumerated() {
            let title = uiProviderDelegate?.subscriptionTitle(for: index) ?? ""
            let price = uiProviderDelegate?.subscriptionPrice(for: index, withDurationSuffix: true) ?? ""
            button.setTitle("\(title)\n\(price)", for: .normal)
        }
    }
    
    private func _configureRestorePurchasesButton() {
        // Already configured in lazy var
    }
    
    private func _configurePrivacyAndTermsOfLawLabel() {
        let text = "Terms of law".localized + " " + "and".localized + " " + "Privacy policy".localized
        let attributedString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms of law".localized)
        let range2 = (text as NSString).range(of: "Privacy policy".localized)
        
        attributedString.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.systemBlue], range: range1)
        attributedString.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.systemBlue], range: range2)
        privacyAndTermsOfLawLabel.attributedText = attributedString
    }
    
    private func setupSubscriptionButtons() {
        // Setup subscription buttons
    }
    
    // MARK: - Helper Methods
    private func highlightButton(at index: Int) {
        // Highlight selected button
    }
    
    private func unhighlightButton(at index: Int) {
        // Unhighlight deselected button
    }
    
    private func checkFreeOfferTrialStatus(for index: Int) {
        // Check and update free trial status
    }
    
    // MARK: - IBActions
    @objc private func subscriptionButtonTapped(_ sender: UIButton) {
        _selectedIndex = sender.tag
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