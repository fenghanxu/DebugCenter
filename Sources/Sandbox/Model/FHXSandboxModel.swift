//
//  FHXSandboxModel.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/21.
//


import Foundation

enum FHXSandboxFileType {

    case folder

    case image

    case json

    case text

    case plist

    case sqlite

    case pdf

    case zip

    case video

    case audio
    
    case word

    case excel

    case powerpoint
    
    case gif
    
    case svg
    
    case tif

    case unknown
}

struct FHXSandboxModel {
    
    /// 文件名
    let name: String
    
    /// 完整路径
    let path: String
    
    /// 是否目录
    let isDirectory: Bool

    /// 文件类型
    let fileType: FHXSandboxFileType
    
    /// 文件大小(Byte)
    let fileSize: UInt64
    
    /// 创建时间
    let createDate: Date?

    /// 修改时间
    let modifyDate: Date?

    /// 文件夹数量
    let childrenCount: Int
}
