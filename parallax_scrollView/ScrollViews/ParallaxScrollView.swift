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

class ParallaxView<T: UIView>: UIView {
    
    // MARK: - Content
    
    let contentView: T
    
    init(contentView: T) {
        self.contentView = contentView
        super.init(frame: contentView.frame)
        
        layer.masksToBounds = true
        
        addContentView(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func addContentView(_ contentView: T) {
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: - Instantiatable

extension ParallaxView: Instantiatable {
    static func instantiate() -> Self {
        return ParallaxView(contentView: T()) as! Self
    }
}
