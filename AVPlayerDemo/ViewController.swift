//
//  ViewController.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/20.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()

    var playerManager: PlayerManager?

    var documentList = ["我是第一个目录","我是第二个目录"]

    override func viewDidLoad() {
        super.viewDidLoad()
        _initUI()
        _setData()
    }

    func _initUI() {
//        let activity = UIActivityIndicatorView(style: .gray)
//        self.view.addSubview(activity)
//        activity.startAnimating()
        self.navigationController?.title = "Document List"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func _setData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = documentList[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path      = Bundle.main.path(forResource: "objectC", ofType: "mp4") ?? ""
        let manager = PlayerManager(path: path, frame: kWindow.bounds)

//        let vc = ViewController()
//        vc.title = documentList[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }


}

