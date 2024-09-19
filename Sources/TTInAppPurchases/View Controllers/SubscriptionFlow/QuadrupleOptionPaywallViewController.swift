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
    public let screenHeight = UIScreen.main.bounds.height
    
    // MARK: - UI Elements
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
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var topDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProLight, style: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
        stackView.spacing = calculateSpacing() * 0.7
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        return stackView
    }()
    
    private lazy var continueButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = false // Allow shadow to be visible
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var freeTrialInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProMedium, style: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.font(.sofiaProBold, style: .headline)
        button.setTitle("CONTINUE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapSubscribeNowButton), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = button.bounds
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        return button
    }()
    
    private lazy var saveInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProMedium, style: .subheadline)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
    
    private lazy var cancelAnytimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProBold, style: .subheadline)
        label.text = "Cancel at any time"
        label.textColor = .systemGreen
        label.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var restorePurchasesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.font(.sofiaProRegular, style: .footnote)
        let attributedTitle = NSAttributedString(string: "Restore Purchase".localized, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.label
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
        
        updateColorsForCurrentTraitCollection()
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        [cancelButton, primaryHeaderLabel, topDescriptionLabel, reviewCarouselView, featureStackView,
         continueButtonContainer, subscriptionStackView, cancelAnytimeLabel, restorePurchasesButton, 
         privacyAndTermsOfLawLabel].forEach { view.addSubview($0) }
        
        continueButtonContainer.addSubview(freeTrialInfoLabel)
        continueButtonContainer.addSubview(subscribeButton)
        continueButtonContainer.addSubview(saveInfoLabel)
        
        subscriptionStackView.isUserInteractionEnabled = true
        
        for _ in 0..<3 {
            let button = createPriceButton()
            priceButtons.append(button)
            subscriptionStackView.addArrangedSubview(button)
            
            let tickMark = createTickMarkView()
            tickMarkViews.append(tickMark)
            button.addSubview(tickMark)
        }
        
        // Ensure continue button container and its subviews are set up properly
        continueButtonContainer.addSubview(freeTrialInfoLabel)
        continueButtonContainer.addSubview(subscribeButton)
        continueButtonContainer.addSubview(saveInfoLabel)
        
        // Force layout update
        continueButtonContainer.setNeedsLayout()
        continueButtonContainer.layoutIfNeeded()
    }
    
    private func calculateSpacing() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
            case 926...932: // iPhone 15 Pro Max, 14 Plus, 13 Pro Max, 12 Pro Max (6.7 inches)
                return 16
            case 844...896: // iPhone 15, iPhone 14, 13/12 Pro, 13/12, 11 Pro Max, XS Max, 11, XR (6.1 - 6.5 inches)
                return 16
            case 812: // iPhone X, XS (5.8 inches) and iPhone 13 Mini, 12 Mini (5.4 inches)
                return 12
            case 736: // iPhone 8 Plus, iPhone 7 Plus (5.5 inches)
                return 8
            case 667: // iPhone 8, iPhone 7, SE 2nd/3rd Gen (4.7 inches)
                return 8
            case 568: // iPhone SE 1st Gen, iPhone 5s, 5c (4 inches)
                return 6
            default:
                return 8 // Default font size for unlisted screen sizes
            }
    }
    
    private func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            primaryHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: calculateSpacing()),
            primaryHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            primaryHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            topDescriptionLabel.topAnchor.constraint(equalTo: primaryHeaderLabel.bottomAnchor, constant: calculateSpacing()),
            topDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            reviewCarouselView.topAnchor.constraint(equalTo: topDescriptionLabel.bottomAnchor, constant: 16),
            reviewCarouselView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            reviewCarouselView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            reviewCarouselView.heightAnchor.constraint(equalToConstant: getScreenHeight() * 0.14),
            
            featureStackView.topAnchor.constraint(equalTo: reviewCarouselView.bottomAnchor, constant: calculateSpacing()),
            featureStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            featureStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            continueButtonContainer.topAnchor.constraint(equalTo: featureStackView.bottomAnchor, constant: calculateSpacing() * 1.5),
            continueButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            freeTrialInfoLabel.topAnchor.constraint(equalTo: continueButtonContainer.topAnchor, constant: 20),
            freeTrialInfoLabel.leadingAnchor.constraint(equalTo: continueButtonContainer.leadingAnchor, constant: 20),
            freeTrialInfoLabel.trailingAnchor.constraint(equalTo: continueButtonContainer.trailingAnchor, constant: -20),

            subscribeButton.topAnchor.constraint(equalTo: freeTrialInfoLabel.bottomAnchor, constant: 16),
            subscribeButton.leadingAnchor.constraint(equalTo: continueButtonContainer.leadingAnchor, constant: 20),
            subscribeButton.trailingAnchor.constraint(equalTo: continueButtonContainer.trailingAnchor, constant: -20),
            subscribeButton.heightAnchor.constraint(equalToConstant: 56),

            saveInfoLabel.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 16),
            saveInfoLabel.leadingAnchor.constraint(equalTo: continueButtonContainer.leadingAnchor, constant: 20),
            saveInfoLabel.trailingAnchor.constraint(equalTo: continueButtonContainer.trailingAnchor, constant: -20),
            saveInfoLabel.bottomAnchor.constraint(equalTo: continueButtonContainer.bottomAnchor, constant: -20),
            
            subscriptionStackView.topAnchor.constraint(equalTo: continueButtonContainer.bottomAnchor, constant: calculateSpacing()),
            subscriptionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscriptionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cancelAnytimeLabel.topAnchor.constraint(equalTo: subscriptionStackView.bottomAnchor, constant: 5),
            cancelAnytimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelAnytimeLabel.heightAnchor.constraint(equalToConstant: 30),
            cancelAnytimeLabel.widthAnchor.constraint(equalToConstant: 160),
            
            restorePurchasesButton.topAnchor.constraint(equalTo: cancelAnytimeLabel.bottomAnchor, constant: 8),
            restorePurchasesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            privacyAndTermsOfLawLabel.topAnchor.constraint(equalTo: restorePurchasesButton.bottomAnchor, constant: 4),
            privacyAndTermsOfLawLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            privacyAndTermsOfLawLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            privacyAndTermsOfLawLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            privacyAndTermsOfLawLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtonConstraints() {
        for button in priceButtons {
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: getScreenHeight() * 0.075),
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
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        button.layer.borderWidth = 1
        
        // Add a subtle shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
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
                label.setContentHuggingPriority(.required, for: .vertical)
                label.setContentCompressionResistancePriority(.required, for: .vertical)
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
            
            // Create a container view for the button
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.isUserInteractionEnabled = false
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
            leftStackView.isUserInteractionEnabled = false
            
            let rightStackView = UIStackView()
            rightStackView.axis = .vertical
            rightStackView.alignment = .trailing
            rightStackView.translatesAutoresizingMaskIntoConstraints = false
            rightStackView.isUserInteractionEnabled = false
            
            containerView.addSubview(leftStackView)
            containerView.addSubview(rightStackView)
            
            NSLayoutConstraint.activate([
                leftStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                leftStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                rightStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                rightStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            // Handle button content based on index
            switch index {
            case 0: // Monthly
                if let pricePerMonth = uiProviderDelegate.subscriptionPricePerMonth(for: index + 1) {
                    configureMonthlyButton(leftStackView: leftStackView, rightStackView: rightStackView, price: price, pricePerMonth: pricePerMonth)
                }
            case 1: // Lifetime
                configureLifetimeButton(leftStackView: leftStackView, rightStackView: rightStackView, price: price, button: button)
            case 2: // Weekly
                if let pricePerMonth = uiProviderDelegate.subscriptionPricePerMonth(for: index + 1) {
                    configureWeeklyButton(leftStackView: leftStackView, rightStackView: rightStackView, price: price, pricePerMonth: pricePerMonth)
                }
            default:
                break
            }
            
            // Ensure the button title label is on top of the container view
            button.bringSubviewToFront(button.titleLabel!)
        }
    }


    private func configureMonthlyButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, pricePerMonth: Double) {
        // This function configures the UI for the monthly subscription option
        
        // Create and configure the title label for "Subscribe Monthly"
        let titleLabel = UILabel()
        titleLabel.text = "Subscribe Monthly"
        titleLabel.font = UIFont.font(.sofiaProRegular, style: .callout)
        titleLabel.textColor = .label
        
        // Create and configure the price label showing the monthly price
        let priceLabel = UILabel()
        priceLabel.text = price + " per month"
        priceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        priceLabel.textColor = .label
        
        // Add the title and price labels to the left stack view
        leftStackView.addArrangedSubview(titleLabel)
        leftStackView.addArrangedSubview(priceLabel)
        
        // Calculate the yearly price
        let yearlyPrice = pricePerMonth * 12
        
        // Create and configure the yearly price label
        let yearlyPriceLabel = UILabel()
        yearlyPriceLabel.text = formatPrice(yearlyPrice, currencyCode: getCurrencyCode(from: price), originalPriceString: price)
        yearlyPriceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        yearlyPriceLabel.textColor = .label
        
        // Create and configure the "per year" label
        let perYearLabel = UILabel()
        perYearLabel.text = "per year".localized
        perYearLabel.font = UIFont.font(.sofiaProRegular, style: .footnote)
        perYearLabel.textColor = UIColor.secondaryLabel
        
        // Add the yearly price and "per year" labels to the right stack view
        rightStackView.addArrangedSubview(yearlyPriceLabel)
        rightStackView.addArrangedSubview(perYearLabel)
    }

    private func configureLifetimeButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, button: UIButton) {
        let lifetimeLabel = UILabel()
        lifetimeLabel.text = "Lifetime"
        lifetimeLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        lifetimeLabel.textColor = .label
    
        
        leftStackView.addArrangedSubview(lifetimeLabel)
        
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        priceLabel.textColor = .label
        
        rightStackView.addArrangedSubview(priceLabel)
        
        // Add "Best Value" label
        let bestValueLabel = UILabel()
        bestValueLabel.text = "Best Value"
        bestValueLabel.font = UIFont.font(.sofiaProBold, style: .caption1)
        bestValueLabel.textColor = .white
        bestValueLabel.backgroundColor = .systemOrange
        bestValueLabel.textAlignment = .center
        bestValueLabel.layer.cornerRadius = 8
        bestValueLabel.clipsToBounds = true
        bestValueLabel.isUserInteractionEnabled = false // Disable user interaction on the "Best Value" label
        bestValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove any existing "Best Value" label
        subscriptionStackView.subviews.first(where: { $0.accessibilityIdentifier == "BestValueLabel" })?.removeFromSuperview()
        
        // Add the label to the subscription stack view
        subscriptionStackView.addSubview(bestValueLabel)
        bestValueLabel.accessibilityIdentifier = "BestValueLabel"
        
        NSLayoutConstraint.activate([
            bestValueLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: -8),
            bestValueLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8),
            bestValueLabel.widthAnchor.constraint(equalToConstant: 80),
            bestValueLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func configureWeeklyButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, pricePerMonth: Double) {
        let titleLabel = UILabel()
        titleLabel.text = "Subscribe Weekly"
        titleLabel.font = UIFont.font(.sofiaProRegular, style: .callout)
        titleLabel.textColor = .label
        
        let priceLabel = UILabel()
        priceLabel.text = price + " per week"
        priceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        priceLabel.textColor = .label
        
        leftStackView.addArrangedSubview(titleLabel)
        leftStackView.addArrangedSubview(priceLabel)
        
        let yearlyPrice = pricePerMonth * 12
        let yearlyPriceLabel = UILabel()
        yearlyPriceLabel.text = formatPrice(yearlyPrice, currencyCode: getCurrencyCode(from: price), originalPriceString: price)
        yearlyPriceLabel.font = UIFont.font(.sofiaProBold, style: .callout)
        yearlyPriceLabel.textColor = .label
        
        let perYearLabel = UILabel()
        perYearLabel.text = "per year".localized
        perYearLabel.font = UIFont.font(.sofiaProRegular, style: .footnote)
        perYearLabel.textColor = UIColor.secondaryLabel
        
        rightStackView.addArrangedSubview(yearlyPriceLabel)
        rightStackView.addArrangedSubview(perYearLabel)
    }

    private func formatPrice(_ price: Double, currencyCode: String, originalPriceString: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        numberFormatter.locale = Locale.current

        if let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) {
            // Extract the currency symbol from the original price string
            let originalSymbol = originalPriceString.components(separatedBy: CharacterSet.decimalDigits).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // Replace the formatted currency symbol with the original one and add a space
            return formattedPrice.replacingOccurrences(of: numberFormatter.currencySymbol, with: originalSymbol + " ")
        }
        
        // Fallback to a basic format if formatting fails
        return "\(currencyCode) \(price)"
    }

    private func getCurrencyCode(from priceString: String) -> String {
        let currencySymbol = priceString.components(separatedBy: CharacterSet.decimalDigits).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let locale = Locale.current
        
        if let currencyCode = locale.currencyCode {
            return currencyCode
        }
        
        // Fallback method if we can't get the currency code directly
        for code in Locale.isoCurrencyCodes {
            let tempLocale = Locale(identifier: "en_US_POSIX")
            if let symbol = tempLocale.localizedString(forCurrencyCode: code), symbol == currencySymbol {
                return code
            }
        }
        
        return "USD" // Default to USD if currency code can't be determined
    }

    private func _configureSubscribeButton() {
        subscribeButton.setTitle("CONTINUE", for: .normal)
        updateFreeTrialInfo()
    }

    // MARK: - Helper Methods
    private func highlightButton(at index: Int) {
        priceButtons.forEach {
            $0.backgroundColor = .systemBackground
            $0.layer.borderColor = UIColor.separator.cgColor
        }
        priceButtons[index].backgroundColor = .systemBlue.withAlphaComponent(0.1)
        priceButtons[index].layer.borderColor = UIColor.systemBlue.cgColor
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        updateFreeTrialInfo()
    }
    
    private func unhighlightButton(at index: Int) {
        priceButtons[index].backgroundColor = .systemBackground
        priceButtons[index].layer.borderColor = UIColor.separator.cgColor
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
            // UIView doesn't have a contentSize property
            // If you're using a UIScrollView, update its contentSize instead
            if let scrollView = self.view as? UIScrollView {
                scrollView.contentSize = self.view.bounds.size
            } else {
                // If view is not a UIScrollView, you might need to adjust your layout
                // or reconsider how you're handling the content size
                print("Warning: Attempting to set contentSize on a non-scrollable view")
            }
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update continue button gradient
        if let gradientLayer = subscribeButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = subscribeButton.bounds
        }
        
        // Force layout update for continue button container
        continueButtonContainer.setNeedsLayout()
        continueButtonContainer.layoutIfNeeded()
        
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

    // Add this method to update colors for dark mode
    private func updateColorsForCurrentTraitCollection() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray6 // Light gray background for dark mode
            continueButtonContainer.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8)
            // Use a black shadow for better contrast in dark mode
            continueButtonContainer.layer.shadowColor = UIColor.black.cgColor
            continueButtonContainer.layer.shadowOpacity = 0.3
            continueButtonContainer.layer.shadowRadius = 15
            cancelAnytimeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            cancelAnytimeLabel.textColor = .systemGreen
            
            // Update price button colors for dark mode
            for button in priceButtons {
                button.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8)
                button.layer.borderColor = UIColor.systemGray3.cgColor
                // Add black shadow to price buttons in dark mode
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.2
                button.layer.shadowRadius = 8
            }
        } else {
            view.backgroundColor = .white
            continueButtonContainer.backgroundColor = UIColor.white
            continueButtonContainer.layer.shadowColor = UIColor.black.cgColor
            continueButtonContainer.layer.shadowOpacity = 0.1
            continueButtonContainer.layer.shadowRadius = 10
            cancelAnytimeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            cancelAnytimeLabel.textColor = .systemGreen
            
            // Update price button colors for light mode
            for button in priceButtons {
                button.backgroundColor = .systemBackground
                button.layer.borderColor = UIColor.separator.cgColor
                // Reset shadow for price buttons in light mode
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowRadius = 6
            }
        }
        
        // Update gradient for subscribe button
        if let gradientLayer = subscribeButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.colors = traitCollection.userInterfaceStyle == .dark
                ? [UIColor.systemBlue.cgColor, UIColor(red: 0.3, green: 0.2, blue: 0.8, alpha: 1.0).cgColor]
                : [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
            gradientLayer.frame = subscribeButton.bounds
        }
        
        // Update text colors for better readability in both modes
        primaryHeaderLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        topDescriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .lightGray : .darkGray
        
        // Force layout update
        continueButtonContainer.setNeedsLayout()
        continueButtonContainer.layoutIfNeeded()
        
        // Update free trial info colors
        updateFreeTrialInfo()
    }

    private func updateFreeTrialInfo() {
        guard let uiProviderDelegate = uiProviderDelegate else { return }
        
        let trialDuration = uiProviderDelegate.freeTrialDuration(for: selectedIndex)
        let price = uiProviderDelegate.subscriptionPrice(for: selectedIndex, withDurationSuffix: false)
        
        let attributedString = NSMutableAttributedString()
        
        if !trialDuration.isEmpty {
            attributedString.append(NSAttributedString(string: "\(trialDuration) FREE TRIAL\n", attributes: [
                .font: UIFont.font(.sofiaProBlack, style: .title3),
                .foregroundColor: UIColor.systemGreen
            ]))
            attributedString.append(NSAttributedString(string: "then ", attributes: [
                .font: UIFont.font(.sofiaProRegular, style: .subheadline),
                .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
            ]))
        }
        
        attributedString.append(NSAttributedString(string: price, attributes: [
            .font: UIFont.font(.sofiaProBlack, style: .title2),
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        ]))
        attributedString.append(NSAttributedString(string: " / year", attributes: [
            .font: UIFont.font(.sofiaProRegular, style: .subheadline),
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
        ]))
        
        freeTrialInfoLabel.attributedText = attributedString
        
        // Update save info label
        let saveInfoAttributedString = NSMutableAttributedString()
        saveInfoAttributedString.append(NSAttributedString(string: "Save 75% • ", attributes: [
            .font: UIFont.font(.sofiaProBold, style: .subheadline),
            .foregroundColor: UIColor.systemGreen
        ]))
        saveInfoAttributedString.append(NSAttributedString(string: "Top Rated Plan", attributes: [
            .font: UIFont.font(.sofiaProMedium, style: .subheadline),
            .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
        ]))
        
        // Add SF Symbol
        let imageAttachment = NSTextAttachment()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        imageAttachment.image = UIImage(systemName: "star.fill", withConfiguration: config)?.withTintColor(.systemYellow)
        let imageString = NSAttributedString(attachment: imageAttachment)
        saveInfoAttributedString.append(NSAttributedString(string: " "))
        saveInfoAttributedString.append(imageString)
        
        saveInfoLabel.attributedText = saveInfoAttributedString
    }

    // Override traitCollectionDidChange to handle dark mode changes
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorsForCurrentTraitCollection()
    }
}
