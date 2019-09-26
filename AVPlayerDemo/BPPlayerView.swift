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

enum RotateDirectionType {
    case left, right, up
}

class BPPlayerView: UIView, UIGestureRecognizerDelegate {

    fileprivate let headerViewHeight: CGFloat = 64
    fileprivate let footerViewHeight: CGFloat = 40
    fileprivate let padding: CGFloat          = 10
    fileprivate let aspectRatio: CGFloat      = kScreenHeight/kScreenWidth

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
    let fullscreenButton   = UIButton()
    let footerView         = UIView()
    let backButton         = UIButton()
    let menuButton         = UIButton()
    let loadView           = UIActivityIndicatorView(style: .white)

    fileprivate var timer: Timer?

    // TODO: 设置UI
    func makeUI() {
        makeSubviews()
        makeHeaderSubviews()
        addGresture()
    }

    /// 设置子视图
    private func makeSubviews() {
        kWindow.addSubview(self)
        let playHeight = kScreenWidth/aspectRatio
        playerLayer.frame           = CGRect(x: 0, y: (self.height - playHeight)/2, width: kScreenWidth, height: playHeight)
        playerLayer.videoGravity    = AVLayerVideoGravity.resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(playerLayer)

        // 设置顶部遮罩层
        addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.top.equalTo(playerLayer.frame.minY)
            make.width.equalTo(playerLayer.width)
            make.height.equalTo(playerLayer.height)
            make.left.equalToSuperview()
        }

        // 设置顶部视图
        coverView.addSubview(headerView)
        headerView.backgroundColor = UIColor.clear
        headerView.snp.makeConstraints { (make) in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }

        // 设置底部视图
        coverView.addSubview(footerView)
        footerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        footerView.snp.makeConstraints { (make) in
            make.left.bottom.width.equalToSuperview()
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
        backButton.titleLabel?.font = UIFont.iconFont(size: 16)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.addTarget(self, action: #selector(clickBackBtn), for: .touchUpInside)
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(headerView.height)
        }

        // 设置菜单按钮
        headerView.addSubview(menuButton)
        menuButton.frame = CGRect(x: headerView.width - headerView.height - 15, y: 0, width: headerView.height, height: headerView.height)
        menuButton.setTitle(IconFont.publis.rawValue, for: .normal)
        menuButton.titleLabel?.font = UIFont.iconFont(size: 16)
        menuButton.setTitleColor(UIColor.white, for: .normal)
        menuButton.addTarget(self, action: #selector(clickMenuBtn), for: .touchUpInside)
        menuButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(headerView.height)
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
        footerView.addSubview(fullscreenButton)

        playButton.setTitle(IconFont.back.rawValue, for: .normal)
        playButton.setTitle(IconFont.publis.rawValue, for: .selected)
        playButton.setTitleColor(UIColor.white, for: .normal)
        playButton.titleLabel?.font = UIFont.iconFont(size: 16)
        playButton.addTarget(self, action: #selector(clickPlayBtn), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(footerView.height)
        }

        leftTimeLabel.text          = "00:00"
        leftTimeLabel.textColor     = UIColor.white
        leftTimeLabel.font          = UIFont.systemFont(ofSize: 13)
        leftTimeLabel.textAlignment = .center
        leftTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right).offset(padding)
            make.width.equalTo(30)
            make.top.bottom.equalToSuperview()
        }

        fullscreenButton.setTitle(IconFont.back.rawValue, for: .normal)
        fullscreenButton.setTitle(IconFont.publis.rawValue, for: .selected)
        fullscreenButton.setTitleColor(UIColor.white, for: .normal)
        fullscreenButton.titleLabel?.font = UIFont.iconFont(size: 16)
        fullscreenButton.addTarget(self, action: #selector(clickFullscreenBtn), for: .touchUpInside)
        fullscreenButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(footerView.height)
        }

        rightTimeLabel.text          = "00:00"
        rightTimeLabel.textColor     = UIColor.white
        rightTimeLabel.font          = UIFont.systemFont(ofSize: 13)
        rightTimeLabel.textAlignment = .center
        rightTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(fullscreenButton.snp.left).offset(-padding)
            make.width.equalTo(30)
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

    /// 添加手势事件
    private func addGresture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapScreenView(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panScreenView(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
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
//        addProgressObserver()
//        addPlayerItemobserver()
    }

    // TODO: 事件处理

    @objc func clickBackBtn() {

    }

    @objc func clickMenuBtn() {

    }

    @objc func clickPlayBtn() {

    }

    @objc func clickFullscreenBtn() {

    }

    func setFullscreen(_ direcction: RotateDirectionType) {
        kWindow.addSubview(self)
        UIView.animate(withDuration: 0.25) {
            if direcction == .left {
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            } else {
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            }
        }
        self.snp.updateConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func willDragSlider(_ slider: UISlider) {

    }

    @objc func draggingSlider(_ slider: UISlider) {

    }

    @objc func finishDragSlider(_ slider: UISlider) {

    }

    @objc func tapScreenView(_ sender: UITapGestureRecognizer) {

    }

    @objc func panScreenView(_ sender: UIPanGestureRecognizer) {

    }

    /// 更新时间事件
    func refreshTimeObserver(_ time: CMTime) {

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
}
