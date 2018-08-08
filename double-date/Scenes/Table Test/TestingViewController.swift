//
//  TestingViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

class GridCellTest: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ item: UIColor, at indexPath: IndexPath) {
        contentView.backgroundColor = item
    }
    
}

struct ModelOne {
    let name: String
}

struct ModelTwo {
    let name: String
}

enum TestSection {
    case sectionOne([ModelOne])
    case sectionTwo([ModelTwo])
    
    var itemCount: Int {
        switch self {
        case .sectionOne(let items): return items.count
        case .sectionTwo(let items): return items.count
        }
    }
}

final class TestingViewController: UIViewController {

    //MARK: - Views
    private var continueButton = UIButton()
    private var label = UILabel()
    
    //MARK: - Collection View
    private var collectionView: UICollectionView!
    //private var dataSoruce: CollectionDataSource<ArrayDataProvider<UIColor>, GridCellTest>!
    private var objects = ArrayDataProvider<UIColor>()
    private var timer: Timer!
    
    //MARK: - Table View
    private var tableView: UITableView!
    private var tableDataSource: TableViewDriver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(setDataSource), userInfo: nil, repeats: false)
        createContinueButton()
        setupCollectionViewLayout()
        setupCollectionViewDataSource()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.beginUpdates()
//        tableView.endUpdates()
    }
    
    @objc func didTapContinueButton(_ sender: UIButton) {
        print("Continue Tapped")
    }
    
    @objc func setDataSource(_ sender: Any) {
//        tableDataSource.updateHeader(in: 0, item: TableHeaderWrapper<TableHeaderView, String>(item: "Updating Section"))
        //objects.items = [[1, 2, 3, 4, 5].map { _ in UIColor.random }]
//        tableDataSource.sections = [[UIColor.orange, UIColor.red, UIColor.green].map { UserCellConfigurator(item: $0) }]
//        tableView.reloadData()
        //collectionView.reloadData()
    }
    
    private func setupCollectionViewDataSource() {
//        dataSoruce = CollectionDataSource<ArrayDataProvider<UIColor>, GridCellTest>(collectionView: collectionView, provider: objects)
//        dataSoruce.collectionItemSelectionHandler = { [weak self] indexPath in
//            guard let itemColor = self?.objects.item(at: indexPath) else { return }
//            self?.objects.updateItem(at: indexPath, value: itemColor == .purple ? .random : .purple)
//            self?.collectionView.reloadItems(at: [indexPath])
//        }
    }
    
}

extension TestingViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableDataSource = TableViewDriver(tableView: tableView,
                                          cellClasses: [UserCell.self, RandomCell.self],
                                          headerClasses: [TableHeaderView.self],
                                          footerClasses: [TableHeaderView.self],
                                          headerModels: [
                                            TableHeaderWrapper(item: "First Section")
                                          ],
                                          footerModels: [
                                            TableHeaderWrapper(item: "First Footer")
                                          ])
        
        tableDataSource.sections = [
            [
                UserCellWrapper(item: .yellow),
                UserCellWrapper(item: .red),
                RandomCellWrapper(item: "Hello")
            ]
        ]
        
        _ = tableDataSource.actionsProxy.on(.didSelect) { (c: UserCellWrapper, cell) in
                print("did select color cell", c.item.description)
            }
            .on(.didSelect) { (c: RandomCellWrapper, cell) in
                print("did select image cell", c.item)
            }
            .on(.custom(RandomCell.userFollowAction)) { (c: RandomCellWrapper, _) in
                print("button tapped", c.item)
            }
            .on(.custom(TableHeaderView.headerAction)) { (c: TableHeaderWrapper, _) in
                print("Header Button tapped", c.item)
            }
        
        view.addSubview(tableView)
        tableView.anchor(continueButton.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
    
}

extension TestingViewController {
    
    private func createContinueButton() {
        continueButton = continueButton.setup(title: "Continue", backgroundColor: .red, titleColor: .white, font: FontBook.AvenirHeavy.of(size: 12), target: self, selector: #selector(didTapContinueButton))
        
        view.addSubview(continueButton)
        continueButton.anchor(view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: 300)
    }
    
    private func setupCollectionViewLayout() {
        collectionView =
            UICollectionView(frame: .zero,
                             collectionViewLayout: CollectionViewFlowLayout(itemSpacing: 2.0,
                                                                            itemsPerRow: 3,
                                                                            itemHeight: 100,
                                                                            scrollDirection: .horizontal,
                                                                            isSelfSizing: false))
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.anchor(continueButton.bottomAnchor,
                              left: view.leftAnchor,
                              right: view.rightAnchor,
                              heightConstant: 100)
    }
    
}
