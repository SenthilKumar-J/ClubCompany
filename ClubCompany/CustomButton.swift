//
//  CustomButton.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.cornerRadius = 5
        layer.borderWidth = 1.0
        setTitleColor(.lightGray, for: .highlighted)
    }
    
    func setShadow() {
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.5
    }
}
