//
//  InfiniteScrollView.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/1/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

class InfiniteScrollView : UIScrollView, UIScrollViewDelegate {
    
    // 1
    var views: [UIView] = [] {
        didSet {
            setupViews()
        }
    }
    var currentPage = 0
    var currentOffset: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollsToTop = false
        delegate = self
    }
    
    // 4
    private func setupViews() {
        views.enumerated().forEach { index, view in
            var newFrame = frame
            newFrame.origin.x = frame.size.width * CGFloat(index)
            newFrame.origin.y = 0
            view.frame = newFrame
            addSubview(view)
        }
        contentSize = CGSize(width: frame.width * CGFloat(views.count),
                             height: frame.height)
        layoutIfNeeded()
    }
    
    // 6
    @objc internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let lastOffset = currentOffset
        currentOffset = contentOffset.x
        if currentOffset >= lastOffset {
           currentPage += 1
        } else if lastOffset >= currentOffset {
            currentPage -= 1
        }
        
        let pageWidth = frame.size.width
//        let page: Int = Int(floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1)
//        print(contentOffset.x)
//        print(floor((contentOffset.x - (pageWidth/2)) / pageWidth))
        if currentPage == -1 {
            currentPage = views.count - 1
            currentOffset = pageWidth * (CGFloat(views.count - 1))
            contentOffset = CGPoint(x: pageWidth*(CGFloat(views.count - 1)), y: 0)
        } else if currentPage == views.count {
            currentPage = 0
            currentOffset = 0
            contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
}

class LoopyScrollThingy : UIScrollView, UIScrollViewDelegate {
    
    // 1
    var viewObjects: [UIView]?
    var numPages: Int = 0
    
    // 2
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollsToTop = false
        delegate = self
    }
    
    // 3
    func setup() {
        contentSize = CGSize(width: (frame.size.width * (CGFloat(numPages) + 2)), height: frame.size.height)
        
        loadScrollViewWithPage(page: 0)
        loadScrollViewWithPage(page: 1)
        loadScrollViewWithPage(page: 2)
        
        var newFrame = frame
        newFrame.origin.x = newFrame.size.width
        newFrame.origin.y = 0
        scrollRectToVisible(newFrame, animated: false)
        
        layoutIfNeeded()
    }
    
    // 4
    private func loadScrollViewWithPage(page: Int) {
        if page < 0 { return }
        if page >= numPages + 2 { return }
        
        var index = 0
        
        if page == 0 {
            index = numPages - 1
        } else if page == numPages + 1 {
            index = 0
        } else {
            index = page - 1
        }
        
        let view = viewObjects?[index]
        
        var newFrame = frame
        newFrame.origin.x = frame.size.width * CGFloat(page)
        newFrame.origin.y = 0
        view?.frame = newFrame
        
        if view?.superview == nil {
            addSubview(view!)
        }
        
        //layoutIfNeeded()
    }
    
    // 5
    // This really works well with > 2 pages. It works with 2, but the effect is slightly broken.
    @objc internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page = floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1
        
        loadScrollViewWithPage(page: Int(page - 1))
        loadScrollViewWithPage(page: Int(page))
        loadScrollViewWithPage(page: Int(page + 1))
    }
    
    // 6
    @objc internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page : Int = Int(floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1)
        
        if page == 0 {
            contentOffset = CGPoint(x: pageWidth*(CGFloat(numPages)), y: 0)
        } else if page == numPages + 1 {
            contentOffset = CGPoint(x: pageWidth, y: 0)
        }
    }
    
}


public protocol InfinitePageViewDelegate: class {
    func pageViewCurrentIndex(currentIndex: Int)
}

public class InfinitePageViewController: UIPageViewController {
    private var controllers: [AnimatableViewController]
    public weak var infiniteDelegate: InfinitePageViewDelegate?
    private var lastIndex = -1
    
    init(frame: CGRect, viewControllers: [AnimatableViewController]) {
        controllers = viewControllers
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        guard let firstViewController = controllers.first else {
            return
        }
        
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func animate(at index: Int) {
        guard index != lastIndex else { return }
        //resetAnimation(at: lastIndex)
        controllers[index].animate()
        lastIndex = index
    }
    
//    func resetAnimation(at index: Int) {
//        guard index >= 0 else { return }
//        controllers[index].resetAnimation()
//    }
}

extension InfinitePageViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? AnimatableViewController,
              let index = controllers.index(of: vc) else { return nil }
        infiniteDelegate?.pageViewCurrentIndex(currentIndex: index)
        
        let nextIndex = index + 1
        if nextIndex == controllers.count {
            return controllers.first
        }
        
        return controllers[nextIndex]
    }
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? AnimatableViewController,
              let index = controllers.index(of: vc) else {
            return nil
        }
        
        infiniteDelegate?.pageViewCurrentIndex(currentIndex: index)
        
        if index == 0 {
            return controllers[controllers.count-1]
        }
        
        let previousIndex = index - 1
        return controllers[previousIndex]
    }
    
}
