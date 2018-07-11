//
//  TitleTextFieldView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/9/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class TitleTextFieldView: UIView {
    
    // MARK: - Properties
    var mainLabel: UILabel!
    var textField: UITextField!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupMainLabel()
        setupTextField()
        setupContainerStackView()
    }
    
    // MARK: - Configuration
    func configureWith(mainLabelText: String, placeHolderText: String) {
        mainLabel.text = mainLabelText
        textField.placeholder = placeHolderText
        textField.keyboardType = .default
    }
    
}

extension TitleTextFieldView {
    
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
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(30)
        }
    }
    
}
