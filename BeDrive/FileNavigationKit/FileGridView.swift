//
//  FileGridContainerView.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 8/11/23.
//

import SwiftUI
import AsyncView
import APIClient

struct FileGridView: View {
    @ObservedObject var viewModel: FileGridViewModel
    init(viewModel: FileGridViewModel) {
        self.viewModel = viewModel
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    private var gridBody: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.fileItems) { item in
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
                    Button(action: {
                        viewModel.showFolderActionsAlert = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .actionSheet(isPresented: $viewModel.showFolderActionsAlert) {
                // Present an action sheet with options
                fileCreationActionSheet()
            }
            .fileImporter(isPresented: $viewModel.showDocumentPicker, allowedContentTypes: [.text, .png, .jpeg], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let files):
                    guard let file = files.first else { return }
                    viewModel.selectedFileUrl = file
                case .failure(let error):
                    // handle error
                    print(error)
                }
            }
        }
        .navigationTitle(viewModel.folder.name)
        .preferredColorScheme(.dark)
    }
    
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
    
    func delete(_ fileItem: FileItem) {
        Task {
            try await viewModel.repository.deleteItem(fileItem)
        }
    }
    
    func deleteButton(for fileItem: FileItem) -> some View {
        Button(action: {
            delete(fileItem)
        }) {
            Text("Delete")
            Image(systemName: "trash")
        }
    }
}

// MARK: File Creation Action Sheet

extension FileGridView {
    
    func fileCreationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Folder Actions"),
            buttons: [
                .default(Text("Create new folder"), action: {
                    // Show an alert with a text field for folder name
                    createFolderAlert()
                }),
                .default(Text("Upload file from device"), action: {
                    viewModel.showDocumentPicker = true
                }),
                .cancel()
            ]
        )
    }
    
    func createFolderAlert() {
        // Alert with a text field for entering folder name
        let alert = UIAlertController(title: "Create Folder", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Folder Name"
        }
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            // Handle the folder creation with the entered folder name
            if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
                Task {
                    do {
                        let folder = try await viewModel.repository.createFolder(named: folderName, in: viewModel.folder)
                        print(folder)
                    } catch {
                        print(error)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
}

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
    let viewModel = FileNavigationViewModel(currentUser: user, repository: BeDriveRepository(apiClient: BaseAPIClient()))
    
    return FileNavigationView(viewModel: viewModel)
}
