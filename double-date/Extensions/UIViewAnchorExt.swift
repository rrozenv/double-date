//
//  UIViewAnchorExt.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/3/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    public func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    
    public func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        _ = anchorWithReturnAnchors(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: widthConstant, heightConstant: heightConstant)
    }
    
    public func anchorWithReturnAnchors(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    public func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    public func anchorCenterYToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    public func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
    
}

extension UIButton {
    
    public func setup(title: String? = nil,
                      backgroundColor: UIColor? = .clear,
                      image: UIImage? = nil,
                      titleColor: UIColor? = .white,
                      font: UIFont? = nil,
                      target: Any? = nil,
                      selector: Selector? = nil) -> UIButton {
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        if let selector = selector {
            self.addTarget(target, action: selector, for: .touchUpInside)
        }
        return self
    }
    
}

extension NSMutableAttributedString {
    
    public func appendNewLine() {
        append(NSAttributedString(string: "\n"))
    }
    
    public func centerAlignWithSpacing(_ lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = lineSpacing
        setParagraphStyle(paragraphStyle: paragraphStyle)
    }
    
    public func setLineSpacing(_ lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        setParagraphStyle(paragraphStyle: paragraphStyle)
    }
    
    func setParagraphStyle(paragraphStyle: NSParagraphStyle) {
        let range = NSMakeRange(0, string.count)
        addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: range)
    }
    
}

open class Datasource: NSObject {
    
    public var objects: [Any]?
    
    ///The cell classes that will be used to render out each section.
    open func cellClasses() -> [DatasourceCell.Type] {
        return []
    }
    
    ///If you want more fine tuned control per row, override this method to provide the proper cell type that should be rendered
    open func cellClass(_ indexPath: IndexPath) -> DatasourceCell.Type? {
        return nil
    }
    
    ///Override this method to provide your list with what kind of headers should be rendered per section
    open func headerClasses() -> [DatasourceCell.Type]? {
        return []
    }
    
    ///Override this method to provide your list with what kind of footers should be rendered per section
    open func footerClasses() -> [DatasourceCell.Type]? {
        return []
    }
    
    open func numberOfItems(_ section: Int) -> Int {
        return objects?.count ?? 0
    }
    
    open func numberOfSections() -> Int {
        return 1
    }
    
    ///For each row in your list, override this to provide it with a specific item. Access this in your DatasourceCell by overriding datasourceItem.
    open func item(_ indexPath: IndexPath) -> Any? {
        return objects?[indexPath.item]
    }
    
    ///If your headers need a special item, return it here.
    open func headerItem(_ section: Int) -> Any? {
        return nil
    }
    
    ///If your footers need a special item, return it here
    open func footerItem(_ section: Int) -> Any? {
        return nil
    }
    
}



open class DatasourceController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    open let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.hidesWhenStopped = true
        aiv.color = .black
        return aiv
    }()
    
    open var datasource: Datasource? {
        didSet {
            if let cellClasses = datasource?.cellClasses() {
                for cellClass in cellClasses {
                    collectionView?.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
                }
            }
            
            if let headerClasses = datasource?.headerClasses() {
                for headerClass in headerClasses {
                    collectionView?.register(headerClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(headerClass))
                }
            }
            
            if let footerClasses = datasource?.footerClasses() {
                for footerClass in footerClasses {
                    collectionView?.register(footerClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(footerClass))
                }
            }
            
            collectionView?.reloadData()
        }
    }
    
    public init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let defaultCellId = "lbta_defaultCellId"
    let defaultFooterId = "lbta_defaultFooterId"
    let defaultHeaderId = "lbta_defaultHeaderId"
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.anchorCenterXToSuperview()
        activityIndicatorView.anchorCenterYToSuperview()
        
        collectionView?.register(DefaultCell.self, forCellWithReuseIdentifier: defaultCellId)
        collectionView?.register(DefaultHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: defaultHeaderId)
        collectionView?.register(DefaultFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: defaultFooterId)
    }
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datasource?.numberOfSections() ?? 0
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource?.numberOfItems(section) ?? 0
    }
    
    //need to override this otherwise size doesn't get called
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: DatasourceCell
        
        if let cls = datasource?.cellClass(indexPath) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cls), for: indexPath) as! DatasourceCell
        } else if let cellClasses = datasource?.cellClasses(), cellClasses.count > indexPath.section {
            let cls = cellClasses[indexPath.section]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cls), for: indexPath) as! DatasourceCell
        } else if let cls = datasource?.cellClasses().first {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cls), for: indexPath) as! DatasourceCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath) as! DatasourceCell
        }
        
        cell.controller = self
        cell.datasourceItem = datasource?.item(indexPath)
        return cell
    }
    
    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView: DatasourceCell
        
        if kind == UICollectionElementKindSectionHeader {
            if let classes = datasource?.headerClasses(), classes.count > indexPath.section {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(classes[indexPath.section]), for: indexPath) as! DatasourceCell
            } else if let cls = datasource?.headerClasses()?.first {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(cls), for: indexPath) as! DatasourceCell
            } else {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: defaultHeaderId, for: indexPath) as! DatasourceCell
            }
            reusableView.datasourceItem = datasource?.headerItem(indexPath.section)
            
        } else {
            if let classes = datasource?.footerClasses(), classes.count > indexPath.section {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(classes[indexPath.section]), for: indexPath) as! DatasourceCell
            } else if let cls = datasource?.footerClasses()?.first {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(cls), for: indexPath) as! DatasourceCell
            } else {
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: defaultFooterId, for: indexPath) as! DatasourceCell
            }
            reusableView.datasourceItem = datasource?.footerItem(indexPath.section)
        }
        
        reusableView.controller = self
        
        return reusableView
    }
    
    open func getRefreshControl() -> UIRefreshControl {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rc
    }
    
    @objc open func handleRefresh() {
        
    }
    
    open var layout: UICollectionViewFlowLayout? {
        get {
            return collectionViewLayout as? UICollectionViewFlowLayout
        }
    }
}

open class DatasourceCell: UICollectionViewCell {
    
    open var datasourceItem: Any?
    open weak var controller: DatasourceController?
    
    open let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lineView.isHidden = true
        return lineView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    ///Override this method to provide your own custom views.
    open func setupViews() {
        clipsToBounds = true
        addSubview(separatorLineView)
        separatorLineView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DefaultHeader: DefaultCell {
    
    override var datasourceItem: Any? {
        didSet {
            if datasourceItem == nil {
                label.text = "This is your default header"
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        label.text = "Header Cell"
        label.textAlignment = .center
    }
}

class DefaultFooter: DefaultCell {
    
    override var datasourceItem: Any? {
        didSet {
            if datasourceItem == nil {
                label.text = "This is your default footer"
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        label.text = "Footer Cell"
        label.textAlignment = .center
    }
}

class DefaultCell: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            if let text = datasourceItem as? String {
                label.text = text
            } else {
                label.text = datasourceItem.debugDescription
            }
        }
    }
    
    let label = UILabel()
    
    override func setupViews() {
        super.setupViews()
        addSubview(label)
        label.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
    
}
