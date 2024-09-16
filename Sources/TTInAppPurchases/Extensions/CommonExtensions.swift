//
//  CommonExtensions.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 5/10/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import NVActivityIndicatorView
import PhoneNumberKit

public extension CALayer {
    func applySketchShadow(color: UIColor, alpha: Float, position: CGPoint, blur: CGFloat, spread: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: position.x, height: position.y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let inset = -spread
            let rect = bounds.insetBy(dx: inset, dy: inset)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

public extension NVActivityIndicatorView {
    static func start() {
        let activityData = ActivityData(type: .ballScaleMultiple)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    static func stop() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    static func startRecording() {
        let activityData = ActivityData(type: .ballPulse)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
}

public extension URL {
    func byAppending(item: URLQueryItem) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(item)
        urlComponents.queryItems = queryItems
        return urlComponents.url ?? self
    }
}

public extension PhoneNumber {
    var e164String: String {
        return PhoneNumberHelper.shared.e164Format(from: self)
    }
    
    var formattedInternationalString: String {
        return PhoneNumberHelper.shared.internationalFormat(from: self)
    }
}

public extension PhoneNumberTextField {
    var validPhoneNumber: PhoneNumber? {
        guard isValidNumber else {
            return nil
        }
        
        let rawNumber = text ?? String()
        do {
            let phoneNumber = try phoneNumberKit.parse(rawNumber, withRegion: currentRegion)
            return phoneNumber
        } catch {
            return nil
        }
    }
}

public extension UITextField {
    var isEmpty: Bool {
        if let text = text, !text.isEmpty {
             return false
        }
        return true
    }
}
