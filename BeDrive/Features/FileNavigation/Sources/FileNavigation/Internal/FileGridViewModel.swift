//
//  FileGridViewModel.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 17/11/23.
//

import Foundation
import AsyncView
import FileCache
import FileModels
import FileRepository

// FileGridViewModel: Manages the data for the FileGridView.
// Conforms to the DataLoadable protocol for handling loading, error, and resolved states.
// Tracks fileItems, dataState, and errorMessage as published properties for UI updates.
// Utilizes repository methods for fetching, deleting, and subscribing to file updates.
// Implements load() to fetch files, subscribeToFileUpdates() for real-time updates, and delete() for file deletion.

class FileGridViewModel: ObservableObject, DataLoadable {
    @MainActor @Published var fileItems: [any FileItem] = []
    @MainActor @Published var dataState: DataLoadingState = .loading(message: "Loading...")
    @MainActor @Published var errorMessage: String? = nil
    @MainActor @Published var emptyFolderMessage: String?
    let folder: Folder
    let repository: FileRepository
    
    init(folder: Folder, repository: FileRepository) {
        self.folder = folder
        self.repository = repository
    }
    
    func subscribeToFileUpdates() async {
        for await items in await repository.getFileCache(for: folder).$files.values {
            await MainActor.run(body: {
                fileItems = items
                
                // Show message when folder is resolved with no items
                if dataState == .resolved {
                    emptyFolderMessage = items.count == 0 ? "Folder is empty" : nil
                }
            })
        }
    }
    
    @MainActor
    func load() async {
        do {
            fileItems = try await repository.fetchFiles(in: folder)
            dataState = .resolved
            emptyFolderMessage = fileItems.count == 0 ? "Folder is empty" : nil
        } catch {
            // Only show the error message if the view has never resolved the data
            if dataState != .resolved {
                dataState = .error(message: error.localizedDescription)
            }
        }
        Task {
            await subscribeToFileUpdates()
        }
    }
    
    @MainActor
    func delete(_ fileItem: any FileItem) async {
        do {
            let _ = try await repository.deleteItem(fileItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
