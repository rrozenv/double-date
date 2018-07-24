//
//  StyledTextField.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum TextFieldStyle {
    case background
    case underline
}

enum TextFieldInputType {
    case regularText
    case phoneNumber
    case currency
}

final class StyledTextField: UIView {
    
    //MARK: - Private Views
    private var textField: PaddedTextField!
    private var underlineView: UIView!
    
    //MARK: - Public Views
    var clearButton: UIButton!
    var countryCodeButton: ButtonLabel?
    
    //MARK: Text Output Binding
    var textOutput: Observable<String> {
        switch inputType {
        case .regularText: return textField.rx.text.orEmpty.asObservable()
        case .phoneNumber: return textField.rx.text.orEmpty.asObservable().map { $0.digits }
        case .currency: return currencyAmount.asObservable().map { String($0) }
        }
    }
    
    var enterLowerCurrencyAmt: Observable<Int> {
        return _enterLowerCurrencyAmt.asObservable()
    }
    
    //MARK: - Private Vars
    private var currencyAmount = Variable(0)
    private let _enterLowerCurrencyAmt = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    
    //MARK: Initalizer Setup
    private let style: TextFieldStyle
    private let inputType: TextFieldInputType
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(style: TextFieldStyle, inputType: TextFieldInputType, alignment: NSTextAlignment, padding: CGFloat) {
        self.style = style
        self.inputType = inputType
        super.init(frame: .zero)
        
        setupTextfield(padding: padding, alignment: alignment)
        setupUnderlineView()
        setupStackView()
        setupClearButton()
        
        if inputType == .phoneNumber {
            setupCountryCodeButton()
            textField.rx.text.orEmpty.asObservable().map { $0.phoneRepresentable() ?? $0 }
                .bind(to: textField.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
    deinit {
        print("StyledTextField deinit")
    }

}

//MARK: - Public Methods
extension StyledTextField {
    
    func showKeyboard() {
        textField.becomeFirstResponder()
    }
    
    func clearText() {
        textField.text = nil
    }
    
    func styleTextField(placeHolder: String, font: UIFont, backColor: UIColor, titleColor: UIColor, keyboardType: UIKeyboardType) {
        textField.style(placeHolder: placeHolder,
                        font: font,
                        backColor: backColor,
                        titleColor: titleColor)
        textField.keyboardType = keyboardType
    }
    
}

//MARK: - TextFieldDelegate
extension StyledTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard inputType == .currency else { return true }
        if let digit = Int(string) {
            let inputAmount = currencyAmount.value * 10 + digit
            if inputAmount > 1_000_000_000_000 {
                currencyAmount.value = 0
                _enterLowerCurrencyAmt.onNext(1_000_000_000_000)
            } else {
               currencyAmount.value = inputAmount
            }
        }
        if string == "" { currencyAmount.value = currencyAmount.value/10 }
        self.textField.text = currencyAmount.value == 0 ? "" : updatedAmount()
        return false
    }
    
    private func updatedAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let newAmount = Double(currencyAmount.value/100) + Double(currencyAmount.value%100)/100
        return formatter.string(from: NSNumber(value: newAmount))
    }
    
}

//MARK: - View Setup
extension StyledTextField {
    
    private func setupTextfield(padding: CGFloat, alignment: NSTextAlignment) {
        textField = PaddedTextField(padding: padding)
        textField.textAlignment = alignment
        textField.delegate = self
        textField.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    private func setupUnderlineView() {
        underlineView = UIView()
        underlineView.backgroundColor = Palette.faintGrey.color
        underlineView.snp.makeConstraints { $0.height.equalTo(3) }
        underlineView.isHidden = self.style == .background
    }
    
    private func setupClearButton() {
        clearButton = UIButton()
        clearButton.setImage(#imageLiteral(resourceName: "IC_ClearSearch"), for: .normal)
        clearButton.isHidden = true
        clearButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.textField.text = nil
                self.clearButton.isHidden = true
                self.currencyAmount.value = 0
            })
            .disposed(by: disposeBag)
        textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.clearButton.isHidden = $0 == "" || $0.isEmpty
            })
            .disposed(by: disposeBag)
        
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
