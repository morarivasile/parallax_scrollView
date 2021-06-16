//
//  InfiniteScrollView.swift
//  parallax_scrollView
//
//  Created by Vasile Morari on 16.06.2021.
//

import UIKit

class InfiniteScrollView<T: UIView>: ReusableViewsScrollView<T> where T: Instantiatable {
    
    // MARK: - Private constants
    
    private let numberOfRequiredItemsForInfiniteScroll: Int = 2
    private let numberOfAdditionalViews: Int = 2
    
    // MARK: - Public properties
    
    private(set) var originalNumberOfItems: Int = 0
    
    var normalizedPageIndex: Int {
        if numberOfItems < numberOfRequiredItemsForInfiniteScroll {
            return infinitePageIndex
        } else {
            return getNormalizedIndex(
                from: infinitePageIndex,
                numberOfItems: originalNumberOfItems
            )
        }
    }
    
    var infinitePageIndex: Int {
        return Int(contentOffset.x / itemWidth)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if contentOffset.x + itemWidth >= contentSize.width {
            contentOffset = CGPoint(x: contentSize.width - contentOffset.x, y: 0)
        } else if contentOffset.x < .zero {
            contentOffset = CGPoint(x: contentSize.width - (CGFloat(numberOfAdditionalViews) * itemWidth), y: 0)
        }
    }
    
    override func reloadData(numberOfItems: Int, itemAtIndex: @escaping ItemAtIndexCreation) {
        originalNumberOfItems = numberOfItems
        
        if numberOfItems < numberOfRequiredItemsForInfiniteScroll {
            super.reloadData(numberOfItems: numberOfItems, itemAtIndex: itemAtIndex)
        } else {
            super.reloadData(numberOfItems: numberOfItems + numberOfAdditionalViews) { (reusedView, index) -> T in
                let normalizedIndex = self.getNormalizedIndex(from: index, numberOfItems: numberOfItems)
                return itemAtIndex(reusedView, normalizedIndex)
            }
            
            contentOffset = CGPoint(x: itemWidth, y: 0)
        }
    }
    
    override func reuseOrInsertViews(first: Int, last: Int) {
        guard numberOfItems >= numberOfRequiredItemsForInfiniteScroll else {
            super.reuseOrInsertViews(first: first, last: last)
            return
        }
        
        if first == .zero && last == .zero {
            super.reuseOrInsertViews(first: numberOfItems - numberOfAdditionalViews, last: numberOfItems - 1)
        } else if first == numberOfItems - 1 && last == numberOfItems {
            super.reuseOrInsertViews(first: 0, last: 1)
        } else {
            super.reuseOrInsertViews(first: first, last: last)
        }
    }
}

// MARK: - Public

extension InfiniteScrollView {
    func scrollToNextPage(animated: Bool = true) {
        let nextOffset = CGPoint(x: contentOffset.x + itemWidth, y: contentOffset.y)
        setContentOffset(nextOffset, animated: animated)
    }
}

// MARK: - Private

private extension InfiniteScrollView {
    func getNormalizedIndex(from index: Int, numberOfItems: Int) -> Int {
        if index == 0 {
            return numberOfItems - 1
        } else if index > numberOfItems {
            return 0
        } else {
            return index - 1
        }
    }
}
