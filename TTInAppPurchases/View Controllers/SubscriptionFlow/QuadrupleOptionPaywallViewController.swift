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
    
    public lazy var reviewCarouselView: ReviewCarouselView = {
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
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapSubscribeNowButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var mostPopularLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProBold, style: .footnote)
        label.text = "Most Popular"
        label.textColor = .white
        label.backgroundColor = .systemGreen
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var saveInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProMedium, style: .subheadline)
        label.textAlignment = .center
        label.text = "Save 75% • Top Rated Plan"
        label.textColor = .systemGreen
        return label
    }()
    
    private lazy var subscriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = true
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
        let attributedTitle = NSAttributedString(string: "Restore Purchase".localized, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.white
        ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(didTapRestorePurchase), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyAndTermsOfLawLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProRegular, style: .footnote)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var priceButtons: [UIButton] = []
    private var tickMarkViews: [UIView] = []
    
    // MARK: - Internal Properties
    private let bounds = UIScreen.main.bounds
    private var featureLabelTextStyle: UIFont.TextStyle = .callout
    private var restoreButtonTextStyle: UIFont.TextStyle = .footnote
    private let characterSet = CharacterSet(charactersIn: "0123456789.").inverted
    
    private var _selectedIndex = -1 {
        didSet {
            if isViewLoaded {
                checkFreeOfferTrialStatus(for: _selectedIndex)
                if oldValue != -1 {
                    unhighlightButton(at: oldValue)
                }
                if _selectedIndex != -1 {
                    highlightButton(at: _selectedIndex)
                }
            }
        }
    }
    
    private var selectedIndex: Int = 0 // Set default to 0 for the continue button
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupButtonConstraints()
        
        _configureUI()
        _configureHeaderLabels()
        _configureDescriptionLabels()
        _configureFeatureLabel()
        _configureCancelButton()
        _configureRestorePurchasesButton()
        _configurePrivacyAndTermsOfLawLabel()
        
        if uiProviderDelegate!.productsFetched() {
            setupSubscriptionButtons(notification: nil)
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(setupSubscriptionButtons(notification:)),
                                                   name: Notification.Name.iapProductsFetchedNotification,
                                                   object: nil)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [cancelButton, primaryHeaderLabel, topDescriptionLabel, reviewCarouselView, featureStackView, 
         freeTrialInfoLabel, subscribeButton, mostPopularLabel, saveInfoLabel, subscriptionStackView, 
         freeTrialLabel, restorePurchasesButton, privacyAndTermsOfLawLabel].forEach { contentView.addSubview($0) }
        
        subscriptionStackView.isUserInteractionEnabled = true
        
        for _ in 0..<3 {
            let button = createPriceButton()
            priceButtons.append(button)
            subscriptionStackView.addArrangedSubview(button)
            
            let tickMark = createTickMarkView()
            tickMarkViews.append(tickMark)
            button.addSubview(tickMark)
        }
        
        scrollView.isScrollEnabled = true
        updateScrollViewContentSize()
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
            
            primaryHeaderLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32),
            primaryHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            primaryHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topDescriptionLabel.topAnchor.constraint(equalTo: primaryHeaderLabel.bottomAnchor, constant: 16),
            topDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewCarouselView.topAnchor.constraint(equalTo: topDescriptionLabel.bottomAnchor, constant: 16),
            reviewCarouselView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewCarouselView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewCarouselView.heightAnchor.constraint(equalToConstant: 130),
            
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

            mostPopularLabel.topAnchor.constraint(equalTo: subscribeButton.topAnchor, constant: -10),
            mostPopularLabel.trailingAnchor.constraint(equalTo: subscribeButton.trailingAnchor, constant: 10),
            mostPopularLabel.widthAnchor.constraint(equalToConstant: 100),
            mostPopularLabel.heightAnchor.constraint(equalToConstant: 20),

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
            privacyAndTermsOfLawLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtonConstraints() {
        for button in priceButtons {
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 70),
                button.widthAnchor.constraint(equalTo: subscriptionStackView.widthAnchor)
            ])
        }
    }
    
    private func createPriceButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .systemGray5
        
        // Add a subtle shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.layer.masksToBounds = false

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
    
    @objc func setupSubscriptionButtons(notification: Notification?) {
        NVActivityIndicatorView.stop()
        _configurePriceButtonTitle()
        _configureSubscribeButton()
    }
    
    private func _configurePriceButtonTitle() {
        guard let uiProviderDelegate = uiProviderDelegate else { return }
        
        for (index, button) in priceButtons.enumerated() {
            let price = uiProviderDelegate.subscriptionPrice(for: index + 1, withDurationSuffix: false)
            let pricePerMonth = uiProviderDelegate.subscriptionPricePerMonth(for: index + 1)
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.isUserInteractionEnabled = false // Disable user interaction on container
            button.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: button.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: button.trailingAnchor)
            ])
            
            let leftStackView = UIStackView()
            leftStackView.axis = .vertical
            leftStackView.alignment = .leading
            leftStackView.translatesAutoresizingMaskIntoConstraints = false
            leftStackView.isUserInteractionEnabled = false // Disable user interaction on left stack view
            
            let rightStackView = UIStackView()
            rightStackView.axis = .vertical
            rightStackView.alignment = .trailing
            rightStackView.translatesAutoresizingMaskIntoConstraints = false
            rightStackView.isUserInteractionEnabled = false // Disable user interaction on right stack view
            
            containerView.addSubview(leftStackView)
            containerView.addSubview(rightStackView)
            
            NSLayoutConstraint.activate([
                leftStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                leftStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                rightStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                rightStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            // Configure button content based on index
            switch index {
            case 0: // Monthly
                configureMonthlyButton(leftStackView: leftStackView, rightStackView: rightStackView, price: price, pricePerMonth: pricePerMonth)
            case 1: // Lifetime
                configureLifetimeButton(leftStackView: leftStackView, rightStackView: rightStackView, price: price, button: button)
            case 2: // Weekly
                configureWeeklyButton(leftStackView: leftStackView, rightStackView: rightStackView, price: price, pricePerMonth: pricePerMonth)
            default:
                break
            }
            
            // Ensure the button is on top of the container view
            button.bringSubviewToFront(button.titleLabel!)
        }
    }

    private func configureMonthlyButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, pricePerMonth: Double?) {
        let title = "Subscribe Monthly"
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.font(.sofiaProRegular, style: .callout)
        titleLabel.textColor = .white
        
        let priceLabel = UILabel()
        priceLabel.text = price + " per month"
        priceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        priceLabel.textColor = .white
        
        leftStackView.addArrangedSubview(titleLabel)
        leftStackView.addArrangedSubview(priceLabel)
        
        if let pricePerMonth = pricePerMonth {
            let yearlyPrice = round(pricePerMonth * 12)
            let yearlyPriceLabel = UILabel()
            yearlyPriceLabel.text = "$\(Int(yearlyPrice))"
            yearlyPriceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
            yearlyPriceLabel.textColor = .white
            
            let perYearLabel = UILabel()
            perYearLabel.text = "per year"
            perYearLabel.font = UIFont.font(.sofiaProRegular, style: .footnote)
            perYearLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            
            rightStackView.addArrangedSubview(yearlyPriceLabel)
            rightStackView.addArrangedSubview(perYearLabel)
        }
    }

    private func configureLifetimeButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, button: UIButton) {
        let lifetimeLabel = UILabel()
        lifetimeLabel.text = "Lifetime"
        lifetimeLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        lifetimeLabel.textColor = .white
    
        
        leftStackView.addArrangedSubview(lifetimeLabel)
        
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        priceLabel.textColor = .white
        
        rightStackView.addArrangedSubview(priceLabel)
        
        // Add "Best Value" label
        let bestValueLabel = UILabel()
        bestValueLabel.text = "Best Value"
        bestValueLabel.font = UIFont.font(.sofiaProBold, style: .footnote)
        bestValueLabel.textColor = .white
        bestValueLabel.backgroundColor = .systemOrange
        bestValueLabel.textAlignment = .center
        bestValueLabel.layer.cornerRadius = 10
        bestValueLabel.clipsToBounds = true
        bestValueLabel.isUserInteractionEnabled = false // Disable user interaction on the "Best Value" label
        bestValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove any existing "Best Value" label
        subscriptionStackView.subviews.first(where: { $0.accessibilityIdentifier == "BestValueLabel" })?.removeFromSuperview()
        
        // Add the label to the subscription stack view
        subscriptionStackView.addSubview(bestValueLabel)
        bestValueLabel.accessibilityIdentifier = "BestValueLabel"
        
        NSLayoutConstraint.activate([
            bestValueLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: -10),
            bestValueLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 10),
            bestValueLabel.widthAnchor.constraint(equalToConstant: 80),
            bestValueLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func configureWeeklyButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, pricePerMonth: Double?) {
        let titleLabel = UILabel()
        titleLabel.text = "Subscribe Weekly"
        titleLabel.font = UIFont.font(.sofiaProRegular, style: .callout)
        titleLabel.textColor = .white
        
        let priceLabel = UILabel()
        priceLabel.text = price + " per week"
        priceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        priceLabel.textColor = .white
        
        leftStackView.addArrangedSubview(titleLabel)
        leftStackView.addArrangedSubview(priceLabel)
        
        if let pricePerMonth = pricePerMonth {
            let yearlyPrice = round(pricePerMonth * 12)
            let yearlyPriceLabel = UILabel()
            yearlyPriceLabel.text = "$\(Int(yearlyPrice))"
            yearlyPriceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
            yearlyPriceLabel.textColor = .white
            
            let perYearLabel = UILabel()
            perYearLabel.text = "per year"
            perYearLabel.font = UIFont.font(.sofiaProRegular, style: .footnote)
            perYearLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            
            rightStackView.addArrangedSubview(yearlyPriceLabel)
            rightStackView.addArrangedSubview(perYearLabel)
        }
    }

    private func _configureSubscribeButton() {
        subscribeButton.setTitle("CONTINUE", for: .normal)
        updateFreeTrialInfo()
    }

    private func updateFreeTrialInfo() {
        guard let uiProviderDelegate = uiProviderDelegate else { return }
        
        let trialDuration = uiProviderDelegate.freeTrialDuration(for: 0)
        let price = uiProviderDelegate.subscriptionPrice(for: 0, withDurationSuffix: false)
        
        let attributedString = NSMutableAttributedString()
        
        if !trialDuration.isEmpty {
            attributedString.append(NSAttributedString(string: "\(trialDuration) free trial, then ", attributes: [.font: UIFont.font(.sofiaProRegular, style: .title3), .foregroundColor: UIColor.label]))
        }
        
        attributedString.append(NSAttributedString(string: price, attributes: [.font: UIFont.font(.sofiaProBold, style: .title3), .foregroundColor: UIColor.label]))
        attributedString.append(NSAttributedString(string: " / year", attributes: [.font: UIFont.font(.sofiaProRegular, style: .title3), .foregroundColor: UIColor.label]))
        
        freeTrialInfoLabel.attributedText = attributedString
    }

    // MARK: - Helper Methods
    private func highlightButton(at index: Int) {
        priceButtons.forEach { $0.backgroundColor = .systemGray5 }
        priceButtons[index].backgroundColor = .systemBlue
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        updateFreeTrialInfo()
    }
    
    private func unhighlightButton(at index: Int) {
        priceButtons[index].backgroundColor = .systemGray5
    }
    
    private func checkFreeOfferTrialStatus(for index: Int) {
        // Check and update free trial status
    }

    // MARK: - IBActions
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let index = priceButtons.firstIndex(of: sender) else { return }
        selectedIndex = index + 1
        delegate?.selectPlan(at: selectedIndex, controller: self)
    }

    @IBAction func didTapSubscribeNowButton(_ sender: UIButton) {
        delegate?.selectPlan(at: selectedIndex, controller: self)
    }

    @IBAction func didTapCancelButton(_ sender: UIButton) {
        delegate?.exit(self)
    }

    @IBAction func didTapRestorePurchase(_ sender: Any) {
        delegate?.restorePurchases(self)
    }

    private func updateScrollViewContentSize() {
        DispatchQueue.main.async {
            self.scrollView.contentSize = self.contentView.bounds.size
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewContentSize()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(self)
        
        updateScrollViewContentSize()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateScrollViewContentSize()
        }
    }
}
