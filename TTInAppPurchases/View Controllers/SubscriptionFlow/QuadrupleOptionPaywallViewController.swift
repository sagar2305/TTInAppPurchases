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
        stackView.spacing = calculateSpacing()
        return stackView
    }()
    
    private lazy var freeTrialInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProMedium, style: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.font(.sofiaProMedium, style: .callout)
        button.setTitle("CONTINUE".localized, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapSubscribeNowButton), for: .touchUpInside)
        
        // Add a gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = button.bounds
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        return button
    }()
    
    private lazy var mostPopularLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.font(.sofiaProBold, style: .caption1)
        label.text = "Most Popular"
        label.textColor = .white
        label.backgroundColor = .systemGreen
        label.textAlignment = .center
        label.layer.cornerRadius = 8
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
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        [cancelButton, primaryHeaderLabel, topDescriptionLabel, reviewCarouselView, featureStackView,
         freeTrialInfoLabel, subscribeButton, mostPopularLabel, saveInfoLabel, subscriptionStackView,
         cancelAnytimeLabel, restorePurchasesButton, privacyAndTermsOfLawLabel].forEach { view.addSubview($0) }
        
        subscriptionStackView.isUserInteractionEnabled = true
        
        for _ in 0..<3 {
            let button = createPriceButton()
            priceButtons.append(button)
            subscriptionStackView.addArrangedSubview(button)
            
            let tickMark = createTickMarkView()
            tickMarkViews.append(tickMark)
            button.addSubview(tickMark)
        }
    }
    
    private func calculateSpacing() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
        case 926: // iPhone 6.7" (iPhone 13/14 Pro Max, etc.)
            return 16
        case 844: // iPhone 6.1" (iPhone 13/14/12, etc.)
            return 14
        case 812: // iPhone 5.8" (iPhone X, XS, 13 Mini, etc.)
            return 12
        case 736: // iPhone 5.5" (iPhone 8 Plus, etc.)
            return 10
        case 667: // iPhone 4.7" (iPhone SE 2nd gen, iPhone 8, etc.)
            return 8
        default:
            return 8 // Default spacing for other sizes
        }
    }
    
    private func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            primaryHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: calculateSpacing()*1.5),
            primaryHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            primaryHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            topDescriptionLabel.topAnchor.constraint(equalTo: primaryHeaderLabel.bottomAnchor, constant: calculateSpacing() * 1.5),
            topDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            reviewCarouselView.topAnchor.constraint(equalTo: topDescriptionLabel.bottomAnchor, constant: 16),
            reviewCarouselView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            reviewCarouselView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            reviewCarouselView.heightAnchor.constraint(equalToConstant: getScreenHeight() * 0.14),
            
            featureStackView.topAnchor.constraint(equalTo: reviewCarouselView.bottomAnchor, constant: calculateSpacing() * 1.5),
            featureStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            featureStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            freeTrialInfoLabel.topAnchor.constraint(equalTo: featureStackView.bottomAnchor, constant: 0),
            freeTrialInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            freeTrialInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            subscribeButton.topAnchor.constraint(equalTo: freeTrialInfoLabel.bottomAnchor, constant: 8),
            subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            subscribeButton.heightAnchor.constraint(equalToConstant: 44),

            mostPopularLabel.topAnchor.constraint(equalTo: subscribeButton.topAnchor, constant: -8),
            mostPopularLabel.trailingAnchor.constraint(equalTo: subscribeButton.trailingAnchor, constant: -8),
            mostPopularLabel.widthAnchor.constraint(equalToConstant: 80),
            mostPopularLabel.heightAnchor.constraint(equalToConstant: 16),

            saveInfoLabel.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 8),
            saveInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            subscriptionStackView.topAnchor.constraint(equalTo: saveInfoLabel.bottomAnchor, constant: calculateSpacing() * 1.5),
            subscriptionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscriptionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cancelAnytimeLabel.topAnchor.constraint(equalTo: subscriptionStackView.bottomAnchor, constant: 5),
            cancelAnytimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelAnytimeLabel.heightAnchor.constraint(equalToConstant: 30),
            cancelAnytimeLabel.widthAnchor.constraint(equalToConstant: 160),
            
            restorePurchasesButton.topAnchor.constraint(equalTo: cancelAnytimeLabel.bottomAnchor, constant: 8),
            restorePurchasesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            privacyAndTermsOfLawLabel.topAnchor.constraint(equalTo: restorePurchasesButton.bottomAnchor, constant: 8),
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
        button.layer.cornerRadius = 12 // Increased corner radius
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        
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
        
        // If a monthly price is provided, calculate and display the yearly equivalent
        if let pricePerMonth = pricePerMonth {
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

    private func configureWeeklyButton(leftStackView: UIStackView, rightStackView: UIStackView, price: String, pricePerMonth: Double?) {
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
        
        if let pricePerMonth = pricePerMonth {
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
            cancelAnytimeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            cancelAnytimeLabel.textColor = .systemGreen
        } else {
            cancelAnytimeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            cancelAnytimeLabel.textColor = .systemGreen
        }
    }

    // Override traitCollectionDidChange to handle dark mode changes
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorsForCurrentTraitCollection()
    }

    // Update the updateFreeTrialInfo() method
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
                .foregroundColor: UIColor.secondaryLabel
            ]))
        }
        
        attributedString.append(NSAttributedString(string: price, attributes: [
            .font: UIFont.font(.sofiaProBlack, style: .title2),
            .foregroundColor: UIColor.label
        ]))
        attributedString.append(NSAttributedString(string: " / year", attributes: [
            .font: UIFont.font(.sofiaProRegular, style: .subheadline),
            .foregroundColor: UIColor.secondaryLabel
        ]))
        
        freeTrialInfoLabel.attributedText = attributedString
        
        // Remove the background color and shadow
        freeTrialInfoLabel.backgroundColor = .clear
        freeTrialInfoLabel.layer.shadowColor = nil
        freeTrialInfoLabel.layer.shadowOffset = .zero
        freeTrialInfoLabel.layer.shadowRadius = 0
        freeTrialInfoLabel.layer.shadowOpacity = 0
        freeTrialInfoLabel.layer.masksToBounds = true
    }
}
