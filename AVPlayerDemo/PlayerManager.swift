//
//  PlayerManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

class PlayerManager: NSObject, UIGestureRecognizerDelegate {

    var playerView: BPPlayerView!

    init(path: String, frame: CGRect) {
        super.init()
        playerView = BPPlayerView(frame: frame)
        playerView?.makeData(path)
        playerView?.makeUI()
        addGresture()
        playerView?.showVideo()
    }

    /// 添加手势事件
    private func addGresture() {
        guard let _playerView = playerView else {
            return
        }
        let singleTap = UITapGestureRecognizer(target: _playerView, action: #selector(singleTapScreenView(_:)))
        //        singleTap.delegate                = self
        singleTap.numberOfTapsRequired    = 1
        singleTap.numberOfTouchesRequired = 1
        playerView?.addGestureRecognizer(singleTap)
        let doubleTap = UITapGestureRecognizer(target: _playerView, action: #selector(doubleTapScreenView(_:)))
        //        doubleTap.delegate                = self
        doubleTap.numberOfTapsRequired    = 2
        doubleTap.numberOfTouchesRequired = 1
        playerView?.addGestureRecognizer(doubleTap)
        let pan = UIPanGestureRecognizer(target: _playerView, action: #selector(panScreenView(_:)))
        pan.delegate = self
        playerView?.addGestureRecognizer(pan)

        singleTap.require(toFail: doubleTap)
    }

    // TODO: 手势处理

    @objc func singleTapScreenView(_ sender: UITapGestureRecognizer) {
        print("singleTapScreenView")
    }

    @objc func doubleTapScreenView(_ sender: UITapGestureRecognizer) {
        print("doubleTapScreenView")
        guard let _playView = playerView else { return }
        if _playView.playButton.isSelected {
            _playView.playVideo()
        } else {
            _playView.pauseVideo()
        }
    }

    @objc func panScreenView(_ sender: UIPanGestureRecognizer) {
        print("panScreenView")
    }
}
