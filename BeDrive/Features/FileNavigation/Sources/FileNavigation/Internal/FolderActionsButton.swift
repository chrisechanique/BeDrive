//
//  FolderActionsButton.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import SwiftUI
import FileModels
import FileRepository

struct FolderActionsButton: View {
    @StateObject var viewModel: FolderActionsViewModel
    
    init(folder: Folder, repository: FileRepository) {
        _viewModel = StateObject(wrappedValue: FolderActionsViewModel(folder: folder, repository: repository))
    }
    
    var body: some View {
        Button(action: {
            viewModel.showFolderActions = true
        }) {
            Image(systemName: "plus")
        }
        .actionSheet(isPresented: $viewModel.showFolderActions) {
            // Present an action sheet with options
            fileCreationActionSheet()
        }
        .fileImporter(isPresented: $viewModel.showDocumentPicker, allowedContentTypes: [.text, .png, .jpeg], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let files):
                guard let file = files.first else { return }
                viewModel.selectedFileUrl = file
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .alert(isPresented: $viewModel.showAlert, content: {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""))
        })
    }
    
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
                    await viewModel.createFolder(with: folderName)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
}
