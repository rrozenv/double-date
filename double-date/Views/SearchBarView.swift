//
//  SearchBarView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class SearchBarView: UIView {
    
    var searchTextField: PaddedTextField!
    var searchIconImageView: UIImageView!
    //var clearButton: UIButton!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupSearchTextfield()
        setupSearchIcon()
        //setupClearSearchButton()
    }
    
    func style(placeHolder: String, backColor: UIColor, searchIcon: UIImage, clearIcon: UIImage) {
        searchTextField.placeholder = placeHolder
        searchTextField.backgroundColor = backColor
        searchIconImageView.image = searchIcon
        //clearButton.setImage(clearIcon, for: .normal)
    }
    
}

extension SearchBarView {
    
    private func setupSearchTextfield() {
        searchTextField = PaddedTextField(padding: 40)
        searchTextField.layer.cornerRadius = 2.0
        searchTextField.layer.masksToBounds = true
        searchTextField.font = FontBook.AvenirMedium.of(size: 14)
        searchTextField.textColor = UIColor.black
        
        self.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupSearchIcon() {
        searchIconImageView = UIImageView()
        
        self.addSubview(searchIconImageView)
        searchIconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(searchTextField).offset(16)
            make.width.height.equalTo(14)
            make.centerY.equalTo(searchTextField).offset(-1)
        }
    }
    
//    private func setupClearSearchButton() {
//        clearButton = UIButton()
//
//        self.addSubview(clearButton)
//        clearButton.snp.makeConstraints { (make) in
//            make.right.equalTo(searchTextField).offset(-10)
//            make.width.height.equalTo(20)
//            make.centerY.equalTo(searchTextField)
//        }
//    }
    
}
