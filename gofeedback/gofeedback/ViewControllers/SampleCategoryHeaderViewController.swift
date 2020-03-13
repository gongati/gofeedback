//
//  SampleCategoryHeaderViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 13/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import Foundation
import UIKit

import SnapKit

class SampleCategoryHeaderViewController: UIViewController {
    
    static let actionButtonContainerHeight: CGFloat = 25
    
    fileprivate(set) lazy var backgroundImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: "starbucks-bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
        
    fileprivate(set) lazy var heroLabel: UILabel = {
        
        let label = UILabel()
        
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        //label.font = UIFont.h5
        
        return label
    }()
    
    fileprivate(set) lazy var subTitleLabel: UILabel = {
        
        let label = UILabel()
        
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.8
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        //label.font = UIFont.p3
        label.textColor = .white
        
        return label
    }()
    
    //Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.heroLabel)
        self.view.addSubview(self.subTitleLabel)
        
        self.setupConstraints()
    }
    
    func setupConstraints() {
        
        self.backgroundImageView.snp.makeConstraints { make in
            
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.heroLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        self.heroLabel.snp.makeConstraints { make in
            
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(165)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.subTitleLabel.snp.makeConstraints { make in
            
            make.centerX.equalTo(self.heroLabel.snp.centerX)
            make.top.equalTo(self.heroLabel.snp.bottom).offset(6)
            
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
}

