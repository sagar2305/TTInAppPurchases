import UIKit

public class ReviewCarouselView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var timer: Timer?
    private var currentPage = 0
    
    private var reviews: [(String, String, String)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with reviews: [(String, String, String)]) {
        self.reviews = reviews
        setupReviews()
    }
    
    private func setupViews() {
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.borderWidth = 1
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        stackView.axis = .horizontal
        stackView.spacing = 16
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        updateColorsForCurrentTraitCollection()
    }
    
    private func setupReviews() {
        // Remove existing review views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for review in reviews {
            let reviewView = createReviewView(name: review.0, rating: review.1, comment: review.2)
            stackView.addArrangedSubview(reviewView)
        }
        
        layoutIfNeeded()
        startAutoScroll()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        for view in stackView.arrangedSubviews {
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32).isActive = true
        }
        scrollView.contentSize = CGSize(width: CGFloat(reviews.count) * (bounds.width - 32) + CGFloat(reviews.count - 1) * 16, height: bounds.height)
    }
    
    private func createReviewView(name: String, rating: String, comment: String) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 12
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        
        let ratingLabel = UILabel()
        ratingLabel.text = rating
        ratingLabel.font = UIFont.font(.sofiaProBold, style: .subheadline)
        ratingLabel.textAlignment = .center
        
        let commentLabel = UILabel()
        commentLabel.text = comment
        commentLabel.font = UIFont.font(.sofiaProRegular, style: .body)
        commentLabel.numberOfLines = 3
        commentLabel.textAlignment = .center
        
        let nameLabel = UILabel()
        nameLabel.text = "- " + name
        nameLabel.font = UIFont.font(.sofiaProMedium, style: .footnote)
        nameLabel.textAlignment = .right
        
        let screenHeight = UIScreen.main.bounds.height
        let dynamicSpacing = 5

        let stackView = UIStackView(arrangedSubviews: [ratingLabel, commentLabel, nameLabel])
        stackView.axis = .vertical
        stackView.spacing = UIScreen.main.bounds.height < 700 ? 5 : 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
        
        return view
    }
    
    private func startAutoScroll() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            self?.scrollToNextPage()
        }
    }
    
    private func scrollToNextPage() {
        currentPage = (currentPage + 1) % reviews.count
        let offsetX = CGFloat(currentPage) * (bounds.width - 32) + CGFloat(currentPage) * 16
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    private func updateColorsForCurrentTraitCollection() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        backgroundColor = isDarkMode ? UIColor.systemGray5.withAlphaComponent(0.5) : .white // Changed to white for light mode
        layer.borderColor = isDarkMode ? UIColor.systemGray4.cgColor : UIColor.systemGray3.cgColor
        
        for case let reviewView as UIView in stackView.arrangedSubviews {
            if let gradientLayer = reviewView.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.colors = isDarkMode
                    ? [UIColor.systemGray6.cgColor, UIColor.systemGray5.cgColor]
                    : [UIColor.white.cgColor, UIColor.systemGray6.cgColor]
            }
            
            for case let label as UILabel in reviewView.subviews.first?.subviews ?? [] {
                if label.font == UIFont.font(.sofiaProBold, style: .subheadline) {
                    label.textColor = .systemYellow // Rating color
                } else {
                    label.textColor = isDarkMode ? .white : .black
                }
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorsForCurrentTraitCollection()
    }
}
