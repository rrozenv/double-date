//
//  EmptyLabelsView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/31/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

final class EmptyLabelsView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var bodyLabel: UILabel!
    var button: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupEmptyView()
    }
    
    func populateInfoWith(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }
    
    private func setupEmptyView() {
        titleLabel = UILabel().rxStyle(font: FontBook.AvenirHeavy.of(size: 14), color: Palette.lightBlue.color)
        bodyLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 12), color: Palette.lightBlue.color)
        bodyLabel.numberOfLines = 0
        
        let emptyLabelsSv = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        emptyLabelsSv.axis = .vertical
        emptyLabelsSv.distribution = .equalSpacing
        emptyLabelsSv.spacing = 5.0
        
        self.addSubview(emptyLabelsSv)
        emptyLabelsSv.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}
