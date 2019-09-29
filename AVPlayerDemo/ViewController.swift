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
        tableView.register(FileTableViewCell.classForCoder(), forCellReuseIdentifier: "fileTableViewCell")
    }

    func _setData() {
        documentList = BPFileManager.default.getFilesModel(documentPath)
        tableView.reloadData()
    }
    
    /// TODO: UITableViewDelegate & UITabelViewDatasource

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "fileTableViewCell") as? FileTableViewCell else {
            return UITableViewCell()
        }
        let fileModel = documentList[indexPath.row]
        cell.makeData(fileModel)
        return cell
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
            guard let path = fileModel.path else {
                self.view.toast("路径无效")
                return
            }
            let manager = PlayerManager(path: path, frame: kWindow.bounds)
            manager.playVideo()
        }
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }


}

