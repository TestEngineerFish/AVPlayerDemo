//
//  PlayerManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

struct PlayerManager {

    var playerView: BPPlayerView?


    init(path: String, frame: CGRect) {
        playerView = BPPlayerView(frame: frame)
        playerView?.makeData(path)
        playerView?.makeUI()
        playerView?.player.play()
//        playerView?.setFullscreen(.left)
    }

    static func showVideo(sourcePath path: String) {
    }

}
