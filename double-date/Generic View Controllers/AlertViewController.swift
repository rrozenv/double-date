//
//  AlertViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/25/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

final class AlertViewController: UIViewController {
    
    var customAlertView: CustomAlertView!
    var buttonCount: ButtonCount = .one
    var alertInfo = AlertInfo(header: "Header",
                              message: "Message",
                              okButtonTitle: nil,
                              cancelButtonTitle: nil)
    var okTapped$ = PublishSubject<Void>()
    var okAction: (() -> ())?
    var cancelAction: (() -> ())?
    var opaqueButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(alertInfo: AlertInfo, okAction: (() -> Void)?) {
        self.init(nibName: nil, bundle: nil)
        self.buttonCount = .one
        self.alertInfo = alertInfo
        self.okAction = okAction
    }
    
    convenience init(alertInfo: AlertInfo, okAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        self.init(nibName: nil, bundle: nil)
        self.buttonCount = .two
        self.alertInfo = alertInfo
        self.okAction = okAction
        self.cancelAction = cancelAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = .clear
        setupOpaqueButton()
        setupCustomAlertView()
        configureAlertView(with: alertInfo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 1.0) {
            self.opaqueButton.alpha = 1.0
        }
    }
    
    deinit {
        print("AlertViewController deinit")
    }
    
}

extension AlertViewController {
    
    fileprivate func configureAlertView(with alertInfo: AlertInfo) {
        customAlertView.headerLabel.text = alertInfo.header
        customAlertView.messageLabel.text = alertInfo.message
        switch buttonCount {
        case .one:
            customAlertView.singleButton.setTitle(alertInfo.okButtonTitle.uppercased(), for: .normal)
        case .two:
            customAlertView.cancelButton.setTitle(alertInfo.cancelButtonTitle.uppercased(), for: .normal)
            customAlertView.okButton.setTitle(alertInfo.okButtonTitle.uppercased(), for: .normal)
        }
    }
    
    @objc fileprivate func didSelectOkButton(_ sender: UIButton) {
        self.okTapped$.onNext(())
        self.animateBackground { self.dismiss(animated: true, completion: { self.okAction?() }) }
    }
    
    @objc fileprivate func didSelectCancelButton(_ sender: UIButton) {
        self.animateBackground { self.dismiss(animated: true, completion: { self.cancelAction?() }) }
    }
    
    @objc fileprivate func didTapOpaqueButton(_ sender: UIButton) {
        self.animateBackground { self.dismiss(animated: true, completion: nil) }
    }
    
    private func animateBackground(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.opaqueButton.alpha = 0.0
        }) { _ in
            completion()
        }
    }
    
}

extension AlertViewController {
    
