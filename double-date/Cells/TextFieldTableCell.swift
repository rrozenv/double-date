//
//  TextFieldTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/20/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class TextFieldTableCell: UITableViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    static let defaultReusableId: String = "TextFieldTableCell"
    private var mainLabel: UILabel!
    var textField: UITextField!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        setupMainLabel()
        setupTextField()
        setupContainerStackView()
    }
    
    // MARK: - Configuration
    func configureWith(value: TextFieldTableCellProps) {
        mainLabel.text = value.title
        textField.placeholder = value.placeHolderText
        textField.keyboardType = value.keyBoardType
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension TextFieldTableCell {
    
    //MARK: View Setup

    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 14), color: .black, alignment: .left)
    }
    
    private func setupTextField() {
        textField = UITextField()
    }
    
    private func setupContainerStackView() {
        let stackView = UIStackView(arrangedSubviews: [mainLabel, textField])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
//        stackView.spacing = 30.0
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(30)
        }
    }
    
}

final class TextFieldFormView: UIView {
    
    // MARK: - Properties
    let inputType: TextFieldInputType
    var disposeBag = DisposeBag()
    private var mainLabel: UILabel!
    var textField: StyledTextField!
    var dividerView: UIView!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(inputType: TextFieldInputType) {
        self.inputType = inputType
        super.init(frame: .zero)
        setupMainLabel()
        setupTextField()
        setupContainerStackView()
        setupDividerView()
    }
    
    // MARK: - Configuration
    func configureWith(value: TextFieldTableCellProps) {
        mainLabel.text = value.title
        textField.styleTextField(placeHolder: value.placeHolderText,
                                 font: FontBook.AvenirMedium.of(size: 14),
                                 backColor: .white,
                                 titleColor: .black,
                                 keyboardType: value.keyBoardType)
    }
    
}

extension TextFieldFormView {
    
    //MARK: View Setup
    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.aqua.color, alignment: .left)
    }
    
    private func setupTextField() {
        textField = StyledTextField(style: .background,
                                    inputType: inputType,
                                    alignment: .left,
                                    padding: 0)
        textField.styleTextField(placeHolder: "", font: FontBook.AvenirMedium.of(size: 14), backColor: .white, titleColor: .black, keyboardType: inputType == .phoneNumber || inputType == .currency ? .numberPad : .default)
        textField.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    private func setupContainerStackView() {
        let stackView = UIStackView(arrangedSubviews: [mainLabel, textField])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0.5
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-2)
            make.left.right.equalTo(self)
        }
    }
    
    private func setupDividerView() {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        self.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(2)
        }
    }
    
}

final class DatePickerFormView: UIView {
    
    // MARK: - Properties
    var mainLabel: UILabel!
    var displayedDateButton: UIButton!
    var dividerView: UIView!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupMainLabel()
        setupDisplayedDateButton()
        setupContainerStackView()
        setupDividerView()
    }
    
    // MARK: - Configuration
    func configureWith(value: DatePickerTableCellProps) {
        mainLabel.text = value.title
    }
    
}

extension DatePickerFormView {
    
    //MARK: View Setup
    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.aqua.color, alignment: .left)
    }
    
    private func setupDisplayedDateButton() {
        displayedDateButton = UIButton().rxStyle(title: "\(Date())",
            font: FontBook.AvenirMedium.of(size: 14),
            backColor: .clear, titleColor: .black)
        displayedDateButton.contentHorizontalAlignment = .left
        displayedDateButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    private func setupContainerStackView() {
        let labelButtonSv = UIStackView(arrangedSubviews: [mainLabel, displayedDateButton])
        labelButtonSv.axis = .vertical
        labelButtonSv.distribution = .equalSpacing
        labelButtonSv.spacing = 0.5
        
        self.addSubview(labelButtonSv)
        labelButtonSv.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-2)
            make.left.right.equalTo(self)
        }
    }
    
    private func setupDividerView() {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        self.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(2)
        }
    }
    
}

