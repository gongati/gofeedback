//
//  StrechableHeader.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 13/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit


protocol StretchableHeader {
    /// View that will need its constraints updated
    var stretchableContentView: UIView? { get }
    
    /// The offset of the content. If you don't provide this variable a default of 0 is used
    var contentOffsetY: CGFloat { get }
    
    /// The height of the image you want to streach. If you don't provide this variable a default of 0 is used
    var stretchableImageHeight: CGFloat { get }
    
    /**
         Must be called in `updateConstraints()`
         
            - parameter gapOffset:
                a value that is subtracted form `contentOffsetY` to create a gap if needed
    */
    func updateStretchableConstraints(_ gapOffset: CGFloat)
    
    /// Call this before showing the view, i.e viewDidLoad
    
    func makeStretcheable(strechableView view: UIView?, scrollableView scrollView: UIScrollView)
    
}

extension StretchableHeader {
    
    var contentOffsetY: CGFloat {
        
        return 0
    }
    
    var stretchableImageHeight: CGFloat {
        
        return 200
    }
    
    func makeStretcheable(strechableView view: UIView?, scrollableView scrollView: UIScrollView) {
        
        self.addAndPositionStreachableContentView(inScrollView: scrollView)
        
        view?.contentMode = .scaleAspectFill
        view?.clipsToBounds = true

        var insets = scrollView.contentInset
        insets.top += self.stretchableImageHeight
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }
    
    func addAndPositionStreachableContentView(inScrollView scrollView: UIScrollView) {
        
        guard let stretchableContentView = self.stretchableContentView else { return }
        
        scrollView.addSubview(stretchableContentView)
        
        stretchableContentView.snp.makeConstraints { make in
            
            make.top.left.right.equalToSuperview()
            make.centerX.equalToSuperview() // constraint to fix center on smaller devices
            make.height.equalTo(self.stretchableImageHeight)
        }
    }
    
    func updateStretchableConstraints(_ gapOffset: CGFloat = 0) {

        self.stretchableContentView?.snp.updateConstraints {  update in
            
            let height = abs(min(self.contentOffsetY, 0))
            update.height.equalTo(height - gapOffset)

            update.top.equalTo(self.contentOffsetY)
        }
    }
}
