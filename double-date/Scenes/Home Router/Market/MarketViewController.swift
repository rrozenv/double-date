//
//  MarketViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

final class MarketViewController: UIViewController {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    
    //MARK: - Views
    private var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        createLabel()
    }
    
    deinit { print("MarketViewController deinit") }
    
}

extension MarketViewController {
    
    private func createLabel() {
        label = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 14), color: .black)
        label.text = "Market View Controller"
        
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
}
