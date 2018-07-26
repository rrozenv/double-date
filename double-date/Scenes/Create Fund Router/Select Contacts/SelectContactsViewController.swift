//
//  SelectContactsViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SelectContactsViewController: UIViewController, BindableType, CustomNavBarViewable, KeyboardAvoidable {
    
    var latestKeyboardHeight: CGFloat = 0
    var adjustableConstraint: Constraint!
    private var searchBarView: SearchBarView!
    private var tableView: UITableView!
    private var contactsNotEnabledView: EmptyView!
    private var nextButton: UIButton!
    var navView: BackButtonNavView = BackButtonNavView.blackArrow
    var navBackgroundView: UIView = UIView()
    
    let disposeBag = DisposeBag()
    var viewModel: SelectContactsViewModel!
    private let dataSource = MultipleSelectionFilterDataSource<ContactViewModel, UserContactTableCell>(isSingleSelection: false)
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        setupNavBar()
//        navView.containerView.backgroundColor = Palette.lightGrey.color
//        navBackgroundView.backgroundColor = Palette.lightGrey.color
        setupSearchBarView()
        setupTableView()
        setupEmptyView()
        setupNextButton()
        bindKeyboardNotifications(bottomOffset: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit { print("SelectSquadViewController deinit") }
    
    func bindViewModel() {
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        //MARK: - Inputs
        let backTapped$ = navView.backButton.rx.tap.asObservable()
        viewModel.bindBackButton(backTapped$)
        
        let nextTapped$ = nextButton.rx.tap
            .asObservable()
            .map { [unowned self] in self.dataSource.getAllSelectedItems() }
        viewModel.bindNextButton(nextTapped$)
        
        tableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [unowned self] in
                guard let user = self.dataSource.getItem(at: $0) else { return }
                self.dataSource.toggleSelectedStatus(of: user)
                self.tableView.reloadRows(at: [$0], with: .none)
            })
            .disposed(by: disposeBag)
        
        let enableContactsTapped$ = contactsNotEnabledView.button.rx.tap.asObservable()
        viewModel.bindDidSelectEnableContacts(enableContactsTapped$)
        
//        searchBarView.clearButton.rx.tap
//            .do(onNext: { [unowned self] in self.searchBarView.searchTextField.text = nil })
//            .subscribe(onNext: { [weak self] in
//                self?.dataSource.resetSearchFilter()
//                self?.tableView.reloadData()
//            })
//            .disposed(by: disposeBag)
        
        searchBarView.searchTextField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] in
                if $0.isEmpty {
                    self?.dataSource.resetSearchFilter()
                    //self?.updateContactsHeaderView()
                } else {
                    self?.dataSource.filterItemsFor(query: $0)
                }
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.hasAccessToContacts
            .bind(to: contactsNotEnabledView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.hasAccessToContacts
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in self?.viewModel.fetchContacts() })
            .disposed(by: disposeBag)
        
        dataSource.selectedCount
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.nextButton.isHidden = $0 > 0 ? false : true
            })
            .disposed(by: disposeBag)
        
        viewModel.userContacts
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (users) in
                self?.dataSource.load(items: users)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSearchBarView() {
        searchBarView = SearchBarView()
        searchBarView.style(placeHolder: "Search friends...", backColor: Palette.lightGrey.color, searchIcon: #imageLiteral(resourceName: "IC_Search"), clearIcon: #imageLiteral(resourceName: "IC_ClearSearch"))
        
        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { (make) in
            make.left.equalTo(navView.backButton.snp.right).offset(15)
            make.right.equalTo(view).offset(-15)
            make.centerY.equalTo(navView)
            make.height.equalTo(60)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = dataSource
        tableView.register(UserContactTableCell.self, forCellReuseIdentifier: UserContactTableCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(navView.snp.bottom)
        }
    }
    
    private func setupEmptyView() {
        contactsNotEnabledView = EmptyView()
        contactsNotEnabledView.titleLabel.style(font: FontBook.AvenirMedium.of(size: 14), color: Palette.darkGrey.color, alignment: .center)
        contactsNotEnabledView.button.style(title: "Enable Contacts", font: FontBook.AvenirMedium.of(size: 13), backColor: Palette.aqua.color, titleColor: .white)
        contactsNotEnabledView.populateInfoWith(titleText: "In order to choose the friends you want to go to a party with. Please enable access to your contacts.", buttonText: "Enable Contacts")
        
        view.addSubview(contactsNotEnabledView)
        contactsNotEnabledView.snp.makeConstraints { (make) in
            make.edges.equalTo(tableView)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.style(title: "Next")
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.left.right.equalTo(26)
            self.adjustableConstraint = $0.bottom.equalTo(view).constraint
        }
    }
    
}

extension SelectContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TitleView.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TitleView()
        headerView.configureWith(value: "Select your SQUAD.")
        let varyingFontInfo = VaryingFontInfo(originalText: "Select your SQUAD.", fontDict: ["SQUAD.": FontBook.AvenirBlack.of(size: 14), "Select your": FontBook.AvenirMedium.of(size: 13)], fontColor: .black)
        headerView.mainLabel.varyingFonts(info: varyingFontInfo)
        return headerView
    }
    
}
