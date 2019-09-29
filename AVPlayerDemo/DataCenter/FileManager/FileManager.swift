//
//  FileManager.swift
//  AVPlayerDemo
//
//  Created by 沙庭宇 on 2019/9/25.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

struct BPFileManager {
    
    static var `default` = BPFileManager()

    func getFilesList() -> [BPFileModel]? {
        var fileModelList = [BPFileModel]()
        if let documentPath = getPath(.documentDirectory) {
            fileModelList = getFilesModel(documentPath)
        }
        return fileModelList
    }

    /// 获取目录下所有文件路径
    /// - Parameter path: 目录路径
    /// - Returns: 目录下文件的路径列表
    private func getFilesModel(_ path: String) -> [BPFileModel] {
        var modelList = [BPFileModel]()
        do {
            let fileNameList = try FileManager.default.contentsOfDirectory(atPath: path)
            fileNameList.forEach { (fileName) in
                let filePath = path + "/" + fileName
                var model = BPFileModel()
                model.name = fileName
                model.path = filePath
                model.type = getFileType(filePath)
                modelList.append(model)
            }
        } catch {
            print("获取目录下文件失败")
        }
        return modelList
    }

    /// 获取目录地址
    /// - Parameter type: 目录类型
    /// - Returns: 如果目录不存在,则返回nil
    private func getPath(_ type: FileManager.SearchPathDirectory) -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(type, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return nil
        }
        return path
    }

    /// 获取文件类型
    /// - Parameter path: 文件地址
    /// - Returns: 文件类型
    private func getFileType(_ path: String) -> BPFileType {
        var type = BPFileType.unknown
        let fileExt = URL(fileURLWithPath: path).pathExtension
        if fileExt == "" {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            type = isDirectory.boolValue ? .folder : .unknown
        } else {
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExt as CFString, nil)
//            UTTypeConformsTo(value, kUTTypeImage)
            if let utiValue = uti?.takeRetainedValue() {
                if UTTypeConformsTo(utiValue, kUTTypeImage) {
                    type = .image
                } else if UTTypeConformsTo(utiValue, kUTTypeAudiovisualContent) {
                    type = .audiovisual
                }
            }
        }
        return type
    }

    //            let imageTypes: [CFString] = [kUTTypeImage, kUTTypeJPEG, kUTTypeJPEG2000, kUTTypeTIFF, kUTTypePICT, kUTTypeGIF, kUTTypePNG, kUTTypeQuickTimeImage, kUTTypeAppleICNS, kUTTypeBMP, kUTTypeICO, kUTTypeRawImage, kUTTypeScalableVectorGraphics, kUTTypeLivePhoto]
    //            let audiovisualTypes = [kUTTypeAudiovisualContent, kUTTypeMovie, kUTTypeVideo, kUTTypeAudio, kUTTypeQuickTimeMovie, kUTTypeMPEG, kUTTypeMPEG2Video, kUTTypeMPEG2TransportStream, kUTTypeMP3, kUTTypeMPEG4, kUTTypeMPEG4Audio, kUTTypeAppleProtectedMPEG4Audio, kUTTypeAppleProtectedMPEG4Video, kUTTypeAVIMovie, kUTTypeAudioInterchangeFileFormat, kUTTypeWaveformAudio, kUTTypeMIDIAudio]

}
