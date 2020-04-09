//
//  GFHistoryTableViewCell.swift
//  Genfare
//
//  Created by omniwzse on 28/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import SnapKit
import CDYelpFusionKit

class GFHistoryTableViewCell: UITableViewCell {

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
        label.font = label.font.withSize(15)
        label.textColor = .darkGray
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
        button.addTarget(self, action: #selector(makeCall), for: .touchUpInside)

        return button
    }()
    
    private lazy var bgView: GFCustomTableViewCellShadowView = GFCustomTableViewCellShadowView()
        
    private var phoneNumber:String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
        self.setupCell()
        
        self.setupConstraints()
    }
    
    private func setupCell() {
        
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
        self.accessoryType = .none
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("Fatel Error")
    }
    
    private func setupViews() {
        
        self.bgView.addSubview(self.titleLabel)
        self.bgView.addSubview(self.descLabel)
        self.bgView.addSubview(self.iconImageView)
        self.bgView.addSubview(self.distanceLabel)
        self.bgView.addSubview(self.callButton)
        self.contentView.addSubview(self.bgView)
        self.backgroundColor = .gray
        self.contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        
        self.iconImageView.snp.makeConstraints { make in
            
            make.leading.equalTo(16)
            make.height.width.equalTo(80)
            make.top.equalToSuperview().offset(8)
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            
            make.top.equalTo(self.iconImageView.snp.top)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        self.descLabel.snp.makeConstraints{ make in
            
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        self.distanceLabel.snp.makeConstraints { make in
            
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        self.callButton.snp.makeConstraints { make in
            
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalTo(self.distanceLabel.snp.leading).offset(100)
            make.height.equalTo(25)
        }
        
        self.bgView.snp.makeConstraints { make in
            
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }

    }

    func configureCell(_ bussiness: CDYelpBusiness?) {

        self.phoneNumber = bussiness?.phone
        self.titleLabel.text = bussiness?.name
        
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

extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension String {

    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }

    func isValid(regex: RegularExpressions) -> Bool { return isValid(regex: regex.rawValue) }
    func isValid(regex: String) -> Bool { return range(of: regex, options: .regularExpression) != nil }

    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }

    func makeACall() {
        guard   isValid(regex: .phone),
                let url = URL(string: "tel://\(self.onlyDigits())"),
                UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
