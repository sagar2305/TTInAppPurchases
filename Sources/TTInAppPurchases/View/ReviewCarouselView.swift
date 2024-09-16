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
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        stackView.axis = .horizontal
        stackView.spacing = 0
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        for review in reviews {
            let reviewView = createReviewView(name: review.0, rating: review.1, comment: review.2)
            stackView.addArrangedSubview(reviewView)
        }
        
        startAutoScroll()
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
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
        scrollView.contentSize = CGSize(width: CGFloat(reviews.count) * bounds.width, height: bounds.height)
    }
    
    private func createReviewView(name: String, rating: String, comment: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        
        let ratingLabel = UILabel()
        ratingLabel.text = rating
        ratingLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: UIFont(name: "SofiaPro-Regular", size: calculateFontSize()) ?? UIFont.systemFont(ofSize: calculateFontSize()))
        ratingLabel.textAlignment = .center
        
        let commentLabel = UILabel()
        commentLabel.text = comment
        commentLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: UIFont(name: "SofiaPro-Regular", size: calculateFontSize()) ?? UIFont.systemFont(ofSize: calculateFontSize()))
        commentLabel.adjustsFontForContentSizeCategory = true
        commentLabel.numberOfLines = 2
        commentLabel.textAlignment = .center
        
        let nameLabel = UILabel()
        nameLabel.text = "- " + name
        nameLabel.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont(name: "SofiaPro-Medium", size: calculateFontSize()) ?? UIFont.systemFont(ofSize: calculateFontSize()))
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [ratingLabel, commentLabel, nameLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
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
        let offsetX = CGFloat(currentPage) * bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    private func calculateFontSize() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
        case 926: // iPhone 6.7" (iPhone 13/14 Pro Max, etc.)
            return 22
        case 844: // iPhone 6.1" (iPhone 13/14/12, etc.)
            return 20
        case 812: // iPhone 5.8" (iPhone X, XS, 13 Mini, etc.)
            return 18
        case 736: // iPhone 5.5" (iPhone 8 Plus, etc.)
            return 17
        case 667: // iPhone 4.7" (iPhone SE 2nd gen, iPhone 8, etc.)
            return 16
        default:
            return 16 // Default font size for other sizes
        }
    }

}
