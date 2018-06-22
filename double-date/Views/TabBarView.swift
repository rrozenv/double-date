//
//  TabBarView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class TabBarView: UIView, TabBarViewable {
    
    var buttons: [UIButton] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupButtons()
    }
    
    private func setupButtons() {
        let props = StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0)
        let stackView = CustomStackView<UIButton>(number: 3, stackViewProps: props)
        self.buttons = stackView.views
        self.buttons.enumerated().forEach {
            $0.element.tag = $0.offset
        }
        self.buttons[0].backgroundColor = .red
        self.buttons[1].backgroundColor = .yellow
        self.buttons[2].backgroundColor = .blue
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(60)
        }
    }
    
}
