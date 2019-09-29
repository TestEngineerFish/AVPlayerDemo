//
//  BPFileModel.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/29.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation

enum BPFileType {
    case unknown
    case folder
    case image
    case audiovisual
}

struct BPFileModel {
    var path: String?
    var name: String?
    var size: Float?
    var type: BPFileType?
    var date: Date?

}
