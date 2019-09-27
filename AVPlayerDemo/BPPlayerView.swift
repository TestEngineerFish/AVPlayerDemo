//
//  BPPlayerView.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class BPPlayerView: UIView {

    fileprivate let headerViewHeight: CGFloat = 40
    fileprivate let footerViewHeight: CGFloat = 40
    fileprivate let padding: CGFloat          = 10
    fileprivate let aspectRatio: CGFloat      = kScreenHeight/kScreenWidth
    fileprivate var isSliding                 = false

    var playerItem: AVPlayerItem?
    let player             = AVPlayer()
    var playerLayer        = AVPlayerLayer()
    let coverView          = UIView()
    let headerView         = UIView()
    let playButton         = UIButton()
    let progressView       = UIProgressView()
    let progressSliderView = UISlider()
    let leftTimeLabel      = UILabel()
    let rightTimeLabel     = UILabel()
    let speedButton        = UIButton()
    let footerView         = UIView()
    let backButton         = UIButton()
    let menuButton         = UIButton()
    let loadView           = UIActivityIndicatorView(style: .white)

    fileprivate var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: kScreenHeight, width: frame.width, height: frame.height))
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: 设置UI
    func makeUI() {
        makeSubviews()
        makeHeaderSubviews()
        makeFooterSubviews()
        addNotifications()
    }

    /// 设置子视图
    private func makeSubviews() {

        // 设置当前视图
        kWindow.addSubview(self)
        self.backgroundColor = UIColor.black

        // 设置播放视图
        layer.addSublayer(playerLayer)
        playerLayer.frame           = CGRect(x: 0, y: 0, width: width, height: height)
        playerLayer.videoGravity    = AVLayerVideoGravity.resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor

        // 设置顶部遮罩层
        addSubview(coverView)
        coverView.backgroundColor = UIColor.clear
        coverView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width)
            make.left.equalToSuperview()
        }

        // 设置顶部视图
        coverView.addSubview(headerView)
        headerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.left.width.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }

        // 设置底部视图
        coverView.addSubview(footerView)
        footerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let bottomOffset: CGFloat = iPhoneXLater ? -15 : 0
        footerView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(bottomOffset)
            make.left.width.equalToSuperview()
            make.height.equalTo(footerViewHeight)
        }

        // 设置加载中视图
        loadView.center = coverView.center
        addSubview(loadView)
    }

    /// 设置顶部子视图
    private func makeHeaderSubviews() {
        // 设置返回按钮
        headerView.addSubview(backButton)
        backButton.setTitle(IconFont.back.rawValue, for: .normal)
        backButton.titleLabel?.font = UIFont.iconFont(size: 18)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.addTarget(self, action: #selector(clickBackBtn(_:)), for: .touchUpInside)
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(headerViewHeight)
        }

        // 设置菜单按钮
        headerView.addSubview(menuButton)
        menuButton.frame = CGRect(x: headerView.width - headerView.height - 15, y: 0, width: headerView.height, height: headerView.height)
        menuButton.setTitle(IconFont.menu.rawValue, for: .normal)
        menuButton.titleLabel?.font = UIFont.iconFont(size: 18)
        menuButton.setTitleColor(UIColor.white, for: .normal)
        menuButton.addTarget(self, action: #selector(clickMenuBtn(_:)), for: .touchUpInside)
        menuButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(headerViewHeight)
        }
    }

    /// 设置底部子视图
    private func makeFooterSubviews() {
        // 设置播放、暂停按钮
        footerView.addSubview(playButton)
        // 设置左侧时间视图
        footerView.addSubview(leftTimeLabel)
        // 设置缓冲条视图
        footerView.addSubview(progressView)
        // 设置滑动懒视图
        footerView.addSubview(progressSliderView)
        // 设置右侧时间视图
        footerView.addSubview(rightTimeLabel)
        // 设置全屏按钮
        footerView.addSubview(speedButton)

        playButton.setTitle(IconFont.pause.rawValue, for: .normal)
        playButton.setTitle(IconFont.play.rawValue, for: .selected)
        playButton.setTitleColor(UIColor.white, for: .normal)
        playButton.titleLabel?.font = UIFont.iconFont(size: 18)
        playButton.addTarget(self, action: #selector(clickPlayBtn(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(footerViewHeight)
        }

        leftTimeLabel.text          = "00:00:00"
        leftTimeLabel.textColor     = UIColor.white
        leftTimeLabel.font          = UIFont.systemFont(ofSize: 13)
        leftTimeLabel.textAlignment = .center
        leftTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right).offset(padding)
            make.width.equalTo(70)
            make.top.bottom.equalToSuperview()
        }

        speedButton.setTitle("1x", for: .normal)
        speedButton.setTitle("2x", for: .selected)
        speedButton.setTitleColor(UIColor.white, for: .normal)
        speedButton.titleLabel?.font = UIFont.iconFont(size: 18)
        speedButton.addTarget(self, action: #selector(clickSpeedBtn(_:)), for: .touchUpInside)
        speedButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(footerViewHeight)
        }

        rightTimeLabel.text          = "00:00:00"
        rightTimeLabel.textColor     = UIColor.white
        rightTimeLabel.font          = UIFont.systemFont(ofSize: 13)
        rightTimeLabel.textAlignment = .center
        rightTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(speedButton.snp.left).offset(-padding)
            make.width.equalTo(70)
            make.top.bottom.equalToSuperview()
        }

        progressSliderView.minimumValue = 0.0
        progressSliderView.maximumValue = 1.0
        progressSliderView.minimumTrackTintColor = UIColor.orange1
        progressSliderView.maximumTrackTintColor = UIColor.clear
        progressSliderView.addTarget(self, action: #selector(willDragSlider(_:)), for: .touchDown)
        progressSliderView.addTarget(self, action: #selector(draggingSlider(_:)), for: .valueChanged)
        progressSliderView.addTarget(self, action: #selector(finishDragSlider(_:)), for: .touchUpInside)
        progressSliderView.addTarget(self, action: #selector(finishDragSlider(_:)), for: .touchDragOutside)
        progressSliderView.addTarget(self, action: #selector(finishDragSlider(_:)), for: .touchDragExit)
        progressSliderView.snp.makeConstraints { (make) in
            make.left.equalTo(leftTimeLabel.snp.right).offset(padding)
            make.right.equalTo(rightTimeLabel.snp.left).offset(-padding)
            make.top.bottom.equalToSuperview()
        }

        progressView.trackTintColor = UIColor.gray1
        progressView.progressTintColor = UIColor.gray1.withAlphaComponent(0.3)
        progressView.snp.makeConstraints { (make) in
            make.left.equalTo(progressSliderView.snp.left)
            make.right.equalTo(progressSliderView.snp.right)
            make.centerY.equalTo(progressSliderView.snp.centerY)
        }
    }

    // TODO: 设置数据

    /// 播放器设置
    func makeData(_ path: String) {
        // 设置音频类别
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        } catch {
            print("音频类别设置错误!!!")
        }
        playerItem = getPlayItem(vidoPath: path)
        player.replaceCurrentItem(with: playerItem)
        playerLayer = AVPlayerLayer(player: player)

        // 添加监听
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { (time) in
            self.refreshTimeObserver(time)
        }
    }


    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(playFinishNotification), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotateNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    // TODO: 通知处理
    @objc func playFinishNotification() {
        pauseVideo()
    }

    @objc func deviceRotateNotification() {
        switch UIDevice.current.orientation {
        case .portrait:
            headerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(kStatusBarHeight)
            }
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            headerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview()
            }
        default:
            break
        }
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            self.playerLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        }
    }

    // TODO: 手势处理

    @objc func singleTapScreenView(_ sender: UITapGestureRecognizer) {
        print("singleTapScreenView")
    }

    @objc func doubleTapScreenView(_ sender: UITapGestureRecognizer) {
        print("doubleTapScreenView")
        if playButton.isSelected {
            playVideo()
        } else {
            pauseVideo()
        }
    }

    @objc func panScreenView(_ sender: UIPanGestureRecognizer) {
        print("panScreenView")
    }

    // TODO: 事件处理

    func playVideo() {
        playButton.isSelected = false
        self.player.play()
    }

    func pauseVideo() {
        playButton.isSelected = true
        self.player.pause()
    }

    func seekToVideo(startTime time: Int64) {
        let cmTime = CMTimeMake(value: time, timescale: 1)
        player.seek(to: cmTime) { (finish) in
            if finish {
                self.playVideo()
            }
        }
    }

    /// 显示视频播放页
    func showVideo() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -kScreenHeight)
        }) { (finish) in
            if finish {
                self.playVideo()
            }
        }
    }

    /// 隐藏视频播放页
    func hideVideo() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = .identity
            self.pauseVideo()
        }) { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        }
    }

    @objc func clickBackBtn(_ button: UIButton) {
        hideVideo()
    }

    @objc func clickMenuBtn(_ button: UIButton) {

    }

    @objc func clickPlayBtn(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            pauseVideo()
        } else {
            playVideo()
        }
    }

    @objc func clickSpeedBtn(_ button: UIButton) {
        button.isSelected = !button.isSelected

    }

    @objc func willDragSlider(_ slider: UISlider) {
        pauseVideo()
        isSliding = true
    }

    @objc func draggingSlider(_ slider: UISlider) {
        let totalTime = Float(playerItem?.duration.seconds ?? 0.0)
        let currentTime = totalTime * slider.value
        seekToVideo(startTime: Int64(currentTime))
    }

    @objc func finishDragSlider(_ slider: UISlider) {
        playVideo()
        isSliding = false
    }

    /// 更新时间事件
    func refreshTimeObserver(_ time: CMTime) {
        guard let item = playerItem else {
            return
        }
        let totalTime   = item.duration.seconds
        let currentTime = time.seconds
        if totalTime.isNaN || currentTime.isNaN {
            return
        }
        // 更新sliderView
        if !isSliding {
            progressSliderView.value = Float(currentTime/totalTime)
        }
        // 更新显示的时间
        leftTimeLabel.text  = transformTime(Int(currentTime))
        rightTimeLabel.text = transformTime(Int(totalTime))
    }

    // TODO: 工具函数

    private func getPlayItem(vidoPath path: String) -> AVPlayerItem? {
        // 编码文件名,以放有中文导致存储失败
        let charSet = CharacterSet.urlQueryAllowed
        guard let _path   = path.addingPercentEncoding(withAllowedCharacters: charSet) else { return nil }
        let url     = URL(fileURLWithPath: _path)
        let item    = AVPlayerItem(url: url)
        return item
    }

    private func transformTime(_ time: Int) -> String {
        let hour   = time / 3600
        let minute = time % 3600 / 60
        let second = time % 60
        return String(format: "%02ld:%02ld:%02ld", hour, minute, second)
    }

}
