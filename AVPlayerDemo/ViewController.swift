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
    var documentPath: String?
    var documentList = [BPFileModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        _initUI()
        _setData()
    }

    func _initUI() {
        self.title = "Document List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func _setData() {
        documentList = BPFileManager.default.getFilesModel(documentPath)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let fileModel = documentList[indexPath.row]
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = fileModel.name
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileModel = documentList[indexPath.row]
        if fileModel.type == .folder {
            let vc = ViewController()
            vc.title = fileModel.name
            vc.documentPath = fileModel.path
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.toast("显示播放页面")
        }
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }


}

