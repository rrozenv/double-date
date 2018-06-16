//
//  ButtonLabel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class ButtonLabel: UIButton {
    
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.setupLabel()
    }
    
    private func setupLabel() {
        label = UILabel()
        self.addSubview(label)
        label.snp.makeConstraints { (make) in make.edges.equalTo(self) }
    }
    
}
