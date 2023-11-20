//
//  FileCellViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 17/11/23.
//

import Foundation

class FileCellViewModel: ObservableObject {
    enum Icon: String {
        case folder = "folder.fill"
        case image = "photo"
        case text = "doc.text"
    }
    let name: String
    let icon: Icon
    let date: String?
    let size: String?
    
    private static let dateToStringFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    init(file: some FileItem) {
        self.name = file.name
        self.icon = file.cellIcon()
        self.date = Self.dateToStringFormatter.string(from: file.modificationDate)
        if let dataItem = file as? (any DataItem), dataItem.size > 0 {
            self.size = Self.dataSizeString(from: dataItem.size)
        } else {
            self.size = nil
        }
    }
    
    private static func dataSizeString(from bytes: Int) -> String {
        let kilobytes = Double(bytes) / 1024.0
        let megabytes = kilobytes / 1024.0

        if megabytes >= 1.0 {
            return String(format: "%.2f MB", megabytes)
        } else if kilobytes >= 1.0 {
            return String(format: "%.2f KB", kilobytes)
        } else {
            return "\(bytes) Bytes"
        }
    }
}

extension FileItem {
    func cellIcon() -> FileCellViewModel.Icon {
        if self is ImageFile {
            return .image
        }
        if self is TextFile {
            return .text
        }
        return .folder
    }
}
