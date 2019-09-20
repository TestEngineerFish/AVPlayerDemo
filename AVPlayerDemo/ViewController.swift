//
//  ViewController.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var centerBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    var playerManager: PlayerManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        _initUI()
        _setData()
    }

    func _initUI() {
        let activity = UIActivityIndicatorView(style: .gray)
        self.view.addSubview(activity)
        activity.startAnimating()
    }

    func _setData() {
        let path      = Bundle.main.path(forResource: "slider", ofType: "mp4") ?? ""
        let frame     = contentView.bounds
    }

    @IBAction func playAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

    }


}

