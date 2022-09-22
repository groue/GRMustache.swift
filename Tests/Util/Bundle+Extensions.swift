//
//  File.swift
//  
//
//  Created by Fumito Ito on 2022/09/20.
//

import Foundation

extension Bundle {
    static func ofFileDirectory(filePath: String) -> Bundle? {
        let fileURL = URL(fileURLWithPath: filePath)
        let fileDirectoryURL = fileURL.deletingLastPathComponent()

        return Bundle(url: fileDirectoryURL)
    }
}
