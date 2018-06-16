//
//  StyledTextField.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class StyledTextField: UIView {
    
    enum Style {
        case background
        case underline
    }
    
    enum InputType {
        case regularText
        case phoneNumber
    }
    
    var textField: PaddedTextField!
    var underlineView: UIView!
    var clearButton: UIButton!
    var countryCodeButton: ButtonLabel?
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(style: Style, inputType: InputType, alignment: NSTextAlignment, padding: CGFloat) {
        super.init(frame: .zero)
        setupSearchTextfield(padding: padding, alignment: alignment)
        setupUnderlineView()
        setupStackView()
        setupClearButton()
        switch style {
        case .background: underlineView.isHidden = true
        default: break
        }
        switch inputType {
        case .phoneNumber: setupCountryCodeButton()
        default: break
        }
    }
    
}

extension StyledTextField {
    
    private func setupSearchTextfield(padding: CGFloat, alignment: NSTextAlignment) {
        textField = PaddedTextField(padding: padding)
        textField.textAlignment = alignment
        textField.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    private func setupUnderlineView() {
        underlineView = UIView()
        underlineView.backgroundColor = Palette.faintGrey.color
        underlineView.snp.makeConstraints { $0.height.equalTo(3) }
    }
    
    private func setupClearButton() {
        clearButton = UIButton()
        //clearButton.setImage(#imageLiteral(resourceName: "IC_ClearSearch"), for: .normal)
        
        self.addSubview(clearButton)
        clearButton.snp.makeConstraints { (make) in
            make.right.equalTo(textField).offset(-10)
            make.width.height.equalTo(20)
            make.centerY.equalTo(textField)
        }
    }
    
    private func setupCountryCodeButton() {
        textField.padding.left = 30.0
        countryCodeButton = ButtonLabel()
        
        self.addSubview(countryCodeButton!)
        countryCodeButton!.snp.makeConstraints { (make) in
            make.left.equalTo(textField)
            make.centerY.equalTo(textField)
        }
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [textField, underlineView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}
