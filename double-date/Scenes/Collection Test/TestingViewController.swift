//
//  TestingViewController.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

class GridCellTest: UICollectionViewCell, ConfigurableCell {
    
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



final class TestingViewController: UIViewController {

    //MARK: - Views
    private var continueButton = UIButton()
    private var label = UILabel()
    
    //MARK: - Collection View
    private var collectionView: UICollectionView!
    private var dataSoruce: CollectionDataSource<ArrayDataProvider<UIColor>, GridCellTest>!
    private var objects = ArrayDataProvider<UIColor>()
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(setDataSource), userInfo: nil, repeats: false)
        createContinueButton()
        setupCollectionViewLayout()
        setupCollectionViewDataSource()
    }
    
    @objc func didTapContinueButton(_ sender: UIButton) {
        print("Continue Tapped")
    }
    
    @objc func setDataSource(_ sender: Any) {
        objects.items = [[1, 2, 3, 4, 5].map { _ in UIColor.random }]
        collectionView.reloadData()
    }
    
    private func setupCollectionViewDataSource() {
        dataSoruce = CollectionDataSource<ArrayDataProvider<UIColor>, GridCellTest>(collectionView: collectionView, provider: objects)
        dataSoruce.collectionItemSelectionHandler = { [weak self] indexPath in
            guard let itemColor = self?.objects.item(at: indexPath) else { return }
            self?.objects.updateItem(at: indexPath, value: itemColor == .purple ? .random : .purple)
            self?.collectionView.reloadItems(at: [indexPath])
        }
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