    private func setupOpaqueButton() {
        opaqueButton = UIButton()
        opaqueButton.alpha = 0.0
        opaqueButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        opaqueButton.addTarget(self, action: #selector(didTapOpaqueButton), for: .touchUpInside)
        
        view.addSubview(opaqueButton)
        opaqueButton.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    fileprivate func setupCustomAlertView() {
        customAlertView = CustomAlertView(buttonCount: buttonCount)
        customAlertView.layer.cornerRadius = 2.0
        customAlertView.layer.masksToBounds = true
        switch buttonCount {
        case .one:
            customAlertView.singleButton.addTarget(self, action: #selector(didSelectOkButton(_:)), for: .touchUpInside)
        case .two:
            customAlertView.okButton.addTarget(self, action: #selector(didSelectOkButton(_:)), for: .touchUpInside)
            customAlertView.cancelButton.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
        }
        
        self.view.addSubview(customAlertView)
        customAlertView.translatesAutoresizingMaskIntoConstraints = false
        customAlertView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customAlertView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        customAlertView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }
    
}

extension AlertViewController {
    
    enum ButtonCount {
        case one, two
    }
    
    struct AlertInfo {
        let header: String
        let message: String
        let okButtonTitle: String
        let cancelButtonTitle: String
        
        init(header: String, message: String, okButtonTitle: String?, cancelButtonTitle: String?) {
            self.header = header
            self.message = message
            self.okButtonTitle = okButtonTitle ?? "OK"
            self.cancelButtonTitle = cancelButtonTitle ?? "CANCEL"
        }
        
        static func custom(error: CustomError) -> AlertInfo {
            return AlertInfo(header: "Error",
                             message: error.message,
                             okButtonTitle: "Got It",
                             cancelButtonTitle: nil)
        }
        
        static var serverFailed: AlertInfo {
            return AlertInfo(header: "Server Error",
                             message: "Server failed to respond.",
                             okButtonTitle: "Got It",
                             cancelButtonTitle: nil)
        }
        
        static var decodingError: AlertInfo {
            return AlertInfo(header: "Decoding Failed",
                             message: "Failed to decode object.",
                             okButtonTitle: "Got It",
                             cancelButtonTitle: nil)
        }
        
        static var noFundsError: AlertInfo {
            return AlertInfo(header: "No Funds",
                             message: "You are not part of any funds!",
                             okButtonTitle: "Got It",
                             cancelButtonTitle: nil)
        }
        
        static func newPositionAlert(position: Position) -> AlertInfo  {
            return AlertInfo(header: "\(position.ticker) Purchased",
                             message: "You purchased \(position.ticker) for $\(position.shares * position.buyPrice)",
                             okButtonTitle: "Got It",
                             cancelButtonTitle: nil)
        }
        
        static func closePositionAlert(position: Position) -> AlertInfo  {
            return AlertInfo(header: "Close Position?",
                message: "Would you like to close your position in \(position.ticker) for a \(position.positionROI > 0.0 ? "profit" : "loss") of: \(position.profitLossDouble.asCurreny)",
                okButtonTitle: "Close",
                cancelButtonTitle: "Cancel")
        }
        
        static func closePositionConfirmation(position: Position) -> AlertInfo  {
            return AlertInfo(header: "Success",
                             message: "You closed your position in \(position.ticker) for a \(position.positionROI > 0.0 ? "profit" : "loss") of: \(position.profitLossDouble.asCurreny)",
                okButtonTitle: "Got It",
                cancelButtonTitle: nil)
        }
        
        static func enterLowerCapitalAmount(amount: Int) -> AlertInfo  {
            return AlertInfo(header: "Enter Lower Amount",
                message: "Please enter an amount lower than $1 Billion.",
                okButtonTitle: "Got It",
                cancelButtonTitle: nil)
        }
        
        static func acceptInvitation(invite: Invitation) -> AlertInfo  {
            return AlertInfo(header: "Accept Invite",
                             message: "Would you like to accept or reject your invite to: \(invite.fundName)?",
                okButtonTitle: "Accept",
                cancelButtonTitle: "Reject")
        }
    }
    
}

final class CustomAlertView: UIView {
    
    var containerView: UIView!
    var headerLabel: UILabel!
    var messageLabel: UILabel!
    var labelStackView: UIStackView!
    var okButton: UIButton!
    var cancelButton: UIButton!
    var stackView: UIStackView!
    var singleButton: UIButton!
    var dividerView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(buttonCount: AlertViewController.ButtonCount) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.yellow
        setupContainerView()
        
        switch buttonCount {
        case .one:
            setupSingleButton()
        case .two:
            setupOkButton()
            setupCancelButton()
            setupButtonStackView()
            setupDividerView()
        }
        
        setupHeaderLabel()
        setupMessageLabel()
        setupLabelStackView(given: buttonCount)
    }
    
    fileprivate func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 2.0
        containerView.layer.masksToBounds = true
        containerView.dropShadow()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    fileprivate func setupOkButton() {
        okButton = UIButton()
        okButton.setTitleColor(Palette.aqua.color, for: .normal)
        okButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 15)
        okButton.backgroundColor = UIColor.white
    }
    
    fileprivate func setupCancelButton() {
        cancelButton = UIButton()
        cancelButton.setTitleColor(Palette.lightBlue.color, for: .normal)
        cancelButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 15)
        cancelButton.backgroundColor = UIColor.white
    }
    
    fileprivate func setupButtonStackView() {
        stackView = UIStackView(arrangedSubviews: [cancelButton, okButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
    }
    
    fileprivate func setupHeaderLabel() {
        headerLabel = UILabel()
        headerLabel.font = FontBook.AvenirHeavy.of(size: 15)
        headerLabel.textColor = Palette.darkNavy.color
    }
    
    fileprivate func setupMessageLabel() {
        messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.font = FontBook.AvenirMedium.of(size: 13)
        messageLabel.textAlignment = .center
        messageLabel.textColor = Palette.lightBlue.color
    }
    
    fileprivate func setupLabelStackView(given buttonCount: AlertViewController.ButtonCount) {
        labelStackView = UIStackView(arrangedSubviews: [headerLabel, messageLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 15.0
        labelStackView.alignment = .center
        
        containerView.addSubview(labelStackView)
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30).isActive = true
        labelStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30).isActive = true
        labelStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        switch buttonCount {
        case .one:
            labelStackView.bottomAnchor.constraint(equalTo: singleButton.topAnchor, constant: -5).isActive = true
        case .two:
            labelStackView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -5).isActive = true
        }
    }
    
    fileprivate func setupSingleButton() {
        singleButton = UIButton()
        singleButton.backgroundColor = UIColor.white
        singleButton.setTitleColor(Palette.aqua.color, for: .normal)
        
        containerView.addSubview(singleButton)
        singleButton.translatesAutoresizingMaskIntoConstraints = false
        singleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        singleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        singleButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        singleButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
    }
    
    private func setupDividerView() {
        dividerView = UIView()
        dividerView.backgroundColor = Palette.faintGrey.color
        
        containerView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(stackView)
            make.width.equalTo(2)
            make.height.equalTo(stackView).multipliedBy(0.5)
        }
    }
    
}
