//
//  CurrencyTextField.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/23/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class CurrencyTextField: UITextField, UITextFieldDelegate {
    
    var amount = Variable(0)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        delegate = self
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            amount.value = amount.value * 10 + digit
        }
        if string == "" { amount.value = amount.value/10 }
        self.text = updatedAmount()
        return false
    }
    
    private func updatedAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let newAmount = Double(amount.value/100) + Double(amount.value%100)/100
        return formatter.string(from: NSNumber(value: newAmount))
    }
    
}
