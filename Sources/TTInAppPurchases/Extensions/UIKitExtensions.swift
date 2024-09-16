//
//  UIColorExtensions.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 5/19/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

public extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

public extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public extension UIColor {
    
    class func bundle() -> Bundle {
        let bundle = Bundle(for: SubscriptionHelper.self)
        return bundle
    }
    
    class var backgroundColor: UIColor {
        return UIColor(named: "backgroundColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var inverseBackgroundColor: UIColor {
        return UIColor(named: "inverseBackgroundColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var primaryColor: UIColor {
        return UIColor(named: "primaryColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var secondaryColor: UIColor {
        return UIColor(named: "secondaryColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var primaryTextColor: UIColor {
        return UIColor(named: "primaryTextColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var secondaryTextColor: UIColor {
        return UIColor(named: "secondaryTextColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var navigationTitleTextColor: UIColor {
        return UIColor(named: "navigationTitleTextColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var buttonTextColor: UIColor {
        return UIColor(named: "buttonTextColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var creditMainBackgroundColor: UIColor {
        return UIColor(named: "creditMainBackgroundColor", in: bundle(), compatibleWith: nil)!
    }
    
    class var creditSecondaryBackgroundColor: UIColor {
        return UIColor(named: "creditSecondaryBackgroundColor", in: bundle(), compatibleWith: nil)!
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage) ) ?? self
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) ) ?? self
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

public extension UIImage {
    class func bundle() -> Bundle {
        let bundle = Bundle(for: SubscriptionHelper.self)
        return bundle
    }
    
    class var blueTickImage: UIImage {
        return UIImage(named: "ic_blueTick", in: bundle(), compatibleWith: nil)!
    }
    
    class var creditImage: UIImage {
        return UIImage(named: "ic_credit", in: bundle(), compatibleWith: nil)!
    }
}

public extension UIView {
    func shake(duration: CFTimeInterval) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let shakeValues = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        translation.timingFunction = CAMediaTimingFunction(name: .linear)
        translation.values = shakeValues
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = shakeValues.map { (Int(Double.pi) * $0) / 180 }
        
        let shakeGroup = CAAnimationGroup()
        shakeGroup.animations = [translation, rotation]
        shakeGroup.duration = duration
        layer.add(shakeGroup, forKey: "shakeIt")
    }
    
    func addLinearGradient(_ colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        layer.addSublayer(gradient)
    }
    
    func getMyFrame(in view: UIView) -> CGRect {
        return self.convert(self.bounds, to: view)
    }
}

public extension UILabel {
    static func titleLabel(title: String?) -> UILabel {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        titleLabel.text = title ?? ""
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.font(.sofiaProMedium, style: .title3)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = .navigationTitleTextColor
        titleLabel.sizeToFit()
        return titleLabel
    }
    
    func configure(with font: UIFont) {
        self.font = font
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
    }
    
    func getPointer(center: CGPoint, onBottom edge: Bool) -> UIView {
        let path = UIBezierPath()
        let pointerView = UIView(frame: .zero)
        pointerView.backgroundColor = self.backgroundColor
        
        if edge {
            pointerView.frame = CGRect(x: center.x - 6,
                                           y: self.frame.maxY - 2,
                                           width: 12,
                                           height: 12)
                        
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 12, y: 0))
            path.addLine(to: CGPoint(x: 6, y: 12))
            path.close()
        } else {
            pointerView.frame = CGRect(x: center.x - 6,
                                           y: self.frame.minY - 10,
                                           width: 12,
                                           height: 12)
                        
            path.move(to: CGPoint(x: 0, y: 12))
            path.addLine(to: CGPoint(x: 12, y: 12))
            path.addLine(to: CGPoint(x: 6, y: 0))
            path.close()
        }
        
        let hintBannerPointerLayer = CAShapeLayer()
        hintBannerPointerLayer.path = path.cgPath
        hintBannerPointerLayer.fillColor = UIColor.green.cgColor
        pointerView.layer.mask = hintBannerPointerLayer
        return pointerView
    }
    
    func setItalicText() {
        font = UIFont.italicSystemFont(ofSize: font.pointSize)
    }
}

public extension UIViewController {

    convenience init(fromSPMWithXib: Bool) {
        // Ensure that this is only for view controllers in a Swift package using XIBs
        guard fromSPMWithXib else {
            fatalError("This initializer is meant for view controllers in Swift packages with XIBs")
        }

        // Use the Swift Package Manager's module bundle
        let bundle = Bundle.module

        // Dynamically get the XIB name as the class name
        let nibName = String(describing: Self.self)

        // Initialize the view controller with the XIB name and the SPM bundle
        self.init(nibName: nibName, bundle: bundle)
    }
    
    func configureUI(title: String) {
        let titleView = UILabel.titleLabel(title: title.localized)
        titleView.tintColor = .navigationTitleTextColor
        navigationItem.titleView = titleView
    }
    
    func addChildViewController(_ viewController: UIViewController) {
        addChild(viewController)
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

public extension UIFont {
    
    static func sizeFor(_ style: UIFont.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle:   return CGFloat(40)
        case .title1:       return CGFloat(32)
        case .title2:       return CGFloat(26)
        case .title3:       return CGFloat(22)
        case .headline:      return CGFloat(17)
        case .body:         return CGFloat(17)
        case .callout:      return CGFloat(16)
        case .subheadline:  return CGFloat(15)
        case .footnote:     return CGFloat(13)
        case .caption1:     return CGFloat(12)
        case .caption2:     return CGFloat(11)
        default: return CGFloat(17)
        }
    }
    
    static func font(_ name: Constants.Fonts, style: UIFont.TextStyle) -> UIFont {
        let fontSize = UIFont.sizeFor(style)
        let font = UIFont(name: name.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}

public extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(
                            for: locationOfTouchInTextContainer,
                            in: textContainer,
                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
