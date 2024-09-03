import UIKit

class ReviewCarouselView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var timer: Timer?
    private var currentPage = 0
    
    private let reviews = [
        ("John D.", "⭐️⭐️⭐️⭐️⭐️", "This app is a game-changer!"),
        ("Sarah M.", "⭐️⭐️⭐️⭐️⭐️", "Absolutely love the features!"),
        ("Mike R.", "⭐️⭐️⭐️⭐️⭐️", "Best app for call recording!")
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func layoutSubviews() {
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
        ratingLabel.textAlignment = .center
        
        let commentLabel = UILabel()
        commentLabel.text = comment
        commentLabel.font = UIFont.font(.sofiaProRegular, style: .body)
        commentLabel.numberOfLines = 0
        commentLabel.textAlignment = .center
        
        let nameLabel = UILabel()
        nameLabel.text = "- " + name
        nameLabel.font = UIFont.font(.sofiaProMedium, style: .subheadline)
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
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.scrollToNextPage()
        }
    }
    
    private func scrollToNextPage() {
        currentPage = (currentPage + 1) % reviews.count
        let offsetX = CGFloat(currentPage) * bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}