//
//  FileCell.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import SwiftUI

// FileCell: Displays a file or folder item with an associated view model.
// The view includes an icon, file/folder name, modification date, and size (if applicable).
// Utilizes the FileCellViewModel to populate and format the displayed information.

struct FileCell: View {
    enum Icon: String {
        case folder = "folder"
        case image = "photo"
        case text = "doc.text"
    }
    let viewModel: FileCellViewModel
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: viewModel.icon.rawValue)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            VStack(spacing: 2) {
                Text(viewModel.name)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(Color.white)
                if let date = viewModel.date {
                    captionLabel(with: date)
                }
                if let size = viewModel.size {
                    captionLabel(with: size)
                }
            }
        }.padding(8.0)
    }
    
    func captionLabel(with text: String) -> some View {
        Text(text)
            .font(.caption2)
            .lineLimit(1)
            .foregroundStyle(Color.white.opacity(0.6))
    }
}
