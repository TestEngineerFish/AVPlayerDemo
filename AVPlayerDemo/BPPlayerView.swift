//
//  BPPlayerView.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit
import AVFoundation

class BPPlayerView: UIView {

    let kScreenWidth  = UIScreen.main.bounds.width
    let kScreenHeight = UIScreen.main.bounds.height

    var player: AVPlayer?
//    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    var sliderView = UISlider()
    let activity = UIActivityIndicatorView(style: .gray)

    func _initUI() {
        guard let _playerLayer = playerLayer else { return }
        activity.center  = center
        sliderView.frame = CGRect(x: 15, y: kScreenHeight - 45, width: kScreenWidth - 30, height: 5)
        _playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        addSubview(activity)
        addSubview(sliderView)
        layer.addSublayer(_playerLayer)
    }

    func play(videoPath path: String) {
        let playerItem = getPlayItem(vidoPath: path)
        player     = AVPlayer(playerItem: playerItem)
        addProgressObserver()
        addPlayerItemobserver()
        activity.startAnimating()
    }

    func getPlayItem(vidoPath path: String) -> AVPlayerItem? {
        // 编码文件名,以放有中文导致存储失败
        let charSet = CharacterSet.urlQueryAllowed
        guard let _path   = path.addingPercentEncoding(withAllowedCharacters: charSet) else { return nil }
        let url     = URL(fileURLWithPath: _path)
        let item    = AVPlayerItem(url: url)
        return item
    }


    /// 监听播放进度
    func addProgressObserver() {
        guard let durationTime = self.player?.currentItem?.duration else {
            return
        }
        let totalSeconds = CMTimeGetSeconds(durationTime)
        self.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (time:CMTime) in
            let currentTime = CMTimeGetSeconds(time)
            self.sliderView.value = Float(currentTime/totalSeconds)
        })
    }


    /// 添加播放器KVO监听
    func addPlayerItemobserver() {
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    }


    /// 添加播放通知
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinished(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }

    // TODO: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let item = object as? AVPlayerItem else {return}
        if keyPath == "status" {

        }
        if keyPath == "" {

        }
    }

    // TODO: Notification


    /// 播放结束
    ///
    /// - Parameter item: 播放器对象
    @objc func playerDidFinished(_ item: AVPlayerItem) {

    }

    @objc func orientationChanged(_ device: UIDevice) {

    }

}
