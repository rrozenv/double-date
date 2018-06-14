//
//  BindableType.swift
//  HousePartyApp
//
//  Created by Robert Rozenvasser on 6/13/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

protocol BindableType {
    associatedtype ViewModel
    var viewModel: ViewModel! { get set }
    func bindViewModel()
}

extension BindableType where Self: UIViewController {
    mutating func setViewModelBinding(model: Self.ViewModel) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
