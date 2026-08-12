//
//  FHXSandboxTestImporter.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

import Foundation

final class FHXSandboxTestImporter {

    static func importTestFiles() {

        let folder =
        (NSHomeDirectory() as NSString)
            .appendingPathComponent(
                "Documents/FHXDebugKitTest"
            )

        let manager = FileManager.default

        if !manager.fileExists(atPath: folder) {

            try? manager.createDirectory(
                atPath: folder,
                withIntermediateDirectories: true
            )
        }

        let files = [
            "test.txt",
            "test.log",
            "test.json",
            "test.plist",
            "test.png",
            "test.pdf",
            "test.mp4",
            "test.mp3",
            "test.zip",
            "test.sqlite",
            "test.docx",
            "test.xlsx",
            "test.pptx",
            "test.doc",
            "test.xls",
            "test.ppt",
            "test.jpg",
            "test.jpeg",
            "test.tif",
            "test.gif",
            "test.svg",
            "test.heic",
            "test.webp"
        ]

        for file in files {

            guard
                let bundlePath =
                Bundle.main.path(
                    forResource:
                        (file as NSString).deletingPathExtension,
                    ofType:
                        (file as NSString).pathExtension
                )
            else {
                continue
            }

            let target =
            (folder as NSString)
                .appendingPathComponent(file)

            if manager.fileExists(atPath: target) {
                continue
            }

            try? manager.copyItem(
                atPath: bundlePath,
                toPath: target
            )
        }

        print("Sandbox Test Files Imported")
    }
}
