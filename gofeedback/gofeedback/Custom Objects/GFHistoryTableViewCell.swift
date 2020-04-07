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

    private lazy var iconImageView: UIImageView = UIImageView()

    private lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        label.allowsDefaultTighteningForTruncation = true
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        
        let label = UILabel()
        label.font = label.font.withSize(12)
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        label.allowsDefaultTighteningForTruncation = true
        return label
    }()
    
    private lazy var bgView: GFCustomTableViewCellShadowView = GFCustomTableViewCellShadowView()
        
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
        self.backgroundColor = .white
        
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("Fatel Error")
    }
    
    private func setupViews() {
        
        self.bgView.addSubview(self.titleLabel)
        self.bgView.addSubview(self.descLabel)
        self.bgView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.bgView)
    }
    
    private func setupConstraints() {
        
        self.iconImageView.snp.makeConstraints { make in
            
            make.leading.equalTo(16)
            make.height.width.equalTo(60)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        self.descLabel.snp.makeConstraints{ make in
            
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        self.bgView.snp.makeConstraints { make in
            
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }

    }

    func configureCell(_ bussiness: CDYelpBusiness?) {

        self.titleLabel.text = bussiness?.name
        
        if let location = bussiness?.location {
            
            self.descLabel.text = "\(location.addressOne ?? "") \(location.addressTwo ?? "") \(location.addressThree ?? "") \(location.city ?? "") \(location.state ?? "") \(location.country ?? "") \(location.zipCode ?? "")"
        }

        if let url = bussiness?.imageUrl {

            self.iconImageView.downloaded(from: url)
        }
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
