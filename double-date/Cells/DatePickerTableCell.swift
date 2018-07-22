//
//  DatePickerTableCell.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct DatePickerTableCellProps {
    let title: String
    let startDate: Date
}

final class DatePickerTableCell: UITableViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    static let defaultReusableId: String = "DatePickerTableCell"
    private var mainLabel: UILabel!
    var displayedDateButton: UIButton!
    var datePicker: UIDatePicker!
    var isDatePickerHidden = true
    var reload = PublishSubject<Void>()
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        setupMainLabel()
        setupDisplayedDateButton()
        setupDatePicker()
        setupContainerStackView()
    }
    
    // MARK: - Configuration
    func configureWith(value: DatePickerTableCellProps) {
        mainLabel.text = value.title
        datePicker.setDate(value.startDate, animated: true)
        datePicker.minimumDate = value.startDate
        
//        displayedDateButton.rx.tap.asObservable()
//            .subscribe(onNext: { [unowned self] in
//                print(!self.isDatePickerHidden)
//                self.isDatePickerHidden = !self.isDatePickerHidden
//                self.datePicker.isHidden = !self.isDatePickerHidden
//                self.reload.onNext(())
//            })
//            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension DatePickerTableCell {
    
    //MARK: View Setup
    
    private func setupMainLabel() {
        mainLabel = UILabel().rxStyle(font: FontBook.AvenirMedium.of(size: 14), color: .black, alignment: .left)
    }
    
    private func setupDisplayedDateButton() {
        displayedDateButton = UIButton().rxStyle(title: "\(Date())",
            font: FontBook.AvenirMedium.of(size: 12),
            backColor: .clear, titleColor: .black)
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        //datePicker.snp.makeConstraints { $0.height.equalTo(140) }
    }

    private func setupContainerStackView() {
        let labelButtonSv = UIStackView(arrangedSubviews: [mainLabel, displayedDateButton])
        labelButtonSv.axis = .horizontal
        labelButtonSv.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [labelButtonSv, datePicker])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5.0
        
        datePicker.isHidden = true
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(30)
        }
    }
    
}
