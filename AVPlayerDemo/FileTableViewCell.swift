//
//  FileTableViewCell.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/29.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    var iconLabel = UILabel()
    var nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }
    
    private func makeUI() {
        addSubview(iconLabel)
        addSubview(nameLabel)
        
        iconLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(40)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconLabel.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-30)
            make.height.equalToSuperview()
        }

        selectionStyle = .none
        iconLabel.font = UIFont.iconFont(size: 30)
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        iconLabel.textColor     = UIColor.blue1
        nameLabel.textColor     = UIColor.black1
        nameLabel.lineBreakMode = .byTruncatingMiddle

    }
    
    func makeData(_ model: BPFileModel) {
        var iconImageStr = IconFont.unknownFIle.rawValue
        switch model.type {
        case .folder:
            iconImageStr  = IconFont.folderFile.rawValue
            accessoryType = .disclosureIndicator
        case .text:
            iconImageStr  = IconFont.textFile.rawValue
            accessoryType = .none
        case .image:
            iconImageStr  = IconFont.imageFile.rawValue
            accessoryType = .none
        case .audiovisual:
            iconImageStr  = IconFont.videoFile.rawValue
            accessoryType = .none
        default:
            iconImageStr  = IconFont.unknownFIle.rawValue
            accessoryType = .none
        }
        iconLabel.text = iconImageStr
        nameLabel.text = model.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
