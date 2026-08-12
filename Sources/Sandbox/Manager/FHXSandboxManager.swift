//
//  FHXSandboxManager.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/21.
//

import Foundation

final class FHXSandboxManager {

    static let shared = FHXSandboxManager()

    private init() {}

}

// MARK: - Public

extension FHXSandboxManager {

    /// 根目录
    func rootItems() -> [FHXSandboxModel] {

        var models: [FHXSandboxModel] = []

        if let model = directoryModel(
            path: NSHomeDirectory() + "/Documents"
        ) {
            models.append(model)
        }

        if let model = directoryModel(
            path: NSHomeDirectory() + "/Library"
        ) {
            models.append(model)
        }

        if let model = directoryModel(
            path: NSHomeDirectory() + "/Library/Caches"
        ) {
            models.append(model)
        }

        if let model = directoryModel(
            path: NSTemporaryDirectory()
        ) {
            models.append(model)
        }

        if let bundle =
            Bundle.main.bundlePath
                .components(separatedBy: "/")
                .last {

            models.append(
                FHXSandboxModel(
                    name: bundle,
                    path: Bundle.main.bundlePath,
                    isDirectory: true,
                    fileType: .folder,
                    fileSize: 0,
                    createDate: nil,
                    modifyDate: nil,
                    childrenCount: folderItemCount(
                        Bundle.main.bundlePath
                    )
                )
            )
        }

        return models
    }

    /// 指定目录内容
    func contents(
        at path: String
    ) -> [FHXSandboxModel] {

        let manager =
        FileManager.default

        guard let files =
                try? manager.contentsOfDirectory(
                    atPath: path
                )
        else {

            return []
        }

        var models: [FHXSandboxModel] = []

        for file in files {

            let fullPath =
            (path as NSString)
                .appendingPathComponent(file)

            if let model =
                itemModel(
                    path: fullPath
                ) {

                models.append(model)
            }
        }

        models.sort {

            if $0.isDirectory != $1.isDirectory {

                return $0.isDirectory
            }

            return $0.name
                .localizedCompare($1.name)
            == .orderedAscending
        }

        return models
    }

}

// MARK: - Private

private extension FHXSandboxManager {

    func directoryModel(
        path: String
    ) -> FHXSandboxModel? {

        let name =
        (path as NSString)
            .lastPathComponent

        return FHXSandboxModel(
            name: name,
            path: path,
            isDirectory: true,
            fileType: .folder,
            fileSize: 0,
            createDate: nil,
            modifyDate: nil,
            childrenCount: folderItemCount(path)
        )
    }

    func itemModel(
        path: String
    ) -> FHXSandboxModel? {

        let manager =
        FileManager.default

        guard let attr =
                try? manager.attributesOfItem(
                    atPath: path
                )
        else {

            return nil
        }

        let type =
        attr[.type] as? FileAttributeType

        let size =
        attr[.size] as? UInt64 ?? 0

        let create =
        attr[.creationDate] as? Date

        let modify =
        attr[.modificationDate] as? Date

        let isDirectory =
        type == .typeDirectory

        return FHXSandboxModel(

            name:
                (path as NSString)
                .lastPathComponent,

            path: path,

            isDirectory: isDirectory,

            fileType:
                fileType(
                    path: path,
                    isDirectory: isDirectory
                ),

            fileSize: size,

            createDate: create,

            modifyDate: modify,

            childrenCount:
                isDirectory
                ? folderItemCount(path)
                : 0
        )
    }
    
    func fileType(
        path: String,
        isDirectory: Bool
    ) -> FHXSandboxFileType {

        if isDirectory {

            return .folder
        }

        let ext =
        (path as NSString)
            .pathExtension
            .lowercased()

        switch ext {

        case "png",
             "jpg",
             "jpeg",
             "heic",
             "webp":

            return .image

        case "json":

            return .json

        case "txt",
             "log":

            return .text

        case "plist":

            return .plist

        case "sqlite",
             "db":

            return .sqlite

        case "pdf":

            return .pdf

        case "zip":

            return .zip

        case "mp4",
             "mov":

            return .video

        case "mp3",
             "aac",
             "wav":

            return .audio
            
        case "doc",
             "docx":

            return .word

        case "xls",
             "xlsx",
             "csv":

            return .excel

        case "ppt",
             "pptx":

            return .powerpoint
        case "gif":
            return .gif
        case "svg":
            return .svg
        case "tif":
            return .tif
        default:

            return .unknown
        }
    }
    
    func folderItemCount(
        _ path: String
    ) -> Int {

        let manager =
        FileManager.default

        guard let files =
                try? manager.contentsOfDirectory(
                    atPath: path
                )
        else {

            return 0
        }

        return files.count
    }

}
