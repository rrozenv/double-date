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
    
    init(bttnCount: Int = 3) {
        super.init(frame: .zero)
        setupButtonsWith(count: bttnCount)
    }
    
    private func setupButtonsWith(count: Int) {
        let props = StackViewProps(axis: .horizontal, distribution: .fillEqually, spacing: 0)
        let stackView = CustomStackView<UIButton>(number: 3, stackViewProps: props)
        self.buttons = stackView.views
        self.buttons.enumerated().forEach {
            $0.element.tag = $0.offset
        }
        
        for i in 0..<count {
            self.buttons[i].backgroundColor = .random
        }
      
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(60)
        }
    }
    
}

extension UIColor{
    static var random: UIColor {
        return UIColor(hue: CGFloat(arc4random_uniform(.max))/CGFloat(UInt32.max),
                       saturation: 1,
                       brightness: 1,
                       alpha: 1)
    }
}
