//
//  SubtitleButton.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 7/29/24.
//  Copyright © 2024 Smart Apps. All rights reserved.
//

import UIKit

class SubtitleButton: UIButton {
    
    public let subtitleText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(subtitleText)
        setupConstraints()
    }

    private func setupConstraints() {
        subtitleText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleText.topAnchor.constraint(equalTo: titleLabel?.bottomAnchor ?? topAnchor, constant: 2),
            subtitleText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            subtitleText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            subtitleText.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -2)
        ])
    }

    // Public method to set the subtitle text
    public func setSubtitle(_ subtitle: String) {
        subtitleText.text = subtitle
    }
}
