//
//  FileManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/25.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation

struct BPFileManager {

    static func getDocumentList() -> [String]? {
        var docList = [String]()
        guard let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return nil
        }
        do {
            docList = try FileManager.default.contentsOfDirectory(atPath: documentPath)
        } catch {
            return nil
        }
        print(docList)
        return docList
    }

}
