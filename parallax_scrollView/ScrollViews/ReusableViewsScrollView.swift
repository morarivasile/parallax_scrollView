//
//  ReusableViewsScrollView.swift
//  parallax_scrollView
//
//  Created by Vasile Morari on 16.06.2021.
//

import UIKit

protocol Instantiatable {
    static func instantiate() -> Self
}

extension Instantiatable where Self: UIView {
    static func instantiate() -> Self { .init() }
}

class ReusableViewsScrollView<T: UIView>: UIScrollView where T: Instantiatable {
    
    typealias ItemAtIndexCreation = (_ dequeuedView: T, _ index: Int) -> T
    
    var itemWidth: CGFloat = UIScreen.main.bounds.width
    
    private(set) var visibleViews = Dictionary<Int, T>()
    private(set) var reusableViews = Set<T>()
    
    private(set) var numberOfItems: Int = 0 {
        didSet { updateContentSize() }
    }
    
    private(set) var itemAtIndex: ItemAtIndexCreation?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let firstIndex = index(at: contentOffset)
        let lastIndex = index(
            at: CGPoint(
                x: contentOffset.x + (UIScreen.main.bounds.width / itemWidth) * itemWidth,
                y: .zero
            )
        )
        
        reuseOrInsertViews(first: firstIndex, last: lastIndex)
    }
    
    // MARK: - Public API
    
    func reloadData(numberOfItems: Int, itemAtIndex: @escaping ItemAtIndexCreation) {
        self.numberOfItems = numberOfItems
        self.itemAtIndex = itemAtIndex
    }
    
    /// To insert views using a range of ids
    func reuseOrInsertViews(first: Int, last: Int) {
        // Removing no longer needed views
        
        for view in visibleViews {
            if view.key < first || view.key > last {
                reusableViews.insert(view.value)
                
                view.value.removeFromSuperview()
            }
        }
        
        // Removing reusable pages from visible pages array
        
        for visibleView in visibleViews {
            for reusableView in reusableViews {
                if visibleView.value == reusableView {
                    visibleViews[visibleView.key] = nil
                }
            }
        }
        
        // Add the missing views
        
        for index in first...last {
            guard index < numberOfItems else { continue }
            
            if !visibleViews.map({ $0.key }).contains(index) {
                let reusedView = getReusableView()
                
                if let configuredView = itemAtIndex?(reusedView, index) {
                    configuredView.frame = frame(for: index)
                    
                    visibleViews[index] = configuredView
                    addSubview(configuredView)
                } else {
                    print("Couldn't prepare view")
                }
            }
        }
    }
    
    /// Returns view's frame for passed index
    func frame(for index: Int) -> CGRect {
        return CGRect(
            x: CGFloat(index) * itemWidth,
            y: 0,
            width: itemWidth,
            height: bounds.height
        )
    }
}

// MARK: - Private API

private extension ReusableViewsScrollView {
    /// Sets content size in dependence of number of items
    func updateContentSize() {
        contentSize = CGSize(
            width: itemWidth * CGFloat(numberOfItems),
            height: bounds.height
        )
    }
    
    /// Will return a reusable view, dequeueing it or instantiate it if needed
    func getReusableView() -> T {
        return reusableViews.popFirst() ?? T.instantiate()
    }
    
    /// Will return item index for passed position
    func index(at position: CGPoint) -> Int {
        return Int(position.x / itemWidth)
    }
}
