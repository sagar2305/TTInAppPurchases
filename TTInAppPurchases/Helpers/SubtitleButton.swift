//
//  SubtitleButton.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 7/29/24.
//  Copyright © 2024 Smart Apps. All rights reserved.
//

import UIKit

class SubtitleButton: UIButton {
    
    // Public label for subtitle, now named subtitleText
    public let subtitleText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Configure the subtitleText label
        subtitleText.font = UIFont.systemFont(ofSize: 12)
        subtitleText.textColor = .white
        subtitleText.textAlignment = .center
        subtitleText.text = ""

        // Add the label to the button
        addSubview(subtitleText)

        // Setup constraints for subtitleText
        subtitleText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleText.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: 2),
            subtitleText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subtitleText.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            subtitleText.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -2)
        ])
    }

    // Public method to set the subtitle text
    public func setSubtitle(_ subtitle: String) {
        subtitleText.text = subtitle
    }
}
