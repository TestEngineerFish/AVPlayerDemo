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
        let topHeight = UIDevice.current.orientation == .portrait ? kStatusBarHeight : 0
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topHeight)
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
    }

    // TODO: 工具函数

    private func getPlayItem(vidoPath path: String) -> AVPlayerItem? {
        // 编码文件名,以放有中文导致存储失败
//        let charSet = CharacterSet.urlQueryAllowed
//        guard let _path   = path.addingPercentEncoding(withAllowedCharacters: charSet) else { return nil }
        let url     = URL(fileURLWithPath: path)
        let item    = AVPlayerItem(url: url)
        return item
    }
}
