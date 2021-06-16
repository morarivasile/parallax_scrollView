//
//  ParallaxScrollView.swift
//  parallax_scrollView
//
//  Created by Vasile Morari on 16.06.2021.
//

import UIKit

class ParallaxScrollView<T: UIView>: InfiniteScrollView<ParallaxView<T>> {
    
    var tempo: CGFloat = 200.0
    
    private var ratio: CGFloat {
        tempo / itemWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in visibleViews {
            let newX = ratio * (contentOffset.x - CGFloat(view.key) * itemWidth)
            
            // Set frame for parallax content view
            
            view.value.contentView.frame.origin.x = newX
            
            // Update frame for parallax view if bounds change
            
            view.value.frame.size = CGSize(width: itemWidth, height: bounds.height)
        }
    }
}
