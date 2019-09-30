//
//  PlayerManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

enum DrageDirectionEnum: Int {
    case unknown
    case leftUp
    case leftDown
    case rightUp
    case rightDown
    case left
    case right
}

class PlayerManager: NSObject {

    fileprivate var playerView: BPPlayerView!
    fileprivate var timer: Timer?
    fileprivate var isSliding      = false
    fileprivate var isShowToolBar  = true
    fileprivate var firstPoint     = CGPoint.zero
    fileprivate var secondPoint    = CGPoint.zero
    fileprivate var lastPoint      = CGPoint.zero
    fileprivate var drageDirection = DrageDirectionEnum.unknown
    fileprivate var totalTime      = Float.zero

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

    @objc private  func clickBackBtn(_ button: UIButton) {
           hideVideoView()
       }

    @objc private  func clickMenuBtn(_ button: UIButton) {

    }

    /// 点击倍速
    @objc private  func clickSpeedBtn(_ button: UIButton) {
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

    private func seekToVideo(startTime time: Int64) {
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
        if isShowToolBar { return }
        isShowToolBar = true
        UIView.animate(withDuration: 0.25) {
            self.playerView.headerView.transform = .identity
            self.playerView.footerView.transform = .identity
        }
    }

     /// 隐藏上下工具栏
    @objc private func hideToolBar() {
        invalidateToolBarTimer()
        if !isShowToolBar { return }
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
    private func pauseVideo() {
        playerView.playButton.isSelected = true
        playerView.player.pause()
    }

    /// 显示视频播放页
    private func showVideoView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.playerView.transform = CGAffineTransform(translationX: 0, y: -kScreenHeight)
        }) { (finish) in
            if finish {
                self.playVideo()
            }
        }
    }

    /// 隐藏视频播放页
    private func hideVideoView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.playerView.transform = .identity
            self.pauseVideo()
        }) { (finish) in
            if finish {
                self.playerView.removeFromSuperview()
            }
        }
    }

    /// 调节进度
    private func changeVideoProgress(progressValue value:Float) {
        playerView.playerItem?.cancelPendingSeeks()

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.playerView.progressSliderView.value = value / self.totalTime
            }
            self.playerView.leftTimeLabel.text = self.transformTime(Int(value))
            self.seekToVideo(startTime: Int64(value))
        }
    }

    /// 调节亮度
    private func changeBrightness(_ rate: CGFloat) {
        print(rate)
        UIScreen.main.brightness += rate
        print("当前是:\(UIScreen.main.brightness)")
    }

    /// 调节声音
    private func changeVolume(_ rate: CGFloat) {
        // 先获取系统 MPVolumeView 的控件,然后在赋值即可,一般重写会好些
    }

    // TODO: 手势处理

    @objc private  func singleTapScreenView(_ sender: UITapGestureRecognizer) {
        if isShowToolBar {
            hideToolBar()
        } else {
            showToolBar()
        }
    }

    @objc private  func doubleTapScreenView(_ sender: UITapGestureRecognizer) {
        if playerView.playButton.isSelected {
            playVideo()
            hideToolBar()
        } else {
            pauseVideo()
            showToolBar()
        }
    }

    @objc private  func panScreenView(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            print("开始滑动")
            pauseVideo()
            isSliding = true
            invalidateToolBarTimer()
            firstPoint = pan.location(in: playerView)
            drageDirection = .unknown
        case .changed:
            secondPoint = pan.location(in: playerView)
            let horizontalValue = secondPoint.x - firstPoint.x
            let verticalValue   = secondPoint.y - firstPoint.y
            var progressValue   = Float.zero
            switch drageDirection {
            case .left, .right:
                progressValue = Float(secondPoint.x - lastPoint.x)
                progressValue = Float(playerView.playerItem?.currentTime().seconds ?? 0) + progressValue
                self.changeVideoProgress(progressValue: progressValue)
            case .leftUp, .leftDown:
                progressValue = Float(lastPoint.y - secondPoint.y)
                let rate = CGFloat(progressValue) / kScreenHeight
                changeBrightness(rate)
            case .rightUp:
                print("leftUp")
            case .rightDown:
                print("leftUp")
            case .unknown:
            if abs(horizontalValue) > abs(verticalValue) {
                drageDirection = horizontalValue > 0 ? .right : .left
            } else {
                if firstPoint.x < playerView.width/2 {
                    drageDirection = verticalValue > 0 ? .leftDown : .leftUp
                } else {
                    drageDirection = verticalValue > 0 ? .rightDown : .rightUp
                }
            }
            }

            lastPoint = secondPoint
        default:
            print("滑动结束")
            playVideo()
            isSliding = false
            startToolBarTimer()
        }
    }

    // TODO: 通知 & 监听
    @objc private  func deviceRotateNotification() {
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

    @objc private  func playFinishNotification() {
        pauseVideo()
        showToolBar()
        invalidateToolBarTimer()
    }

    /// 更新时间事件
    private func refreshTimeObserver(_ time: CMTime) {
        guard let item = playerView.playerItem else {
            return
        }
        totalTime       = Float(item.duration.seconds)
        let currentTime = time.seconds
        if totalTime.isNaN || currentTime.isNaN {
            return
        }
        // 更新sliderView
        if !isSliding {
            playerView.progressSliderView.value = Float(currentTime)/totalTime
        }
        // 更新显示的时间
        playerView.leftTimeLabel.text  = transformTime(Int(currentTime))
        playerView.rightTimeLabel.text = transformTime(Int(totalTime))
    }

    // TODO: 工具函数
    private func transformTime(_ time: Int) -> String {
        var _time = time

        if time < 0 || totalTime == .nan {
            _time = 0
        } else if time > Int(totalTime) {
            _time = Int(totalTime)
        }
        let hour   = _time / 3600
        let minute = _time % 3600 / 60
        let second = _time % 60
        return String(format: "%02ld:%02ld:%02ld", hour, minute, second)
    }
}
