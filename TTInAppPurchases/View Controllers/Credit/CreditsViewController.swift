//
//  CreditsViewController.swift
//  abseil
//
//  Created by Revathi on 05/07/23.
//

import UIKit
import NVActivityIndicatorView

public protocol CreditsVCProtocol: UIViewController {
    var uiProviderDelegate: CreditsUIProviderDelegate? { get set }
    var delegate: CreditsViewControllerDelegate? { get set }
}

public protocol CreditsUIProviderDelegate: AnyObject {
    func subscriptionPrice(for index: Int, withDurationSuffix: Bool) -> String
    func subscriptionTitle(for index: Int) -> String
    func productsFetched() -> Bool
}

public protocol CreditsViewControllerDelegate: AnyObject {
    func selectPlan(at index: Int, controller: CreditsVCProtocol)
}

public class CreditsViewController: UIViewController, CreditsVCProtocol {
    
    public weak var uiProviderDelegate: CreditsUIProviderDelegate?
    public weak var delegate: CreditsViewControllerDelegate?

    @IBOutlet var priceLabels: [UILabel]!
    @IBOutlet var titleLabel: [UILabel]!
    @IBOutlet weak var firstSubscriptionLabel: UILabel!
    @IBOutlet weak var secondSubscriptionLabel: UILabel!
    @IBOutlet weak var thirdSubscriptionLabel: UILabel!
    @IBOutlet var getButtonCollection: [UIButton]!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Coins".localized
        _configureUI()
        
        if uiProviderDelegate!.productsFetched() {
            setUpCreditsButton(notification: nil)
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(setUpCreditsButton(notification:)),
                                                   name: Notification.Name.creditsFetchedNotification,
                                                   object: nil)
        }
    }
    
    private func _configureUI() {
        firstSubscriptionLabel.text = "200" + " " + "Coins".localized
        secondSubscriptionLabel.text = "500" + " " + "Coins".localized
        thirdSubscriptionLabel.text = "1000" + " " + "Coins".localized
        
        firstSubscriptionLabel.configure(with: UIFont.font(.sofiaProMedium, style: .headline))
        secondSubscriptionLabel.configure(with: UIFont.font(.sofiaProMedium, style: .headline))
        thirdSubscriptionLabel.configure(with: UIFont.font(.sofiaProMedium, style: .headline))
        for label in priceLabels {
            label.configure(with: UIFont.font(.sofiaProMedium, style: .body))
        }
        
        for button in getButtonCollection {
            button.setTitle("Get".localized, for: .normal)
            button.titleLabel?.configure(with: UIFont.font(.sofiaProMedium, style: .title3))
            button.layer.cornerRadius = button.bounds.height/2
            button.clipsToBounds = true
        }
    }
    
    @objc func setUpCreditsButton(notification: Notification?) {
        NVActivityIndicatorView.stop()
        for label in priceLabels {
            label.text = uiProviderDelegate?.subscriptionPrice(for: label.tag, withDurationSuffix: true)
        }
    }
    
    @IBAction func didTapGetCredits(_ sender: UIButton) {
        let tag = sender.tag
        delegate?.selectPlan(at: tag, controller: self)
    }
}
