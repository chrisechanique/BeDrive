//
//  FolderActionsViewModel.swift
//  BeDrive
//
//  Created by Chris Echanique on 21/11/23.
//

import Foundation
import FileRepository
import FileModels

// FolderActionsViewModel: Manages state and actions related to folder operations.
// Handles folder creation and file upload using FileRepository and responds to changes in selectedFileUrl to initiate file creation.

class FolderActionsViewModel: ObservableObject {
    @MainActor @Published var showFolderActions = false
    @MainActor @Published var showDocumentPicker = false
    @MainActor @Published var showAlert = false
    @MainActor @Published var errorMessage: String? = nil
    @MainActor @Published var selectedFileUrl: URL? {
        didSet {
            guard let selectedFileUrl else { return }
            Task {
                await didSelectFileURL(selectedFileUrl)
            }
        }
    }
    
    let repository: FileRepository
    let folder: Folder
    
    init(folder: Folder, repository: FileRepository) {
        self.folder = folder
        self.repository = repository
    }
    
    @MainActor
    func createFolder(with folderName: String) async {
        do {
            _ = try await repository.createFolder(named: folderName, in: folder)
            showFolderActions = false
        } catch {
            showAlert = true
            let repoError = error as? UserFriendlyDescribing
            errorMessage = repoError?.userFriendlyDescription
        }
    }
    
    @MainActor
    func didSelectFileURL(_ url: URL) async {
        guard url.startAccessingSecurityScopedResource() else { return }
        do {
            let name = url.lastPathComponent
            let data = try Data(contentsOf: url)
            _ = try await repository.createDataItem(in: folder, name: name, data: data)
        } catch {
            showAlert = true
            errorMessage = error.localizedDescription
        }
        url.stopAccessingSecurityScopedResource()
    }
}
