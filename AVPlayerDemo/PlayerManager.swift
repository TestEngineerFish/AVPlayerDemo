//
//  PlayerManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerManager: NSObject {

    var playerView: BPPlayerView!
    var timer: Timer?
    fileprivate var isSliding = false
    fileprivate var isShowToolBar = false

    init(path: String, frame: CGRect) {
        super.init()
        playerView = BPPlayerView(frame: frame)
        playerView?.makeData(path)
        playerView?.makeUI()
        addNotification()
        addTargetFunction()
        addGresture()
        startToolBarTimer()
        showVideoView()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    // 添加通知 & 监听
    private func addNotification() {
        // 添加通知
        NotificationCenter.default.addObserver(self, selector: #selector(playFinishNotification), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotateNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
        // 添加监听
        playerView.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { (time) in
            self.refreshTimeObserver(time)
        }
    }

    // 添加UI操作事件
    private func addTargetFunction() {
        playerView.backButton.addTarget(self, action: #selector(clickBackBtn(_:)), for: .touchUpInside)
        playerView.menuButton.addTarget(self, action: #selector(clickMenuBtn(_:)), for: .touchUpInside)
        playerView.playButton.addTarget(self, action: #selector(clickPlayBtn(_:)), for: .touchUpInside)
        playerView.speedButton.addTarget(self, action: #selector(clickSpeedBtn(_:)), for: .touchUpInside)
        playerView.progressSliderView.addTarget(self, action: #selector(willDragSlider(_:)), for: .touchDown)
        playerView.progressSliderView.addTarget(self, action: #selector(draggingSlider(_:)), for: .valueChanged)
        playerView.progressSliderView.addTarget(self, action: #selector(finishDragSlider(_:)), for: .touchUpInside)
        playerView.progressSliderView.addTarget(self, action: #selector(finishDragSlider(_:)), for: .touchDragOutside)
        playerView.progressSliderView.addTarget(self, action: #selector(finishDragSlider(_:)), for: .touchDragExit)
    }

    /// 添加手势事件
    private func addGresture() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapScreenView(_:)))
        singleTap.numberOfTapsRequired    = 1
        singleTap.numberOfTouchesRequired = 1
        playerView.addGestureRecognizer(singleTap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapScreenView(_:)))
        doubleTap.numberOfTapsRequired    = 2
        doubleTap.numberOfTouchesRequired = 1
        playerView.addGestureRecognizer(doubleTap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panScreenView(_:)))
//        pan.delegate = self
        playerView.addGestureRecognizer(pan)

        singleTap.require(toFail: doubleTap)
    }


    // TODO: UI操作回调函数

    @objc func clickBackBtn(_ button: UIButton) {
           hideVideoView()
       }

    @objc func clickMenuBtn(_ button: UIButton) {

    }

    /// 点击倍速
    @objc func clickSpeedBtn(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            setSpeedPlay(2)
        } else {
            setSpeedPlay(1)
        }
    }

    /// 点击播放、暂停
    @objc private func clickPlayBtn(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            pauseVideo()
        } else {
            playVideo()
        }
    }

    /// 手指按下,将要开始滑动进度条
    @objc private func willDragSlider(_ slider: UISlider) {
        pauseVideo()
        isSliding = true
        invalidateToolBarTimer()
    }

    /// 滑动进度条中
    @objc private func draggingSlider(_ slider: UISlider) {
        let totalTime = Float(playerView.playerItem?.duration.seconds ?? 0.0)
        let currentTime = totalTime * slider.value
        seekToVideo(startTime: Int64(currentTime))
    }

    /// 手指移开,结束进度条的滑动
    @objc private func finishDragSlider(_ slider: UISlider) {
        playVideo()
        isSliding = false
        startToolBarTimer()
    }
    // TODO: 其他事件处理

    /// 设置倍速
    private func setSpeedPlay(_ rate: Float) {
        playerView.player.rate = rate
    }

    func seekToVideo(startTime time: Int64) {
        let cmTime = CMTimeMake(value: time, timescale: 1)
        playerView.player.seek(to: cmTime) { (finish) in
            if finish {
                self.playVideo()
            }
        }
    }

     /// 显示上下工具栏
    private func showToolBar() {
        startToolBarTimer()
        isShowToolBar = true
        UIView.animate(withDuration: 0.25) {
            self.playerView.headerView.transform = .identity
            self.playerView.footerView.transform = .identity
        }
    }

     /// 隐藏上下工具栏
    @objc private func hideToolBar() {
        invalidateToolBarTimer()
        isShowToolBar = false
        UIView.animate(withDuration: 0.25) {
            self.playerView.headerView.transform = CGAffineTransform(translationX: 0, y: -self.playerView.headerView.bottom)
            self.playerView.footerView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight - self.playerView.footerView.top)
        }
    }

    /// 自动隐藏上下工具栏的计时器
    private func startToolBarTimer() {
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(hideToolBar), userInfo: nil, repeats: false)
    }

    /// 销毁计时器
    private func invalidateToolBarTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// 播放视频
    func playVideo() {
        playerView.playButton.isSelected = false
        self.playerView.player.play()
    }

    /// 暂停视频
    func pauseVideo() {
        playerView.playButton.isSelected = true
        playerView.player.pause()
    }

    /// 显示视频播放页
    func showVideoView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.playerView.transform = CGAffineTransform(translationX: 0, y: -kScreenHeight)
        }) { (finish) in
            if finish {
                self.playVideo()
            }
        }
    }

    /// 隐藏视频播放页
    func hideVideoView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.playerView.transform = .identity
            self.pauseVideo()
        }) { (finish) in
            if finish {
                self.playerView.removeFromSuperview()
            }
        }
    }

    // TODO: 手势处理

    @objc func singleTapScreenView(_ sender: UITapGestureRecognizer) {
        if isShowToolBar {
            hideToolBar()
        } else {
            showToolBar()
        }
    }

    @objc func doubleTapScreenView(_ sender: UITapGestureRecognizer) {
        if playerView.playButton.isSelected {
            playVideo()
            hideToolBar()
        } else {
            pauseVideo()
            showToolBar()
        }
    }

    @objc func panScreenView(_ sender: UIPanGestureRecognizer) {
        print("panScreenView")
    }

    // TODO: 通知 & 监听
    @objc func deviceRotateNotification() {
        switch UIDevice.current.orientation {
        case .portrait:
            playerView.headerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(kStatusBarHeight)
            }
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            playerView.headerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview()
            }
        default:
            break
        }
        UIView.animate(withDuration: 0.25) {
            self.playerView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            self.playerView.playerLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        }
    }

    @objc func playFinishNotification() {
        pauseVideo()
    }

    /// 更新时间事件
    func refreshTimeObserver(_ time: CMTime) {
        guard let item = playerView.playerItem else {
            return
        }
        let totalTime   = item.duration.seconds
        let currentTime = time.seconds
        if totalTime.isNaN || currentTime.isNaN {
            return
        }
        // 更新sliderView
        if !isSliding {
            playerView.progressSliderView.value = Float(currentTime/totalTime)
        }
        // 更新显示的时间
        playerView.leftTimeLabel.text  = transformTime(Int(currentTime))
        playerView.rightTimeLabel.text = transformTime(Int(totalTime))
    }

    // TODO: 工具函数
    private func transformTime(_ time: Int) -> String {
        let hour   = time / 3600
        let minute = time % 3600 / 60
        let second = time % 60
        return String(format: "%02ld:%02ld:%02ld", hour, minute, second)
    }
}
