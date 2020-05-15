//
//  CustomAnnotationView.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 11/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import SnapKit
import CDYelpFusionKit

protocol AnnotationAction: class {
    
    func annotationTapped(name: String)
}

class CustomAnnotationView: UIView  {
    
    weak var delegate: AnnotationAction?
        
        private lazy var iconImageView: UIImageView = {
           
            let imageView = UIImageView()
            imageView.backgroundColor = .lightGray
            imageView.contentMode = .scaleToFill
            imageView.layer.cornerRadius = 4
            imageView.clipsToBounds = true
            
            return imageView
        }()

        private lazy var titleLabel: UILabel = {
            
            let label = UILabel()
            label.font = label.font.withSize(20)
            label.textColor = .black
            label.lineBreakMode = .byTruncatingTail
            label.allowsDefaultTighteningForTruncation = true
            return label
        }()
        
        private lazy var distanceLabel: UILabel = {
            
            let label = UILabel()
            label.font = label.font.withSize(12)
            label.textColor = .systemBlue
            label.lineBreakMode = .byTruncatingTail
            label.allowsDefaultTighteningForTruncation = true
            return label
        }()
        
        private lazy var descLabel: UILabel = {
            
            let label = UILabel()
            label.font = label.font.withSize(12)
            label.textColor = .black
            label.numberOfLines = 2
            return label
        }()
        
        lazy var callButton: UIButton = {
            
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.contentHorizontalAlignment = .right
            button.addTarget(self, action: #selector(makeCall), for: .touchUpInside)

            return button
        }()

    lazy var actionButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)

        return button
    }()

        private var phoneNumber:String?
    
        private var title:String?
    
        init() {
            
            super.init(frame: CGRect.zero)
            
            self.setupViews()
            self.setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            super.init(coder: aDecoder)
        }
    
        private func setupViews() {
            
            self.addSubview(self.titleLabel)
            self.addSubview(self.descLabel)
            self.addSubview(self.iconImageView)
            self.addSubview(self.distanceLabel)
            self.addSubview(self.actionButton)
            self.addSubview(self.callButton)
            self.backgroundColor = .clear
        }
        
        private func setupConstraints() {
            
            self.iconImageView.snp.makeConstraints { make in
                
                make.leading.equalToSuperview()
                make.height.width.equalTo(80)
                make.top.equalToSuperview().offset(0)
            }
            
            self.titleLabel.snp.makeConstraints{ make in
                
                make.top.equalTo(self.iconImageView.snp.top)
                make.leading.equalTo(self.iconImageView.snp.trailing).offset(8)
                make.trailing.equalToSuperview().offset(0)
            }
            
            self.descLabel.snp.makeConstraints{ make in
                
                make.top.equalTo(self.titleLabel.snp.bottom).offset(4)
                make.leading.equalTo(self.iconImageView.snp.trailing).offset(8)
                make.trailing.equalToSuperview().offset(-8)
            }
            
            self.distanceLabel.snp.makeConstraints { make in
                
                make.bottom.equalToSuperview().offset(0)
                make.leading.equalTo(self.iconImageView.snp.trailing).offset(8)
                make.trailing.equalToSuperview().offset(-8)
            }
            
            self.callButton.snp.makeConstraints { make in
                
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(0)
                make.height.equalTo(20)
            }
            
            self.actionButton.snp.makeConstraints { (make) in
                
                make.edges.equalToSuperview()
            }
            
        }

        func configureView(_ bussiness: CDYelpBusiness?) {

            self.phoneNumber = bussiness?.phone
            self.titleLabel.text = bussiness?.name
            self.title = bussiness?.name
            
            if let location = bussiness?.location {
                
                self.descLabel.text = "\(location.addressOne ?? "") \(location.addressTwo ?? "") \(location.addressThree ?? "") \(location.city ?? "") \(location.state ?? "") \(location.country ?? "") \(location.zipCode ?? "")"
            }
            
            if let distance = bussiness?.distance {
                
                let miles = distance/1609.34
                
                self.distanceLabel.text = String(format: "%.2f miles",miles)
            }

            if let contact = bussiness?.phone {
                
                self.callButton.setTitle(self.formattedNumber(number: contact), for: .normal)
            }
            
            if let url = bussiness?.imageUrl {

                self.iconImageView.downloaded(from: url)
            }
        }
        
        @objc func makeCall() {
            
            self.phoneNumber?.makeACall()
        }
        
        @objc func tapAction() {
            
            self.delegate?.annotationTapped(name: self.title ?? "")
        }
    
        func formattedNumber(number: String) -> String {
            let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let mask = "+X (XXX) XXX-XXXX"

            var result = ""
            var index = cleanPhoneNumber.startIndex
            for ch in mask where index < cleanPhoneNumber.endIndex {
                if ch == "X" {
                    result.append(cleanPhoneNumber[index])
                    index = cleanPhoneNumber.index(after: index)
                } else {
                    result.append(ch)
                }
            }
            return result
        }
}
