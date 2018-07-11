//
//  TabBarView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

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
        let stackView = CustomStackView<UIButton>(number: count, stackViewProps: props)
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

enum TabOptionType {
    case solid
    case underline(UIColor)
}

struct TabAppearence {
    let type: TabOptionType
    let itemTitles: [String]
    let height: CGFloat
    let selectedBkgColor: UIColor
    let selectedTitleColor: UIColor
    let notSelectedBkgColor: UIColor
    let notSelectedTitleColor: UIColor
}

final class TabOptionsView: UIView, TabBarViewable {
    
    var buttons = [UIButton]()
    private var stackView: UIStackView!
    private var slidingView: UIView!
    private var appearence: TabAppearence
    private var centerYSlidingViewConstraint: Constraint!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(appearence: TabAppearence) {
        self.appearence = appearence
        super.init(frame: .zero)
        setupStackView()
        switch appearence.type {
        case .underline(let color): setupSlidingView(color: color)
        default: break
        }
    }
    
    func adjustButtonStyle(selected tag: Int) {
        buttons.forEach {
            $0.backgroundColor =
                ($0.tag == tag) ? appearence.selectedBkgColor : appearence.notSelectedBkgColor
            $0.setTitleColor(($0.tag == tag) ? appearence.selectedTitleColor : appearence.notSelectedTitleColor, for: .normal)
            switch appearence.type {
            case .underline(_):
                centerYSlidingViewConstraint.update(offset: button(at: tag).frame.origin.x)
                UIView.animate(withDuration: 0.5, animations: {
                    self.layoutIfNeeded()
                })
            default: break
            }
        }
    }
    
}

extension TabOptionsView {
    
    func button(at index: Int) -> UIButton {
        guard index < buttons.count else { fatalError() }
        return buttons[index]
    }
    
    private func setupStackView() {
        guard appearence.itemTitles.count > 0 else { return }
        appearence.itemTitles.enumerated().forEach { offset, title in
            let button = UIButton()
            button.tag = offset
            button.setTitle(appearence.itemTitles[offset], for: .normal)
            button.snp.makeConstraints { $0.height.equalTo(appearence.height) }
            buttons.append(applyAppearenceTo(button: button))
        }
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupSlidingView(color: UIColor) {
        slidingView = UIView()
        slidingView.backgroundColor = color
        
        self.addSubview(slidingView)
        slidingView.snp.makeConstraints { (make) in
            centerYSlidingViewConstraint = make.left.equalTo(button(at: 0)).constraint
            make.width.equalTo(button(at: 0))
            make.height.equalTo(4)
            make.bottom.equalTo(stackView)
        }
    }
    
    private func applyAppearenceTo(button: UIButton) -> UIButton {
        button.backgroundColor = appearence.notSelectedBkgColor
        button.setTitleColor(appearence.notSelectedTitleColor, for: .normal)
        button.titleLabel?.font = FontBook.AvenirHeavy.of(size: 14)
        return button
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
