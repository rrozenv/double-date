//
//  CustomStackView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

struct StackViewProps {
    let axis: UILayoutConstraintAxis
    let distribution: UIStackViewDistribution
    let spacing: CGFloat
}

final class CustomStackView<View: UIView>: UIView {
    
    var views: [View] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(number: Int, stackViewProps: StackViewProps) {
        super.init(frame: .zero)
        setupStackView(number: number, props: stackViewProps)
    }
    
    func item(at index: Int) -> View {
        guard index <= views.count - 1 else { fatalError() }
        return views[index]
    }
    
    func setBackgroundColor(at index: Int, color: UIColor, isUnique: Bool) {
        if isUnique {
            views.forEach {
                $0.backgroundColor = $0.tag == index ?
                    color : .white
            }
        } else {
            item(at: index).backgroundColor = color
        }
    }
    
    private func setupStackView(number: Int, props: StackViewProps) {
        for i in 0..<number {
            let view = View()
            view.tag = i
            self.views.append(view)
        }
        
        let stackView = UIStackView(arrangedSubviews: self.views)
        stackView.axis = props.axis
        stackView.spacing = props.spacing
        stackView.distribution = props.distribution
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}
