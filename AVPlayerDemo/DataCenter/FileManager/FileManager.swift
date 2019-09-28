//
//  FileManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/25.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation

struct BPFileManager {
    
    static var `default` = BPFileManager()

    func getDocumentList() -> [String]? {
        var docList = [String]()
        if let path = getPath(.documentDirectory) {
            do {
                docList = try FileManager.default.contentsOfDirectory(atPath: path)
            } catch {
                return nil
            }
            docList.forEach { (name) in
                getDocumentSource(path + "/" + name)
            }
        }

        return docList
    }
    
    func getDocumentSource(_ path: String) {
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: path)
            print(dict)
        } catch {
            print("???")
        }
        
    }
    
    private func getPath(_ type: FileManager.SearchPathDirectory) -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(type, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return nil
        }
        return path
    }

}
