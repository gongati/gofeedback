//
//  SampleCategoryViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 13/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import SnapKit

class SampleCategoryViewController: UIViewController {
    
    fileprivate var categories: [String] = []
    
    fileprivate var headerHeight: CGFloat {
        
        return 200
    }
    
    fileprivate lazy var headerViewController: SampleCategoryHeaderViewController = {
        
        let categoryHeaderViewController = SampleCategoryHeaderViewController()
        return categoryHeaderViewController
    }()
    
    fileprivate let navigationRowHeight: CGFloat = 60
    
    init(rapAssesmentPath: String? = nil){
        
        self.categories = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("\(#function) - has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupViews()
        self.setupHeader()
        self.scrollToTop()
    }
    
  
    func scrollToTop() {
        
        let offset = self.headerHeight
        let topOffset = CGPoint(x: 0, y: -offset)
    }
    
    fileprivate func setupViews() {
        
        self.view.backgroundColor = .white
    }
    
    func setupHeader() {
        
        self.addChild(self.headerViewController)
        self.makeStretcheable(strechableView: self.headerViewController.backgroundImageView, scrollableView: UIScrollView())
        self.headerViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
        self.updateStretchableConstraints()
    }
    
}

extension SampleCategoryViewController: StretchableHeader {
    
    var stretchableContentView: UIView? {
        
        return self.headerViewController.view
    }
    
    var contentOffsetY: CGFloat {
        
        return 0
    }
    
    var stretchableImageHeight: CGFloat {
        
        return self.headerHeight
    }
}

