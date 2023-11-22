//
//  FileGridContainerView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 8/11/23.
//

import SwiftUI
import AsyncView
import APIClient
import FileModels
import FileRepository

struct FileGridView: View {
    @EnvironmentObject var fileNavViewModel: FileNavigationViewModel
    
    @StateObject var viewModel: FileGridViewModel
    init(viewModel: FileGridViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    private var gridBody: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.fileItems, id: \.id) { item in
                    if let folder = item as? Folder {
                        folderCellView(for: folder)
                    } else if let imageFile = item as? ImageFile {
                        imageCellView(for: imageFile)
                    } else if let textFile = item as? TextFile {
                        textCellView(for: textFile)
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FolderActionsButton(folder: viewModel.folder, repository: viewModel.repository)
                }
            }
        }
        .navigationTitle(viewModel.folder.name)
        .preferredColorScheme(.dark)
    }
    
    // Wrap content in loadable view object to handle loading and error states
    var body: some View {
        AsyncLoadableView(viewModel: viewModel) {
            gridBody
        }
    }
}

// MARK: Cell Configuration

extension FileGridView {
    
    func folderCellView(for folder: Folder) -> some View  {
        NavigationLink {
            FileGridView(viewModel: FileGridViewModel(folder: folder, repository: viewModel.repository))
        } label: {
            FileCell(viewModel: FileCellViewModel(file: folder))
                .contextMenu {
                    deleteButton(for: folder)
                }
        }
    }
    
    func imageCellView(for imageFile: ImageFile) -> some View {
        NavigationLink {
            AsyncImageView {
                return try await viewModel.image(for: imageFile)
            }
            // Show the image title inline in the nav bar
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(imageFile.name)
        } label: {
            FileCell(viewModel: FileCellViewModel(file: imageFile))
                .contextMenu {
                    deleteButton(for: imageFile)
                }
        }
    }
    
    func textCellView(for textFile: TextFile) -> some View {
        NavigationLink {
            AsyncTextView {
                return try await viewModel.text(for: textFile)
            }
            // Show the image title inline in the nav bar
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(textFile.name)
        } label: {
            FileCell(viewModel: FileCellViewModel(file: textFile))
                .contextMenu {
                    deleteButton(for: textFile)
                }
        }
    }
}

// MARK: File Deletion

extension FileGridView {
    func deleteButton(for fileItem: some FileItem) -> some View {
        Button(action: {
            Task {
                await viewModel.delete(fileItem)
            }
        }) {
            Text("Delete")
            Image(systemName: "trash")
        }
    }
}

// MARK: File Creation Action Sheet

extension FileGridViewModel {
    func image(for imageFile: ImageFile) async throws -> UIImage {
        let data = try await repository.downloadData(for: imageFile)
        return UIImage(data: data)!
    }
    
    func text(for textFile: TextFile) async throws -> String {
        let data = try await repository.downloadData(for: textFile)
        return String(data: data, encoding: .utf8)!
    }
}



// MARK: SwiftUI Preview

#Preview {
    let folder = Folder(id: "1", name: "Documents", modificationDate: Date.now, parentId: nil)
    let user = User(firstName: "noel", lastName: "smith", userName: "noel", password: "foobar", rootFolder: folder)
    let viewModel = FileNavigationViewModel(currentUser: user, repository: BeDriveRepository(user: user, apiClient: BaseAPIClient()))
    
    return FileNavigationView<BeDriveAppRouter>(viewModel: viewModel)
}
