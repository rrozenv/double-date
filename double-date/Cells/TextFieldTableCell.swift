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
    func configureWith(value: String) {
        mainLabel.text = value
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
