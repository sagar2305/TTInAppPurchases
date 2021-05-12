//
//  UIAlertView.swift
//  CallRecorder
//
//  Created by Sandesh on 14/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import SwiftEntryKit

public struct UIAlertView {
    
    struct  Action {
        var title: String
        var onSelect: () -> Void
    }
    
    var title: String
    var description: String
    var actions: [Action]
    
    init(title: String, description: String, actions: Action...) {
        self.title = title
        self.description = description
        self.actions = actions
    }
    
    func present() {
        let alertTitleLabel = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: UIFont.font(.sofiaProSemibold, style: .title3),
                color: EKColor(.buttonTextColor),
                alignment: .center,
                displayMode: .inferred
            )
        )
        
        let alertDescriptionLabel = EKProperty.LabelContent(
            text: description,
            style: .init(
                font: UIFont.font(.sofiaProRegular, style: .callout),
                color: EKColor(.buttonTextColor),
                alignment: .center,
                displayMode: .inferred
            )
        )
        
        let simpleAlertMessage = EKSimpleMessage(
            title: alertTitleLabel,
            description: alertDescriptionLabel
        )
        
        var actionContents = [EKProperty.ButtonContent]()
        actions.forEach { action in
            let actionButtonFont = UIFont.font(.sofiaProMedium, style: .callout)
            let actionButtonLabelStyle = EKProperty.LabelStyle(
                font: actionButtonFont,
                color: EKColor(.buttonTextColor),
                alignment: .center,
                displayMode: .inferred
            )
            
            let actionButtonLabel = EKProperty.LabelContent(
                text: action.title,
                style: actionButtonLabelStyle
            )
            
            let actionButtonContent = EKProperty.ButtonContent(
                label: actionButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: EKColor(UIColor.inverseBackgroundColor.withAlphaComponent(0.04))) {
                    action.onSelect()
                    SwiftEntryKit.dismiss()
            }
            
            actionContents.append(actionButtonContent)
        }
        
        let actionButtonsBarContent = EKProperty.ButtonBarContent(
            with: actionContents,
            separatorColor: EKColor(UIColor.inverseBackgroundColor.withAlphaComponent(0.40)),
            buttonHeight: 44,
            displayMode: .inferred,
            expandAnimatedly: false
        )
        
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleAlertMessage,
            imagePosition: .top,
            buttonBarContent: actionButtonsBarContent
        )
        
        let alertMessageView = EKAlertMessageView(with: alertMessage)
        
        var attribute = EKAttributes.centerFloat
        attribute.entryInteraction = .forward
        attribute.screenInteraction = .absorbTouches
        attribute.displayDuration = .infinity
        let blackBackgrond = UIColor(red: 0.13, green: 0.13, blue: 0.18, alpha: 1.0)
        let gradient = EKAttributes.BackgroundStyle.Gradient(colors: [
            EKColor(blackBackgrond),
            EKColor(.primaryColor)
            ],
                                                             startPoint: CGPoint(x: 0, y: 0),
                                                             endPoint: CGPoint(x: 1, y: 0.5)
        )
        attribute.entryBackground = .gradient(gradient: gradient)
        attribute.screenBackground = .color(color: EKColor(UIColor.backgroundColor.withAlphaComponent(0.24)))
        SwiftEntryKit.display(entry: alertMessageView, using: attribute)
    }
}
